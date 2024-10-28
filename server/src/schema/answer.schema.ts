import { Prop, Schema, SchemaFactory } from '@nestjs/mongoose';
import { Document, Types } from 'mongoose';
import { User } from './user.schema';
import { Disease } from './disease.schema';

export type AnswerDocument = Answer & Document;

@Schema()
export class Answer{
   @Prop({type: Types.ObjectId, ref: 'User', required: true})
   userID: Types.ObjectId;

   @Prop({ type: Types.ObjectId, ref: 'Disease', required: true })
   diseaseID: Types.ObjectId; 

   @Prop({ required: true })
   questionID: string;

   @Prop({ required: true })
   answer: string;

   // @Prop({ type: Date, default: Date.now })
   // createdAt: Date;
}

export const AnswerSchema = SchemaFactory.createForClass(Answer);