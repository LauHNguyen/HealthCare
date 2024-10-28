import 'package:client_beta/services/api_service.dart';
import 'package:client_beta/services/token_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

import 'package:jwt_decoder/jwt_decoder.dart';

class Disease extends StatefulWidget {
  @override
  _DiseaseState createState() => _DiseaseState();
}

class _DiseaseState extends State<Disease> {
  List<dynamic> diseases = [];
  List<bool> isExpandedList = []; // Danh sách trạng thái mở rộng cho từng khung
  final tokenService = TokenService();
  final storage = FlutterSecureStorage();
  String userId = '';
  String diseaseId = '';

  @override
  void initState() {
    super.initState();
    fetchUserInfo();
    fetchDiseases();
  }

  Future<void> fetchDiseases() async {
    String? token = await tokenService.getValidAccessToken();
    if (token == null) {
      throw Exception('No token found');
    }
    final response = await http.get(
      Uri.parse('${dotenv.env['LOCALHOST']}/disease'),
      headers: {
        'Authorization': 'Bearer $token', // Đặt token đã xác thực của bạn
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        diseases = json.decode(response.body);
        isExpandedList = List.generate(diseases.length, (index) => false);
      });
    } else {
      print('Failed to load diseases');
    }
  }

  Future<void> fetchUserInfo() async {
    String? token = await tokenService.getValidAccessToken();
    if (token == null) {
      throw Exception('No token found');
    }
    final response = await http.get(
      Uri.parse('${dotenv.env['LOCALHOST']}/user/id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      try {
        final userIdInfo = json.decode(response.body);
        setState(() {
          userId = userIdInfo['userId'];
        });
      } catch (e) {
        print('Error decoding JSON: $e');
      }
    } else {
      print('Failed to load user info');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bệnh của bạn là ? '),
      ),
      body: ListView.builder(
        itemCount: diseases.length,
        itemBuilder: (context, index) {
          diseaseId = diseases[index]['_id'];
          // Tạo một mảng các màu sắc để áp dụng cho các khung
          List<Color> boxColors = [
            Colors.blueAccent,
            Colors.greenAccent,
            Colors.orangeAccent,
            Colors.purpleAccent,
            Colors.redAccent,
            // Có thể thêm màu tùy ý
          ];

          // Tạo màu cho khung dựa trên chỉ số của mục
          Color boxColor = boxColors[index % boxColors.length];

          return Padding(
            padding: const EdgeInsets.all(8.0),
            child: GestureDetector(
              onTap: () {
                setState(() {
                  isExpandedList[index] = !isExpandedList[index];
                });
              },
              child: AnimatedContainer(
                duration:
                    Duration(milliseconds: 300), // Thời gian hiệu ứng mở rộng
                padding: EdgeInsets.all(16.0),
                width: double.infinity, // Đặt kích thước chiều rộng đầy đủ
                decoration: BoxDecoration(
                  color: boxColor, // Màu nền của khung từ mảng màu
                  borderRadius: BorderRadius.circular(12.0), // Bo góc
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.3), // Màu đổ bóng
                      spreadRadius: 4,
                      blurRadius: 8,
                      offset: Offset(0, 3), // Độ lệch của bóng
                    ),
                  ],
                  border: Border.all(
                    color: Colors.grey.shade300, // Màu viền
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      diseases[index]['Disease'],
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color:
                            Colors.white, // Màu chữ, bạn có thể thay đổi tùy ý
                      ),
                    ),
                    SizedBox(height: 8.0),
                    if (isExpandedList[index])
                      ..._buildQuestionList(diseases[index]['ListQuestion'])
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  List<Widget> _buildQuestionList(Map<String, dynamic>? listQuestions) {
    if (listQuestions == null || listQuestions.isEmpty) {
      return [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            "Không có câu hỏi nào.",
            style: TextStyle(color: Colors.black),
          ),
        )
      ];
    }
    return listQuestions.entries.map((entry) {
      return Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: Text(
                entry.value, // Lấy giá trị của câu hỏi từ map
                style: TextStyle(color: Colors.black),
              ),
            ),
            // Thêm các nút tương tác sau này tại đây, ví dụ:
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: () {
                _showAnswerDialog(entry.key, entry.value);
              },
            ),
          ],
        ),
      );
    }).toList();
  }

  void _showAnswerDialog(String questionId, String questionText) async {
    final TextEditingController answerController = TextEditingController();
    bool isExistingAnswer =
        false; // Biến để kiểm tra xem có câu trả lời hay không

    try {
      // Lấy câu trả lời nếu đã tồn tại
      String previousAnswer = await ApiService('${dotenv.env['LOCALHOST']}')
          .getExistingAnswer(userId, diseaseId, questionId);

      if (previousAnswer.isNotEmpty) {
        //   // Nếu có câu trả lời, điền vào khung trả lời và thiết lập trạng thái là đã tồn tại
        answerController.text = previousAnswer;
        isExistingAnswer = true;
      }

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text('Nhập câu trả lời cho: $questionText'),
            content: TextField(
              controller: answerController,
              decoration: InputDecoration(hintText: 'Nhập câu trả lời của bạn'),
            ),
            actions: [
              TextButton(
                child: Text('Hủy'),
                onPressed: () {
                  Navigator.of(context).pop(); // Đóng dialog
                },
              ),
              TextButton(
                child: Text('Xác nhận'),
                onPressed: () async {
                  String answer = answerController.text;

                  if (answer.isNotEmpty) {
                    try {
                      if (isExistingAnswer) {
                        // Nếu câu trả lời đã tồn tại, cập nhật nó
                        await ApiService('${dotenv.env['LOCALHOST']}')
                            .updateAnswer(
                                userId, diseaseId, questionId, answer);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('Câu trả lời đã được cập nhật!')),
                        );
                      } else {
                        // Nếu chưa có, tạo mới
                        await ApiService('${dotenv.env['LOCALHOST']}')
                            .createAnswer(
                                questionId, answer, userId, diseaseId);
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Câu trả lời đã được lưu!')),
                        );
                      }

                      Navigator.of(context)
                          .pop(); // Đóng dialog sau khi hoàn tất
                    } catch (e) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text('Lỗi khi xử lý câu trả lời: $e')),
                      );
                    }
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Vui lòng nhập câu trả lời.')),
                    );
                  }
                },
              ),
            ],
          );
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Lỗi khi kiểm tra câu trả lời: $e')),
      );
    }
  }
}
