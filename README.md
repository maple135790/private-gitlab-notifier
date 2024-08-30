A sample command-line application with an entrypoint in `bin/`, library code
in `lib/`, and example unit test in `test/`.


監聽私有的gitlab server的merge request 和comment，並發出系統通知

開發說明：\
將`kenneth-hung/private-gitlab-notifier-dashboard`build 出的`build/web`放到本專案的根目錄下。

使用說明：\
把`dart compile *target_platform_here* -t bin/private_gitlab_notifier.dart` 後的執行檔，和`kenneth-hung/private-gitlab-notifier-dashboard`的`build/web`放到同一個目錄底下，就可以正常工作。