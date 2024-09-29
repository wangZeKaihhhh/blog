# 基础镜像
FROM node:18-alpine AS base

# 设置工作目录
WORKDIR /app

# 复制 package.json 和锁文件
COPY package.json yarn.lock ./

# 安装依赖
RUN yarn install --frozen-lockfile

# 构建应用
FROM base AS builder
COPY . .

# 构建 Next.js 应用
RUN yarn build

# 生产环境镜像
FROM node:18-alpine AS runner

# 设置工作目录
WORKDIR /app

# 设置环境变量
ENV NODE_ENV=production

# 创建用户和组
RUN addgroup -g 1001 -S nextjs && adduser -S nextjs -u 1001

# 复制构建输出
COPY --from=builder /app/.next/standalone ./ 
COPY --from=builder /app/public ./public 
COPY --from=builder /app/package.json ./ 

# 确保文件权限
RUN chown -R nextjs:nextjs ./

# 切换用户
USER nextjs

# 暴露端口
EXPOSE 3000

# 启动应用
CMD ["node", "server.js"]
