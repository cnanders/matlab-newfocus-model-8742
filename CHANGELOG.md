## 1.0.1

- Now uses `tcpclient` instead of `tcpip`
  - No longer requires the Instrument Control Toolbox
  - `tcpclient` requires MATLAB >= 2014b
- Fixed bug where `fprintf` was being used to prepare query commands instead of `sprintf` (most methods did not work because of this but)


## 1.0.0

- Initial untested commit.