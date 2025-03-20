import fs from 'fs';
import path from 'path';
import Router from 'koa-router';

// 自动注册路由
const registerRouters = () => {
  const routers: Router[] = [];
  const routerPath = path.join(__dirname);
  
  // 读取当前目录下的所有文件
  const files = fs.readdirSync(routerPath);
  
  files.forEach((file) => {
    if (file !== 'index.ts' && /\.(ts|js)$/.test(file)) {
      const router = require(path.join(routerPath, file)).default;
      if (router instanceof Router) {
        routers.push(router);
      }
    }
  });
  
  return routers;
};

export const routers = registerRouters();
