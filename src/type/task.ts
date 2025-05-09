import { ObjectId } from 'mongodb';

// 新增任务类型（无ID)
export type addTypeTask = {
    userId: String, // 用户ID
    type?: taskTypeEnum, // 任务类型：工作任务0、生活任务1、未来任务2
    deadLine?: String, // 截止时间
    content?: String, // 任务内容
    state?: stateEnum, // 任务状态
    notes?: String // 随笔记
}

// 定义任务类型
export type typeTask = {
    _id: ObjectId | string, // 任务ID,主键
    type?: taskTypeEnum, // 任务类型：工作任务0、生活任务1、未来任务2
    deadLine?: String, // 截止时间
    content?: String, // 任务内容
    state?: stateEnum, // 任务状态
    notes?: String // 随笔记
}

export enum taskTypeEnum { // 枚举任务的类型
    WORK = '0',
    LIFE = '1',
    STAR = '2'
}

export enum stateEnum { // 枚举状态
    UNSTARTED = '0',
    ONGOING = '1',
    FINISHED = '2',
}

export type paramType = { // 查询参数类型
    userId: String,
    type?: taskTypeEnum,
    deadLine?: String,
    state?: Array<stateEnum>
}