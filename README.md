# private_gitlab_notifier

監聽私有的gitlab server的merge request 和comment，並發出系統通知。

支援Windows 及macos

## 說明

需要準備下列兩個檔案
1. [private-gitlab-notifier-dashboard](https://github.com/maple135790/private-gitlab-notifier-dashboard) build 出的`build/web`
2. .env

把以上的檔案，和`dart compile exe bin/private_gitlab_notifier.dart` 後的執行檔，放到同一個目錄底下，就可以正常工作。

需要自行新增`.env`，格式如下：
```env
domain=<private-gitlab的host。e.g. private_gl.com>
access_token=<gitlab token，需要API權限>
fetch_interval=<fetch gitlab 時間間格，預設5000(ms)>
project_id=<專案ID>
```