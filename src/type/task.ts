// 新增任务类型（无ID)
type addTypeTask = {
    type?: taskTypeEnum, // 任务类型：工作任务0、生活任务1、未来任务2
    deadLine?: String, // 截止时间
    content?: String, // 任务内容
    state?: stateEnum, // 任务状态
    notes?: String // 随笔记
}

// 定义任务类型
type typeTask = {
    _id: String, // 任务ID,主键
    type?: taskTypeEnum, // 任务类型：工作任务0、生活任务1、未来任务2
    deadLine?: String, // 截止时间
    content?: String, // 任务内容
    state?: stateEnum, // 任务状态
    notes?: String // 随笔记
}

enum taskTypeEnum { // 枚举任务的类型
    WORK = '0',
    LIFE = '1',
    FEATURE = '2'
}

enum stateEnum { // 枚举状态
    UNSTARTED = '0',
    ONGOING = '1',
    FINISHED = '2',
}

type paramType = { // 查询参数类型
    type?: taskTypeEnum,
    deadLine?: String,
    state?: stateEnum
}