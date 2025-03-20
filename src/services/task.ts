import db from '../utils/pool'
import { addTypeTask, paramType, typeTask } from "../type/task"

export default class TaskService {

    /**
     * 根据条件查询任务List
     * @param param 
     */
    async getTaskList(param: paramType) {
        const cl = db.collection('task-info');
        let query: paramType = {};

        // 根据param中的字段构建查询条件
        if (param.type) {
            query.type = param.type;
        }
        if (param.deadLine) {
            query.deadLine = param.deadLine;
        }
        if (param.state) {
            query.state = param.state;
        }

        try {
            // 执行查询并返回结果
            const taskList = await cl.find(query).project({ _id: 1, type: 1, deadLine: 1, content: 1, state: 1, notes: 1 }).toArray();
            return taskList;
        } catch (error) {
            console.error('Error fetching TaskList:', error);
            throw error;
        }
    }

    /**
     * 新增任务
     * @param task 
     * @returns 
     */
    async addTask(task: addTypeTask) {
        const cl = db.collection('task-info');
        const res = await cl.insertOne(task)
        return '新增成功'
    }

    /**
     * 修改任务
     */
    async changeTask(task: typeTask) {
        const { _id } = task
        const cl = db.collection('task-info');
        // 根据ID查询出指定的task，根据task里面的内容修改对应的字段
        const res = await cl.updateOne({ _id }, { $set: task })
        if (!res.acknowledged) {
            throw `更新失败,查询到${res.matchedCount}条匹配数据`
        } else if (res.modifiedCount === 0) {
            throw `更新失败,没有符合条件的数据`
        } else {
            return `更新成功,共影响${res.modifiedCount}条数据`
        }
    }

    /**
     * 删除任务
     * @param _id
     * @returns
     */
    async deleteTask(_id: String) {
        const cl = db.collection('task-info');
        const res = await cl.deleteOne({
            _id
        })
        if (res.acknowledged && res.deletedCount > 0) {
            return '删除成功'
        } else {
            throw `删除失败`
        }
    }

    /**
     * 根据ID查询任务详情
     * @param _id
     * @returns
     */
    async getTaskDetail(_id: String) {
        const cl = db.collection('task-info');
        try {
            const task = await cl.findOne({ _id });
            if (!task) {
                throw '未找到该任务';
            }
            return task;
        } catch (error) {
            console.error('Error fetching task detail:', error);
            throw error;
        }
    }
}