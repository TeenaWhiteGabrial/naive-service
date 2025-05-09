import db from '../utils/pool'
import { addTypeTask, paramType, typeTask } from "../type/task"
import { CODE } from "../config/code"

// 顶部确保已导入 ObjectId
import { ObjectId } from 'mongodb';

export default class TaskService {

    /**
     * 根据条件查询任务List
     * @param param 
     */
    async getTaskList(userId: string, param: paramType) {
        const cl = db.collection('task-info');
        let query: paramType = {
            userId
        };

        // 根据param中的字段构建查询条件

        if (param.type) {
            query.type = param.type;
        }
        if (param.deadLine) {
            query.deadLine = param.deadLine;
        }
        if (param.state !== undefined) {
            if (Array.isArray(param.state)) {
                query.state = { $in: param.state } as any;
            } else {
                query.state = param.state;
            }
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
    async addTask(userId: string, task: addTypeTask) {
        try {
            const cl = db.collection('task-info');
            if (!task.content) {
                throw CODE.missingParameters;
            }
            task.userId = userId; // 添加 userId 到任务对象中

            const res = await cl.insertOne(task);

            if (!res.acknowledged) {
                throw { ...CODE.operateFail, msg: '任务创建失败' };
            }
            return '新增成功';
        } catch (error) {
            console.error('Create task error:', error);
            throw { ...CODE.buinessError, error };
        }
    }

    /**
     * 修改任务
     */
    async changeTask(userId: string, task: typeTask) {
        try {
            if (!task._id || !ObjectId.isValid(task._id)) {
                throw CODE.illegalRequest;
            }
            const objectId = new ObjectId(task._id);
            const cl = db.collection('task-info');

            // 创建更新对象时排除 _id 字段
            const { _id, ...updateData } = task;

            const res = await cl.updateOne(
                { _id: objectId },
                { $set: updateData } // 防止修改 _id
            );

            if (!res.acknowledged) {
                throw { ...CODE.operateFail, msg: `更新失败，查询到${res.matchedCount}条匹配数据` };
            }
            if (res.modifiedCount === 0) {
                throw { ...CODE.operateFail, msg: '更新失败，没有符合条件的数据' };
            }
            return '更新成功';
        } catch (error) {
            console.error('Update error:', error);
            throw { ...CODE.buinessError, error };
        }
    }

    /**
     * 删除任务
     * @param _id
     * @returns
     */
    async deleteTask(userId: string, _id: string) { // 修正 String 为 string
        const cl = db.collection('task-info');
        if (!_id) {
            throw CODE.illegalRequest;
        }
        const res = await cl.deleteOne({
            _id: new ObjectId(_id) // 添加类型转换
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
    async getTaskDetail(userId: string, _id: string) { // 修正 String 为 string
        try {
            const cl = db.collection('task-info');
            const task = await cl.findOne({
                _id: new ObjectId(_id) // 添加类型转换
            });
            return task || null;
        } catch (error) {
            console.error('Error fetching task detail:', error);
            throw { ...CODE.buinessError, error };
        }
    }
}