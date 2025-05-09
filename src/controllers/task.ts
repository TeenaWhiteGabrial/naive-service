import { Context, Next } from "koa"
import TaskService from '../services/task'

class TaskController {
    private service: TaskService = new TaskService()
    /**
     * 新增任务
     * @param ctx
     * @param next
     * @returns
     */
    addTask = async (ctx: Context, next: Next) => {
        const res = await this.service.addTask(ctx.userId, ctx.request.body)
        ctx.body = res
        return next()
    }
    /** 
     * 修改任务
     * @param ctx
     * @param next
     * @returns
     */
    changeTask = async (ctx: Context, next: Next) => {
        const res = await this.service.changeTask(ctx.userId, ctx.request.body)
        ctx.body = res
        return next()
    }
    /**
     * 查询任务列表
     * @param ctx
     * @param next
     * @returns
     */
    getTaskList = async (ctx: Context, next: Next) => {
        const res = await this.service.getTaskList(ctx.userId, ctx.request.body)
        ctx.body = res
        return next()
    }
    /**
     * 查询任务详情
     * @param ctx
     * @param next
     * @returns
     */
    getTaskDetail = async (ctx: Context, next: Next) => {
        const res = await this.service.getTaskDetail(ctx.userId, ctx.request.body)
        ctx.body = res
        return next()
    }
    /**
     * 删除任务
     * @param ctx
     * @param next
     * @returns
     */
    deleteTask = async (ctx: Context, next: Next) => {
        const res = await this.service.deleteTask(ctx.userId, ctx.request.body)
        ctx.body = res
        return next()
    }
}

export default new TaskController();