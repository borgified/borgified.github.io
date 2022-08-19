using https://grokdebug.herokuapp.com/ to test

if you want to match everything but the last 2 groups

```
dev02-istio-proxy-sch-metering-f6bf4465f-mkxv7
```

use this:


```
(?<index_name>(\w+\-?)+)-(\w+\-\w+$)
```

and you get

```
{
  "index_name": [
    [
      "dev02-istio-proxy-sch-metering"
    ]
  ]
}
```


the reason why this works is because you can actually match things outside of these parentheses:

```
(?<index_name> ... )
```


so the extra bits:

```
-(\w+\-\w+$)
```

is gonna match the last 2 groups and the rest of the stuff what we want is matched by the remaining regex
