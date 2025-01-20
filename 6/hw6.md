### Локальная установка ClickHouse 

Проверяем поддержку используемого процессора
```
# grep -q sse4_2 /proc/cpuinfo && echo "SSE 4.2 supported" || echo "SSE 4.2 not supported"
SSE 4.2 supported
```

Установим CH на машинку
```sh
sudo apt-get install -y apt-transport-https ca-certificates curl gnupg
curl -fsSL 'https://packages.clickhouse.com/rpm/lts/repodata/repomd.xml.key' | sudo gpg --dearmor -o /usr/share/keyrings/clickhouse-keyring.gpg

echo "deb [signed-by=/usr/share/keyrings/clickhouse-keyring.gpg] https://packages.clickhouse.com/deb stable main" | sudo tee \
    /etc/apt/sources.list.d/clickhouse.list
sudo apt-get update

```
Установка ClickHouse server и client
```sh
sudo apt-get install -y clickhouse-server clickhouse-client

Reading package lists... Done
Building dependency tree... Done
Reading state information... Done
The following additional packages will be installed:
  clickhouse-common-static
Suggested packages:
  clickhouse-common-static-dbg
The following NEW packages will be installed:
  clickhouse-client clickhouse-common-static clickhouse-server
0 upgraded, 3 newly installed, 0 to remove and 178 not upgraded.
Need to get 153 MB of archives.
After this operation, 546 MB of additional disk space will be used.
Get:1 https://packages.clickhouse.com/deb stable/main amd64 clickhouse-common-static amd64 24.12.3.47 [153 MB]
Get:2 https://packages.clickhouse.com/deb stable/main amd64 clickhouse-client amd64 24.12.3.47 [127 kB]
Get:3 https://packages.clickhouse.com/deb stable/main amd64 clickhouse-server amd64 24.12.3.47 [155 kB]
Fetched 153 MB in 3s (50.5 MB/s)
Selecting previously unselected package clickhouse-common-static.
(Reading database ... 65188 files and directories currently installed.)
Preparing to unpack .../clickhouse-common-static_24.12.3.47_amd64.deb ...
Unpacking clickhouse-common-static (24.12.3.47) ...
Selecting previously unselected package clickhouse-client.
Preparing to unpack .../clickhouse-client_24.12.3.47_amd64.deb ...
Unpacking clickhouse-client (24.12.3.47) ...
Selecting previously unselected package clickhouse-server.
Preparing to unpack .../clickhouse-server_24.12.3.47_amd64.deb ...
Unpacking clickhouse-server (24.12.3.47) ...
Setting up clickhouse-common-static (24.12.3.47) ...
Setting up clickhouse-server (24.12.3.47) ...
ClickHouse binary is already located at /usr/bin/clickhouse
Symlink /usr/bin/clickhouse-server already exists but it points to /clickhouse. Will replace the old symlink to /usr/bin/clickhouse.
Creating symlink /usr/bin/clickhouse-server to /usr/bin/clickhouse.
Symlink /usr/bin/clickhouse-client already exists but it points to /clickhouse. Will replace the old symlink to /usr/bin/clickhouse.
Creating symlink /usr/bin/clickhouse-client to /usr/bin/clickhouse.
Symlink /usr/bin/clickhouse-local already exists but it points to /clickhouse. Will replace the old symlink to /usr/bin/clickhouse.
Creating symlink /usr/bin/clickhouse-local to /usr/bin/clickhouse.
Symlink /usr/bin/clickhouse-benchmark already exists but it points to /clickhouse. Will replace the old symlink to /usr/bin/clickhouse.
Creating symlink /usr/bin/clickhouse-benchmark to /usr/bin/clickhouse.
Symlink /usr/bin/clickhouse-obfuscator already exists but it points to /clickhouse. Will replace the old symlink to /usr/bin/clickhouse.
Creating symlink /usr/bin/clickhouse-obfuscator to /usr/bin/clickhouse.
Creating symlink /usr/bin/clickhouse-git-import to /usr/bin/clickhouse.
Symlink /usr/bin/clickhouse-compressor already exists but it points to /clickhouse. Will replace the old symlink to /usr/bin/clickhouse.
Creating symlink /usr/bin/clickhouse-compressor to /usr/bin/clickhouse.
Symlink /usr/bin/clickhouse-format already exists but it points to /clickhouse. Will replace the old symlink to /usr/bin/clickhouse.
Creating symlink /usr/bin/clickhouse-format to /usr/bin/clickhouse.
Symlink /usr/bin/clickhouse-extract-from-config already exists but it points to /clickhouse. Will replace the old symlink to /usr/bin/clickhouse.
Creating symlink /usr/bin/clickhouse-extract-from-config to /usr/bin/clickhouse.
Symlink /usr/bin/clickhouse-keeper already exists but it points to /clickhouse. Will replace the old symlink to /usr/bin/clickhouse.
Creating symlink /usr/bin/clickhouse-keeper to /usr/bin/clickhouse.
Symlink /usr/bin/clickhouse-keeper-converter already exists but it points to /clickhouse. Will replace the old symlink to /usr/bin/clickhouse.
Creating symlink /usr/bin/clickhouse-keeper-converter to /usr/bin/clickhouse.
Creating symlink /usr/bin/clickhouse-disks to /usr/bin/clickhouse.
Symlink /usr/bin/ch already exists. Will keep it.
Symlink /usr/bin/chl already exists. Will keep it.
Symlink /usr/bin/chc already exists. Will keep it.
Creating clickhouse group if it does not exist.
 groupadd -r clickhouse
Creating clickhouse user if it does not exist.
 useradd -r --shell /bin/false --home-dir /nonexistent -g clickhouse clickhouse
Will set ulimits for clickhouse user in /etc/security/limits.d/clickhouse.conf.
Creating config directory /etc/clickhouse-server/config.d that is used for tweaks of main server configuration.
Creating config directory /etc/clickhouse-server/users.d that is used for tweaks of users configuration.
Config file /etc/clickhouse-server/config.xml already exists, will keep it and extract path info from it.
/etc/clickhouse-server/config.xml has /var/lib/clickhouse/ as data path.
/etc/clickhouse-server/config.xml has /var/log/clickhouse-server/ as log path.
Users config file /etc/clickhouse-server/users.xml already exists, will keep it and extract users info from it.
Creating log directory /var/log/clickhouse-server/.
Creating data directory /var/lib/clickhouse/.
Creating pid directory /var/run/clickhouse-server.
 chown -R clickhouse:clickhouse '/var/log/clickhouse-server/'
 chown -R clickhouse:clickhouse '/var/run/clickhouse-server'
 chown  clickhouse:clickhouse '/var/lib/clickhouse/'
Enter password for the default user:
Password for the default user is saved in file /etc/clickhouse-server/users.d/default-password.xml.
Setting capabilities for clickhouse binary. This is optional.
 chown -R clickhouse:clickhouse '/etc/clickhouse-server'

ClickHouse has been successfully installed.

Start clickhouse-server with:
 sudo clickhouse start

Start clickhouse-client with:
 clickhouse-client --password

Synchronizing state of clickhouse-server.service with SysV service script with /lib/systemd/systemd-sysv-install.
Executing: /lib/systemd/systemd-sysv-install enable clickhouse-server
Created symlink /etc/systemd/system/multi-user.target.wants/clickhouse-server.service → /lib/systemd/system/clickhouse-server.service.
Setting up clickhouse-client (24.12.3.47) ...
Scanning processes...
Scanning linux images...

Running kernel seems to be up-to-date.
No services need to be restarted.
No containers need to be restarted.
No user sessions are running outdated binaries.
No VM guests are running outdated hypervisor (qemu) binaries on this host.
```
Задали пароль на этом шаге ch_2412347

Стартуем сервер, проверяем вход, используя пароль
```sh
systemctl status clickhouse-server.service
sudo service clickhouse-server start
clickhouse-client --password
```
Загрузка и извлечение тестовых табличных данных 
```sh
curl https://datasets.clickhouse.com/hits/tsv/hits_v1.tsv.xz | unxz --threads=`nproc` > hits_v1.tsv
curl https://datasets.clickhouse.com/visits/tsv/visits_v1.tsv.xz | unxz --threads=`nproc` > visits_v1.tsv
```

Создание БД
```sh
clickhouse-client --query "CREATE DATABASE IF NOT EXISTS test" --password='ch_2412347'

#Посмотрим, какие есть базы

clickhouse-client --query='show databases;' --password='ch_2412347'
INFORMATION_SCHEMA
default
information_schema
system
test
```

Создание таблиц
```sh
#clickhouse-client --password='ch_2412347'

CREATE TABLE test.hits_v1
(
    `WatchID` UInt64,
    `JavaEnable` UInt8,
    `Title` String,
    `GoodEvent` Int16,
    `EventTime` DateTime,
    `EventDate` Date,
    `CounterID` UInt32,
    `ClientIP` UInt32,
    `ClientIP6` FixedString(16),
    `RegionID` UInt32,
    `UserID` UInt64,
    `CounterClass` Int8,
    `OS` UInt8,
    `UserAgent` UInt8,
    `URL` String,
    `Referer` String,
    `URLDomain` String,
    `RefererDomain` String,
    `Refresh` UInt8,
    `IsRobot` UInt8,
    `RefererCategories` Array(UInt16),
    `URLCategories` Array(UInt16),
    `URLRegions` Array(UInt32),
    `RefererRegions` Array(UInt32),
    `ResolutionWidth` UInt16,
    `ResolutionHeight` UInt16,
    `ResolutionDepth` UInt8,
    `FlashMajor` UInt8,
    `FlashMinor` UInt8,
    `FlashMinor2` String,
    `NetMajor` UInt8,
    `NetMinor` UInt8,
    `UserAgentMajor` UInt16,
    `UserAgentMinor` FixedString(2),
    `CookieEnable` UInt8,
    `JavascriptEnable` UInt8,
    `IsMobile` UInt8,
    `MobilePhone` UInt8,
    `MobilePhoneModel` String,
    `Params` String,
    `IPNetworkID` UInt32,
    `TraficSourceID` Int8,
    `SearchEngineID` UInt16,
    `SearchPhrase` String,
    `AdvEngineID` UInt8,
    `IsArtifical` UInt8,
    `WindowClientWidth` UInt16,
    `WindowClientHeight` UInt16,
    `ClientTimeZone` Int16,
    `ClientEventTime` DateTime,
    `SilverlightVersion1` UInt8,
    `SilverlightVersion2` UInt8,
    `SilverlightVersion3` UInt32,
    `SilverlightVersion4` UInt16,
    `PageCharset` String,
    `CodeVersion` UInt32,
    `IsLink` UInt8,
    `IsDownload` UInt8,
    `IsNotBounce` UInt8,
    `FUniqID` UInt64,
    `HID` UInt32,
    `IsOldCounter` UInt8,
    `IsEvent` UInt8,
    `IsParameter` UInt8,
    `DontCountHits` UInt8,
    `WithHash` UInt8,
    `HitColor` FixedString(1),
    `UTCEventTime` DateTime,
    `Age` UInt8,
    `Sex` UInt8,
    `Income` UInt8,
    `Interests` UInt16,
    `Robotness` UInt8,
    `GeneralInterests` Array(UInt16),
    `RemoteIP` UInt32,
    `RemoteIP6` FixedString(16),
    `WindowName` Int32,
    `OpenerName` Int32,
    `HistoryLength` Int16,
    `BrowserLanguage` FixedString(2),
    `BrowserCountry` FixedString(2),
    `SocialNetwork` String,
    `SocialAction` String,
    `HTTPError` UInt16,
    `SendTiming` Int32,
    `DNSTiming` Int32,
    `ConnectTiming` Int32,
    `ResponseStartTiming` Int32,
    `ResponseEndTiming` Int32,
    `FetchTiming` Int32,
    `RedirectTiming` Int32,
    `DOMInteractiveTiming` Int32,
    `DOMContentLoadedTiming` Int32,
    `DOMCompleteTiming` Int32,
    `LoadEventStartTiming` Int32,
    `LoadEventEndTiming` Int32,
    `NSToDOMContentLoadedTiming` Int32,
    `FirstPaintTiming` Int32,
    `RedirectCount` Int8,
    `SocialSourceNetworkID` UInt8,
    `SocialSourcePage` String,
    `ParamPrice` Int64,
    `ParamOrderID` String,
    `ParamCurrency` FixedString(3),
    `ParamCurrencyID` UInt16,
    `GoalsReached` Array(UInt32),
    `OpenstatServiceName` String,
    `OpenstatCampaignID` String,
    `OpenstatAdID` String,
    `OpenstatSourceID` String,
    `UTMSource` String,
    `UTMMedium` String,
    `UTMCampaign` String,
    `UTMContent` String,
    `UTMTerm` String,
    `FromTag` String,
    `HasGCLID` UInt8,
    `RefererHash` UInt64,
    `URLHash` UInt64,
    `CLID` UInt32,
    `YCLID` UInt64,
    `ShareService` String,
    `ShareURL` String,
    `ShareTitle` String,
    `ParsedParams` Nested(
        Key1 String,
        Key2 String,
        Key3 String,
        Key4 String,
        Key5 String,
        ValueDouble Float64),
    `IslandID` FixedString(16),
    `RequestNum` UInt32,
    `RequestTry` UInt8
)
ENGINE = MergeTree()
PARTITION BY toYYYYMM(EventDate)
ORDER BY (CounterID, EventDate, intHash32(UserID))
SAMPLE BY intHash32(UserID)
...
Query id: c5ca4e67-b626-477d-9eb7-52bdd4094550
Ok.
0 rows in set. Elapsed: 0.015 sec.


CREATE TABLE test.visits_v1
(
    `CounterID` UInt32,
    `StartDate` Date,
    `Sign` Int8,
    `IsNew` UInt8,
    `VisitID` UInt64,
    `UserID` UInt64,
    `StartTime` DateTime,
    `Duration` UInt32,
    `UTCStartTime` DateTime,
    `PageViews` Int32,
    `Hits` Int32,
    `IsBounce` UInt8,
    `Referer` String,
    `StartURL` String,
    `RefererDomain` String,
    `StartURLDomain` String,
    `EndURL` String,
    `LinkURL` String,
    `IsDownload` UInt8,
    `TraficSourceID` Int8,
    `SearchEngineID` UInt16,
    `SearchPhrase` String,
    `AdvEngineID` UInt8,
    `PlaceID` Int32,
    `RefererCategories` Array(UInt16),
    `URLCategories` Array(UInt16),
    `URLRegions` Array(UInt32),
    `RefererRegions` Array(UInt32),
    `IsYandex` UInt8,
    `GoalReachesDepth` Int32,
    `GoalReachesURL` Int32,
    `GoalReachesAny` Int32,
    `SocialSourceNetworkID` UInt8,
    `SocialSourcePage` String,
    `MobilePhoneModel` String,
    `ClientEventTime` DateTime,
    `RegionID` UInt32,
    `ClientIP` UInt32,
    `ClientIP6` FixedString(16),
    `RemoteIP` UInt32,
    `RemoteIP6` FixedString(16),
    `IPNetworkID` UInt32,
    `SilverlightVersion3` UInt32,
    `CodeVersion` UInt32,
    `ResolutionWidth` UInt16,
    `ResolutionHeight` UInt16,
    `UserAgentMajor` UInt16,
    `UserAgentMinor` UInt16,
    `WindowClientWidth` UInt16,
    `WindowClientHeight` UInt16,
    `SilverlightVersion2` UInt8,
    `SilverlightVersion4` UInt16,
    `FlashVersion3` UInt16,
    `FlashVersion4` UInt16,
    `ClientTimeZone` Int16,
    `OS` UInt8,
    `UserAgent` UInt8,
    `ResolutionDepth` UInt8,
    `FlashMajor` UInt8,
    `FlashMinor` UInt8,
    `NetMajor` UInt8,
    `NetMinor` UInt8,
    `MobilePhone` UInt8,
    `SilverlightVersion1` UInt8,
    `Age` UInt8,
    `Sex` UInt8,
    `Income` UInt8,
    `JavaEnable` UInt8,
    `CookieEnable` UInt8,
    `JavascriptEnable` UInt8,
    `IsMobile` UInt8,
    `BrowserLanguage` UInt16,
    `BrowserCountry` UInt16,
    `Interests` UInt16,
    `Robotness` UInt8,
    `GeneralInterests` Array(UInt16),
    `Params` Array(String),
    `Goals` Nested(
        ID UInt32,
        Serial UInt32,
        EventTime DateTime,
        Price Int64,
        OrderID String,
        CurrencyID UInt32),
    `WatchIDs` Array(UInt64),
    `ParamSumPrice` Int64,
    `ParamCurrency` FixedString(3),
    `ParamCurrencyID` UInt16,
    `ClickLogID` UInt64,
    `ClickEventID` Int32,
    `ClickGoodEvent` Int32,
    `ClickEventTime` DateTime,
    `ClickPriorityID` Int32,
    `ClickPhraseID` Int32,
    `ClickPageID` Int32,
    `ClickPlaceID` Int32,
    `ClickTypeID` Int32,
    `ClickResourceID` Int32,
    `ClickCost` UInt32,
    `ClickClientIP` UInt32,
    `ClickDomainID` UInt32,
    `ClickURL` String,
    `ClickAttempt` UInt8,
    `ClickOrderID` UInt32,
    `ClickBannerID` UInt32,
    `ClickMarketCategoryID` UInt32,
    `ClickMarketPP` UInt32,
    `ClickMarketCategoryName` String,
    `ClickMarketPPName` String,
    `ClickAWAPSCampaignName` String,
    `ClickPageName` String,
    `ClickTargetType` UInt16,
    `ClickTargetPhraseID` UInt64,
    `ClickContextType` UInt8,
    `ClickSelectType` Int8,
    `ClickOptions` String,
    `ClickGroupBannerID` Int32,
    `OpenstatServiceName` String,
    `OpenstatCampaignID` String,
    `OpenstatAdID` String,
    `OpenstatSourceID` String,
    `UTMSource` String,
    `UTMMedium` String,
    `UTMCampaign` String,
    `UTMContent` String,
    `UTMTerm` String,
    `FromTag` String,
    `HasGCLID` UInt8,
    `FirstVisit` DateTime,
    `PredLastVisit` Date,
    `LastVisit` Date,
    `TotalVisits` UInt32,
    `TraficSource` Nested(
        ID Int8,
        SearchEngineID UInt16,
        AdvEngineID UInt8,
        PlaceID UInt16,
        SocialSourceNetworkID UInt8,
        Domain String,
        SearchPhrase String,
        SocialSourcePage String),
    `Attendance` FixedString(16),
    `CLID` UInt32,
    `YCLID` UInt64,
    `NormalizedRefererHash` UInt64,
    `SearchPhraseHash` UInt64,
    `RefererDomainHash` UInt64,
    `NormalizedStartURLHash` UInt64,
    `StartURLDomainHash` UInt64,
    `NormalizedEndURLHash` UInt64,
    `TopLevelDomain` UInt64,
    `URLScheme` UInt64,
    `OpenstatServiceNameHash` UInt64,
    `OpenstatCampaignIDHash` UInt64,
    `OpenstatAdIDHash` UInt64,
    `OpenstatSourceIDHash` UInt64,
    `UTMSourceHash` UInt64,
    `UTMMediumHash` UInt64,
    `UTMCampaignHash` UInt64,
    `UTMContentHash` UInt64,
    `UTMTermHash` UInt64,
    `FromHash` UInt64,
    `WebVisorEnabled` UInt8,
    `WebVisorActivity` UInt32,
    `ParsedParams` Nested(
        Key1 String,
        Key2 String,
        Key3 String,
        Key4 String,
        Key5 String,
        ValueDouble Float64),
    `Market` Nested(
        Type UInt8,
        GoalID UInt32,
        OrderID String,
        OrderPrice Int64,
        PP UInt32,
        DirectPlaceID UInt32,
        DirectOrderID UInt32,
        DirectBannerID UInt32,
        GoodID String,
        GoodName String,
        GoodQuantity Int32,
        GoodPrice Int64),
    `IslandID` FixedString(16)
)
ENGINE = CollapsingMergeTree(Sign)
PARTITION BY toYYYYMM(StartDate)
ORDER BY (CounterID, StartDate, intHash32(UserID), VisitID)
SAMPLE BY intHash32(UserID)
...
Query id: 4296f51d-e336-4e90-921e-50acc79e891e
Ok.
0 rows in set. Elapsed: 0.021 sec.

```

Импорт данных
```
clickhouse-client --query "INSERT INTO test.hits_v1 FORMAT TSV" --max_insert_block_size=100000 --password='ch_2412347' < hits_v1.tsv
clickhouse-client --query "INSERT INTO test.visits_v1 FORMAT TSV" --max_insert_block_size=100000 --password='ch_2412347' < visits_v1.tsv
```

Посмотрим сколько занимаются места все таблицы, и количество записей в загруженных табличках
```sh
SELECT
    database,
    `table`,
    formatReadableSize(sum(bytes_on_disk)) AS sum_bytes
FROM system.parts
GROUP BY
    database,
    `table`
ORDER BY sum(bytes_on_disk) DESC

Query id: b000d6c0-98a8-4ce8-915c-0b729a4cd6d9

    ┌─database─┬─table───────────────────┬─sum_bytes──┐
 1. │ test     │ hits_v1                 │ 2.38 GiB   │
 2. │ test     │ visits_v1               │ 858.17 MiB │
 3. │ system   │ metric_log              │ 21.26 MiB  │
 4. │ system   │ text_log                │ 12.60 MiB  │
 5. │ system   │ asynchronous_metric_log │ 5.82 MiB   │
 6. │ system   │ query_metric_log        │ 1.36 MiB   │
 7. │ system   │ trace_log               │ 1.34 MiB   │
 8. │ system   │ query_log               │ 136.38 KiB │
 9. │ system   │ processors_profile_log  │ 66.09 KiB  │
10. │ system   │ part_log                │ 63.22 KiB  │
11. │ system   │ error_log               │ 1.84 KiB   │
    └──────────┴─────────────────────────┴────────────┘
11 rows in set. Elapsed: 0.007 sec.


SELECT COUNT(*)
FROM test.hits_v1

Query id: b5808db4-f95d-41c9-aa43-dd20192751a1

   ┌─COUNT()─┐
1. │ 8873898 │ -- 8.87 million
   └─────────┘
1 row in set. Elapsed: 0.003 sec.


SELECT COUNT(*)
FROM test.visits_v1

Query id: 848b01d9-2ea3-41b4-b38d-b8b421262673

   ┌─COUNT()─┐
1. │ 1680609 │ -- 1.68 million
   └─────────┘
1 row in set. Elapsed: 0.004 sec.
```

Посмотрим parts
```sh
SELECT
    `table`,
    partition,
    name,
    rows,
    disk_name,
    database
FROM system.parts
WHERE database = 'test'

Query id: f6a99da5-a3ff-4f23-9d4f-21952e4eb1cb

    ┌─table─────┬─partition─┬─name───────────┬────rows─┬─disk_name─┬─database─┐
 1. │ hits_v1   │ 201403    │ 201403_1_6_1   │ 1711723 │ default   │ test     │
 2. │ hits_v1   │ 201403    │ 201403_7_12_1  │ 1716411 │ default   │ test     │
 3. │ hits_v1   │ 201403    │ 201403_13_18_1 │ 1731928 │ default   │ test     │
 4. │ hits_v1   │ 201403    │ 201403_19_24_1 │ 1749150 │ default   │ test     │
 5. │ hits_v1   │ 201403    │ 201403_25_30_1 │ 1734057 │ default   │ test     │
 6. │ hits_v1   │ 201403    │ 201403_31_31_0 │  230629 │ default   │ test     │
 7. │ visits_v1 │ 201403    │ 201403_1_1_0   │  173336 │ default   │ test     │
 8. │ visits_v1 │ 201403    │ 201403_1_6_1   │ 1026707 │ default   │ test     │
 9. │ visits_v1 │ 201403    │ 201403_2_2_0   │  165649 │ default   │ test     │
10. │ visits_v1 │ 201403    │ 201403_3_3_0   │  168720 │ default   │ test     │
11. │ visits_v1 │ 201403    │ 201403_4_4_0   │  163713 │ default   │ test     │
12. │ visits_v1 │ 201403    │ 201403_5_5_0   │  183452 │ default   │ test     │
13. │ visits_v1 │ 201403    │ 201403_6_6_0   │  175017 │ default   │ test     │
14. │ visits_v1 │ 201403    │ 201403_7_7_0   │  177353 │ default   │ test     │
15. │ visits_v1 │ 201403    │ 201403_8_8_0   │  171169 │ default   │ test     │
16. │ visits_v1 │ 201403    │ 201403_9_9_0   │  177179 │ default   │ test     │
17. │ visits_v1 │ 201403    │ 201403_10_10_0 │  128201 │ default   │ test     │
    └───────────┴───────────┴────────────────┴─────────┴───────────┴──────────┘

17 rows in set. Elapsed: 0.003 sec.
```

Запустим запрос проведем оптимизацию и снова проверим тот же запрос (чуть быстрее стал выполняться)
```sh
SELECT
    StartURL AS URL,
    length(StartURL),
    AVG(Duration) AS AvgDuration
FROM test.visits_v1
WHERE (StartDate >= '2014-01-23') AND (StartDate <= '2014-03-30')
GROUP BY URL
ORDER BY AvgDuration DESC
LIMIT 10

Query id: 67513c08-5d1b-48cf-aa3a-661802962fa5

    ┌─URL────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┬─length(StartURL)─┬───────AvgDuration─┐
 1. │ http://yandex.ru/news.am/ar/catalog/natureckij_agenciya-organisland.ru/213/page=&prove/prepair-lig/6510&lr=213&noreask │              118 │ 80323.66666666667 │
 2. │ http://yandex.ru/voproki-denginekoloji/yogasharov.com%2Fincident                                                       │               64 │             70003 │
 3. │ http://e.mail.ru/article/?fromId=n-8IXWh1s3M                                                                           │               44 │             65409 │
 4. │ http://e.mail.ru/article/?fromId=90600/?ref_map={"6392068042695625a2bb38379/?fromma.tv/service.net/rus/viewer_type     │              114 │             64755 │
 5. │ http://adult.aspx&refererevogoda/ochek-item-fashini.html/ru                                                            │               59 │             57956 │
 6. │ http://npo-sovbezalka-nevrus.html#1395461-hender-klass.com/webhp                                                       │               64 │             56214 │
 7. │ http://news.mail=1&text=фильмы                                                                                         │               36 │             56161 │
 8. │ http://e.mail.ru/article/?fromId=c219e38c705fcce0                                                                      │               49 │             55171 │
 9. │ http://rbc.ru/cat_na_shtrafliz.com                                                                                     │               34 │             54091 │
10. │ http://karta/Futbol/dynami.html&lang=ru&lr=37&text=уставито сада официальный станцев                                   │              114 │             51837 │
    └────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┴──────────────────┴───────────────────┘

10 rows in set. Elapsed: 0.240 sec. Processed 1.68 million rows, 134.21 MB (7.01 million rows/s., 559.47 MB/s.)
Peak memory usage: 221.58 MiB.

OPTIMIZE TABLE test.visits_v1 FINAL

SELECT
    StartURL AS URL,
    length(StartURL),
    AVG(Duration) AS AvgDuration
FROM test.visits_v1
WHERE (StartDate >= '2014-01-23') AND (StartDate <= '2014-03-30')
GROUP BY URL
ORDER BY AvgDuration DESC
LIMIT 10

Query id: ed14f03d-2b09-4c69-95b5-01cb8d0c2e01

    ┌─URL────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┬─length(StartURL)─┬───────AvgDuration─┐
 1. │ http://yandex.ru/news.am/ar/catalog/natureckij_agenciya-organisland.ru/213/page=&prove/prepair-lig/6510&lr=213&noreask │              118 │ 80323.66666666667 │
 2. │ http://yandex.ru/voproki-denginekoloji/yogasharov.com%2Fincident                                                       │               64 │             70003 │
 3. │ http://e.mail.ru/article/?fromId=n-8IXWh1s3M                                                                           │               44 │             65409 │
 4. │ http://e.mail.ru/article/?fromId=90600/?ref_map={"6392068042695625a2bb38379/?fromma.tv/service.net/rus/viewer_type     │              114 │             64755 │
 5. │ http://adult.aspx&refererevogoda/ochek-item-fashini.html/ru                                                            │               59 │             57956 │
 6. │ http://karta/Futbol/dynamo.kiev.ua/kawaica.su/648                                                                      │               49 │             56538 │
 7. │ http://npo-sovbezalka-nevrus.html#1395461-hender-klass.com/webhp                                                       │               64 │             56214 │
 8. │ http://news.mail=1&text=фильмы                                                                                         │               36 │             56161 │
 9. │ https://moda/vyikroforum1/top.ru/moscow/delo-product/trend_sms/multitryaset/news/2014/03/201000                        │               95 │             55218 │
10. │ http://e.mail.ru/article/?fromId=c219e38c705fcce0                                                                      │               49 │             55171 │
    └────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────┴──────────────────┴───────────────────┘

10 rows in set. Elapsed: 0.188 sec. Processed 1.68 million rows, 134.00 MB (8.94 million rows/s., 714.22 MB/s.)
Peak memory usage: 221.01 MiB.
```

### YC
Для сравнения скорости исполнения запросов на сингл инстансе ClickHouse и кластерном исполнении воспользуемся инфраструктурой Яндекс облака
#### Single instance
Развернем машинку 
```sh
yc compute instance create ch-node1     --ssh-key .\.ssh\rsa_4096_cname.key.pub    --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-2204-lts,size=30     --network-interface subnet-name=default-ru-central1-d,nat-ip-version=ipv4     --memory 4G     --cores 2     --zone ru-central1-d  
```
Зайдем на неё и установим CH аналогично как выше в этой статье
```sh
yc compute ssh --id fv4k5qiucld4ie3qs4bu --identity-file .\.ssh\rsa_4096_cname.key --login yc-user
```

Скачиваем набор данных о воздушном движении OpenSky Network 2020 с сайта https://zenodo.org/records/7923702
```sh
mkdir flightlist
cd flightlist/
wget -O- https://zenodo.org/records/7923702 | grep -oP 'https://zenodo.org/records/7923702/files/flightlist_\d+_\d+\.csv\.gz' | xargs wget
...
Downloaded: 48 files, 7.6G in 2m 33s (50.9 MB/s)
```
Создадим табличку в клике
```sh
CREATE TABLE opensky
(
    callsign String,
    number String,
    icao24 String,
    registration String,
    typecode String,
    origin String,
    destination String,
    firstseen DateTime,
    lastseen DateTime,
    day DateTime,
    latitude_1 Float64,
    longitude_1 Float64,
    altitude_1 Float64,
    latitude_2 Float64,
    longitude_2 Float64,
    altitude_2 Float64
) ENGINE = MergeTree ORDER BY (origin, destination, callsign);

Query id: 8523cc20-049e-4919-84ce-b41afe458d52
Ok.
0 rows in set. Elapsed: 0.134 sec.
```

Загрузим данные, проверим количество записей
```sh
yc-user@ch-node1:~/flightlist$ for file in flightlist_*.csv.gz; do gzip -c -d "$file" | clickhouse-client --password='ch_2412347' --date_time_input_format best_effort --query "INSERT INTO opensky FORMAT CSVWithNames"; done
cd ..
yc-user@ch-node1:~$ clickhouse-client --password='ch_2412347' --query='SELECT count() FROM opensky;'
117258215
```

Узнаем размер набора данных в ClickHouse
```sh
SELECT formatReadableSize(total_bytes)
FROM system.tables
WHERE name = 'opensky'

Query id: 6056c005-200c-473f-9d24-c48a64f70772

   ┌─formatReadableSize(total_bytes)─┐
1. │ 4.66 GiB                        │
   └─────────────────────────────────┘

1 row in set. Elapsed: 0.002 sec.
```

Посмотрим на парты
```sh
SELECT
    `table`,
    partition,
    name,
    rows,
    disk_name,
    database
FROM system.parts
WHERE database = 'default'

Query id: 9832a2c9-c4b5-42fb-ab13-ddf827daeca3

   ┌─table───┬─partition─┬─name──────────┬─────rows─┬─disk_name─┬─database─┐
1. │ opensky │ tuple()   │ all_1_33_2    │ 29491460 │ default   │ default  │
2. │ opensky │ tuple()   │ all_34_65_2   │ 28677568 │ default   │ default  │
3. │ opensky │ tuple()   │ all_66_96_2   │ 26597809 │ default   │ default  │
4. │ opensky │ tuple()   │ all_97_129_2  │ 30889022 │ default   │ default  │
5. │ opensky │ tuple()   │ all_130_130_0 │  1066970 │ default   │ default  │
6. │ opensky │ tuple()   │ all_131_131_0 │   535386 │ default   │ default  │
   └─────────┴───────────┴───────────────┴──────────┴───────────┴──────────┘

6 rows in set. Elapsed: 0.002 sec.
```

Пример довольно долгого запроса. Подсчитаем общее пройденное расстояние на всех данных, что сейчас есть в базе. Оно составляет почти 120 миллиардов километров. 
```sh
SELECT formatReadableQuantity(sum(geoDistance(longitude_1, latitude_1, longitude_2, latitude_2)) / 1000) FROM opensky

Query id: 604539ef-b3a6-4c93-b671-c85a8f10c387

   ┌─formatReadableQuantity(divide(sum(geoDistance(longitude_1, latitude_1, longitude_2, latitude_2)), 1000))─┐
1. │ 119.74 billion                                                                                           │
   └──────────────────────────────────────────────────────────────────────────────────────────────────────────┘

1 row in set. Elapsed: 53.470 sec. Processed 117.26 million rows, 3.75 GB (2.19 million rows/s., 70.18 MB/s.)
Peak memory usage: 8.68 MiB.
```

Сделаем оптимизацию таблички, снова посмотрим parts, прогоним долгий запрос, теперь он выполняется быстрее

```sh
OPTIMIZE TABLE opensky FINAL

Query id: c46095ad-71f7-4bb8-a104-748c86bb4285

Ok.

0 rows in set. Elapsed: 274.039 sec.

SELECT
    `table`,
    partition,
    name,
    rows,
    disk_name,
    database
FROM system.parts
WHERE database = 'default'

Query id: e45c63ce-e599-4024-89c8-ad3d9e8f77bd

   ┌─table───┬─partition─┬─name──────────┬──────rows─┬─disk_name─┬─database─┐
1. │ opensky │ tuple()   │ all_1_33_2    │  29491460 │ default   │ default  │
2. │ opensky │ tuple()   │ all_1_131_3   │ 117258215 │ default   │ default  │
3. │ opensky │ tuple()   │ all_34_65_2   │  28677568 │ default   │ default  │
4. │ opensky │ tuple()   │ all_66_96_2   │  26597809 │ default   │ default  │
5. │ opensky │ tuple()   │ all_97_129_2  │  30889022 │ default   │ default  │
6. │ opensky │ tuple()   │ all_130_130_0 │   1066970 │ default   │ default  │
7. │ opensky │ tuple()   │ all_131_131_0 │    535386 │ default   │ default  │
   └─────────┴───────────┴───────────────┴───────────┴───────────┴──────────┘

7 rows in set. Elapsed: 0.002 sec.

SELECT formatReadableQuantity(sum(geoDistance(longitude_1, latitude_1, longitude_2, latitude_2)) / 1000)
FROM opensky

Query id: c47e32c7-a8d0-497e-91b2-2399c587976a

   ┌─formatReadableQuantity(divide(sum(geoDistance(longitude_1, latitude_1, longitude_2, latitude_2)), 1000))─┐
1. │ 119.74 billion                                                                                           │
   └──────────────────────────────────────────────────────────────────────────────────────────────────────────┘

1 row in set. Elapsed: 44.401 sec. Processed 117.26 million rows, 3.75 GB (2.64 million rows/s., 84.51 MB/s.)
Peak memory usage: 11.58 MiB.
```

#### Cluster and distributed table
Теперь создадим кластер, поднимем еще две машинки в облаке
```sh
yc compute instance create ch-node2     --ssh-key .\.ssh\rsa_4096_cname.key.pub    --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-2204-lts,size=30     --network-interface subnet-name=default-ru-central1-d,nat-ip-version=ipv4     --memory 4G     --cores 2     --zone ru-central1-d     --hostname ch-node2

yc compute instance create ch-node3     --ssh-key .\.ssh\rsa_4096_cname.key.pub    --create-boot-disk image-folder-id=standard-images,image-family=ubuntu-2204-lts,size=30     --network-interface subnet-name=default-ru-central1-d,nat-ip-version=ipv4     --memory 4G     --cores 2     --zone ru-central1-d     --hostname ch-node3

yc compute instance list
+----------------------+----------+---------------+---------+-----------------+-------------+
|          ID          |   NAME   |    ZONE ID    | STATUS  |   EXTERNAL IP   | INTERNAL IP |
+----------------------+----------+---------------+---------+-----------------+-------------+
| fv49ru1b755igkc2l2hm | ch-node2 | ru-central1-d | RUNNING | 158.160.138.154 | 10.130.0.7  |
| fv4k5qiucld4ie3qs4bu | ch-node1 | ru-central1-d | RUNNING | 158.160.146.184 | 10.130.0.30 |
| fv4o6jklafiegfvu94ri | ch-node3 | ru-central1-d | RUNNING | 84.252.135.90   | 10.130.0.35 |
+----------------------+----------+---------------+---------+-----------------+-------------+

#2
yc compute ssh --id fv49ru1b755igkc2l2hm --identity-file .\.ssh\rsa_4096_cname.key --login yc-user
#3
yc compute ssh --id fv4o6jklafiegfvu94ri --identity-file .\.ssh\rsa_4096_cname.key --login yc-user
```
Внесем изменения в конфигурацию /etc/clickhouse-server/config.xml на всех нодах, сделаем три шарда
```
<listen_host>0.0.0.0</listen_host>
...
    <remote_servers>
        <default>
            <shard>
                <internal_replication>false</internal_replication>
                <replica>
                    <host>ch-node1</host>
                    <port>9000</port>
                        <user>default</user>
                        <password>ch_2412347</password>
                </replica>
            </shard>
            <shard>
            <internal_replication>false</internal_replication>
                <replica>
                    <host>ch-node2</host>
                    <port>9000</port>
                        <user>default</user>
                        <password>ch_2412347</password>
                </replica>
            </shard>
            <shard>
            <internal_replication>false</internal_replication>
                <replica>
                    <host>ch-node3</host>
                    <port>9000</port>
                        <user>default</user>
                        <password>ch_2412347</password>
                </replica>
            </shard>
        </default>
    </remote_servers>
```
Рестарнем сервисы на всех трёх нодах
```sh
sudo systemctl restart clickhouse-server.service
```

Получили топологию
```
$ clickhouse-client --password='ch_2412347' --query=' select cluster,shard_num,shard_weight,replica_num,host_name,host_address,port,is_local,user from system.clusters;'
default 1       1       1       ch-node1        127.0.1.1       9000    1       default
default 2       1       1       ch-node2        10.130.0.7      9000    0       default
default 3       1       1       ch-node3        10.130.0.35     9000    0       default
```

Создадим базу и аналогичную предыдущей локальную табличку на всех трех машинах кластера, только добавим в неё ключ шардирования, поле num
```sh
CREATE DATABASE IF NOT EXISTS test;

CREATE TABLE test.opensky
(   num   UInt32 default rand64() % 16,
    callsign String,
    number String,
    icao24 String,
    registration String,
    typecode String,
    origin String,
    destination String,
    firstseen DateTime,
    lastseen DateTime,
    day DateTime,
    latitude_1 Float64,
    longitude_1 Float64,
    altitude_1 Float64,
    latitude_2 Float64,
    longitude_2 Float64,
    altitude_2 Float64
) ENGINE = MergeTree 
PARTITION BY num
ORDER BY (origin, destination, callsign);
```
На первой машине создадим распределенную таблицу
```sh
CREATE TABLE IF NOT EXISTS test.opensky_shard as test.opensky ENGINE = Distributed('default', 'test', 'opensky', rand());
```

Заполняем её данными
```
yc-user@ch-node1:~/flightlist$ for file in flightlist_*.csv.gz; do gzip -c -d "$file" | clickhouse-client --password='ch_2412347' --date_time_input_format best_effort --query "INSERT INTO test.opensky_shard FORMAT CSVWithNames"; done
```
Ну и наконец пробуем запустить тот же запрос по вычислению общего пройденного расстрояния, он выполнился быстрее
```sh
SELECT formatReadableQuantity(sum(geoDistance(longitude_1, latitude_1, longitude_2, latitude_2)) / 1000) FROM test.opensky_shard

Query id: db0787b5-9fc6-4566-93c2-2fb69d8ffb3b

   ┌─formatReadableQuantity(divide(sum(geoDistance(longitude_1, latitude_1, longitude_2, latitude_2)), 1000))─┐
1. │ 119.74 billion                                                                                           │
   └──────────────────────────────────────────────────────────────────────────────────────────────────────────┘

1 row in set. Elapsed: 31.054 sec. Processed 117.26 million rows, 3.68 GB (3.71 million rows/s., 118.65 MB/s.)
Peak memory usage: 8.34 MiB.