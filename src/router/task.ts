import taskController from "../controllers/task";
import koaRouter from "koa-router";
import { methodType } from "../type/enum"
import { jwtMiddlewareDeal } from "../middleware/jwt";

const router = new koaRouter({
    prefix: '/spc'
});
/** 管理端，需要Token的相关接口 */
router.use(jwtMiddlewareDeal);

const routerList = [
    /** 新增任务 */
    {
        path: `/task/add`,
        method: methodType.POST,
        action: taskController.addTask,
    },
    /** 修改任务 */
    {
        path: `/task/update`,
        method: methodType.POST,
        action: taskController.changeTask,
    },
    /** 查询任务列表 */
    {
        path: `/task/list`,
        method: methodType.POST,
        action: taskController.getTaskList,
    },
    /** 查询任务详情 */
    {
        path: `/task/detail`,
        method: methodType.POST,
        action: taskController.getTaskDetail,
    },
    /** 删除任务 */
    {
        path: `/task/delete`,
        method: methodType.POST,
        action: taskController.deleteTask,
    },
]

routerList.forEach((route) => {
    router[route.method](route.path, route.action)
})

export default router;