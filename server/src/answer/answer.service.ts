import { Injectable } from '@nestjs/common';
import { InjectModel } from '@nestjs/mongoose';
import { Model } from 'mongoose';
import { Answer, AnswerDocument } from '../schema/answer.schema';

@Injectable()
export class AnswerService {
  constructor(
    @InjectModel(Answer.name) private AnswerModel: Model<AnswerDocument>,
  ) {}

  // Tạo câu trả lời mới
  async createAnswer(AnswerData: Answer): Promise<Answer> {
    const newAnswer = new this.AnswerModel(AnswerData);
    return newAnswer.save();
  }

  // Lấy tất cả câu trả lời
  async getAllAnswers(): Promise<Answer[]> {
    return this.AnswerModel.find().exec();
  }

  // Lấy câu trả lời dựa trên userId, diseaseId và questionId
  async getAnswerByIds(
    userID: string,
    diseaseID: string,
    questionID: string,
  ): Promise<Answer | null> {
    return (await this.AnswerModel.findOne({ userID, diseaseID, questionID }).select('answer').exec());
  }

  async updateAnswer(
   userID: string,
   diseaseID: string,
   questionID: string,
   updateData: Partial<Answer>
   ): Promise<Answer | null> {
      return this.AnswerModel.findOneAndUpdate(
      { userID, diseaseID, questionID },
      updateData,
      { new: true } // Trả về tài liệu đã được cập nhật
      ).exec();
   }

   async deleteAnswer(
      userID: string,
      diseaseID: string,
      questionID: string
    ): Promise<Answer | null> {
      return this.AnswerModel.findOneAndDelete({ userID, diseaseID, questionID }).exec();
    }

    async checkAnswer(
      userID: string,
      diseaseID: string,
      questionID: string,
    ): Promise<boolean> {
      const answer = await this.AnswerModel.findOne({ userID, diseaseID, questionID }).exec();
      return !!answer; // Trả về true nếu tồn tại, false nếu không
    }
}
