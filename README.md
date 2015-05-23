輔仁課程爬蟲
=========

## Endpoints

1.
```
    GET /courses.json
```
本來想弄 Course API 端點兒，不過因為 worker dyno / web dyno 不互通，要在串 s3 之類的 file server，就先 pending 惹。


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
強制重跑 task，預設間隔為兩小時
