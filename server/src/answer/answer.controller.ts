import { Controller, Post, Get, Param, Body, Query } from '@nestjs/common';
import { AnswerService } from './answer.service';
import { Answer } from '../schema/answer.schema';

@Controller('answer')
export class AnswerController {
  constructor(private readonly AnswerService: AnswerService) {}

  // Tạo câu trả lời mới
  @Post()
  async create(@Body() AnswerData: Answer) {
    return this.AnswerService.createAnswer(AnswerData);
  }

  // Lấy tất cả câu trả lời
  @Get()
  async getAll() {
    return this.AnswerService.getAllAnswers();
  }

  // Lấy câu trả lời dựa trên 3 ID: userId, diseaseId, questionId
  @Get('by-ids')
  async getByUserDiseaseQuestion(
    @Query('userID') userID: string,
    @Query('diseaseID') diseaseID: string,
    @Query('questionID') questionID: string,
  ) {
    return this.AnswerService.getAnswerByIds(userID, diseaseID, questionID);
  }
}
