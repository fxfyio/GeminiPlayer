# 报错 GNU assembler not found, install/update gas-preprocessor

1、安装 gas-preprocessor

```
curl -L https://github.com/libav/gas-preprocessor/raw/master/gas-preprocessor.pl -o gas-preprocessor.pl
chmod +x gas-preprocessor.pl
sudo mv gas-preprocessor.pl /usr/local/bin/
```

2、运行 ./gas-preprocessor.pl 报错

> Unescaped left brace in regex is deprecated here (and will be fatal in Perl 5.32), passed through in regex; marked by <-- HERE in m/(?:ld|st)\d\s+({ <-- HERE \s*v(\d+)\.(\d[bhsdBHSD])\s*-\s*v(\d+)\.(\d[bhsdBHSD])\s*})/ at /usr/local/bin/gas-preprocessor.pl line 1066.
> Unrecognized input filetype at /usr/local/bin/gas-preprocessor.pl line 100.

解决方法:

这个错误提示出现是由于 gas-preprocessor.pl 脚本与您系统上安装的 Perl 版本有兼容性问题。从 Perl 5.26 开始，正则表达式中的左大括号 "{" 必须要转义。

打开文件找到 1066 行,修改为

```
if ($line =~ /(?:ld|st)\d\s+(\{\s*v(\d+)\.(\d[bhsdBHSD])\s*-\s*v(\d+)\.(\d[bhsdBHSD])\s*})/) {
```
