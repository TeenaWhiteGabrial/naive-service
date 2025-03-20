import Koa from "koa";
import http from "http";
import koaBody from "koa-body";
import koaCors from "koa-cors";
import { getIpAddress } from "./utils/util";
import { loggerMiddleware } from "./log/log";
import { FIXED_KEY } from "./config/constant";
import { routers } from "./router";
import { errorHandler, responseHandler } from "./middleware/response";

const app = new Koa();

// 跨域处理
app.use(koaCors())
// 日志中间件
app.use(loggerMiddleware);

// 错误处理
app.use(errorHandler);

// koaBody,处理请求的中间件
app.use(koaBody({ multipart: true }));

// 注册所有路由
routers.forEach(router => {
  app.use(router.routes()).use(router.allowedMethods());
});

// 请求response处理
app.use(responseHandler);

const port = FIXED_KEY.port;

const server = http.createServer(app.callback());

server.listen(port);

server.on("error", (err: Error) => {
  console.log(err);
});

server.on("listening", () => {
  const ip = getIpAddress();
  const address = `http://${ip}:${port}`;
  const localAddress = `http://localhost:${port}`;
  console.log(`app started at address \n\n${localAddress}\n\n${address}`);
});
