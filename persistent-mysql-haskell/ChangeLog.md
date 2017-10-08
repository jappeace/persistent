## 0.3.4
- Port from `mysql-haskell`: Extend the `SomeField` type to allow `insertManyOnDuplicateKeyUpdate` to conditionally copy values [#693](https://github.com/yesodweb/persistent/pull/693).

## 0.3.3
- Port from `mysql-haskell`: MySQL on duplicate key update [#674](https://github.com/yesodweb/persistent/pull/674).

## 0.3.2.1
- Port from `mysql-haskell`: Prevent spurious no-op migrations when `default=NULL` is specified - revised version [#672](https://github.com/yesodweb/persistent/pull/672) (which fixes bug [#671](https://github.com/yesodweb/persistent/issues/671) introduced by the earlier attempt [#641](https://github.com/yesodweb/persistent/pull/641)).

## 0.3.2.0
- Added conditional declaration of `Show` instance for mysql-haskell's `ConnectInfo` for compatibility with `mysql-haskell-0.8.1.0+`.

## 0.3.1.0
- Fixed compiler warnings in `stack --pedantic` mode so the project can run upstream tests on Travis.
- Minor README enhancements for badges and fixed URL for example when viewing outside of Github.

## 0.3.0.0
- Added API for setting [TLS client parameters](https://hackage.haskell.org/package/mysql-haskell-0.8.0.0/docs/Database-MySQL-TLS.html) for secure MySQL connections.
- Exported [Data.TLSSetting](https://hackage.haskell.org/package/tcp-streams-1.0.0.0/docs/Data-TLSSetting.html) for convenient usage of TLS.

## 0.2.1.0
- Bumped up version to update README.

## 0.2.0.0
- Added APIs for setting port number and character encoding.
- Updated type signature for mkMySQLConnectInfo to align with mysql-haskell.

## 0.1.1.0
- Bumped up version to include README and example.

## 0.1.0.0

* Ported persistent-mysql 2.6 to use mysql-haskell as the underlying database driver.
* Deprecated MySQLConf and ConnectInfo native constructor and default instance in favor of mk functions for better forward compatibility. See http://www.snoyman.com/blog/2016/11/designing-apis-for-extensibility.