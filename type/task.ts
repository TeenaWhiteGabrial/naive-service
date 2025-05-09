import { ObjectId } from 'mongodb';

// 新增任务类型（无ID)
export type addTypeTask = {
    type?: taskTypeEnum, // 任务类型：工作任务0、生活任务1、未来任务2
    deadLine?: string, // 截止时间
    content?: string, // 任务内容
    state?: stateEnum, // 任务状态
    notes?: string // 随笔记
}
// 定义任务类型
export interface typeTask {
    _id?: ObjectId | string; // 支持两种类型
    type?: taskTypeEnum; // 任务类型：工作任务0、生活任务1、未来任务2
    deadLine?: string; // 截止时间
    content?: string; // 任务内容
    state?: stateEnum; // 任务状态
    notes?: string // 随笔记
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
    type?: taskTypeEnum,
    deadLine?: string,
    state?: Array<stateEnum>
}