輔仁課程爬蟲
=========

## Endpoints

1.
```
    GET /courses.json
```
用 redis 存


2.
```
    GET /sidekiq
```
sidekiq 的 web monitor

3.
```
    GET /?key=api_key_here
```
讓他開始跑 task

4.
```
    GET/force?key=api_key_here
```
強制重跑 task，<del>預設間隔為兩小時</del>(還沒弄)
