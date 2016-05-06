# light_server
TLDR:
Sinatra server connected to raspberry pi w/ LED strip. Listens to json requests.

new json request format:


<em>custom</em>

```
{
    "setup": {
        "mode": "custom",
        "clear": true
    },
    "colors": [
        {
            "red": 123,
            "green": 127,
            "blue": 127
        },
        {
            "red": 123,
            "green": 127,
            "blue": 127
        }
    ]
}
```

note: custom must have total # of colors equal to # of lights

<em>fill</em>
```
{
    "setup": {
        "mode": "fill"
    },
    "color": {
            "red": 123,
            "green": 127,
            "blue": 127
    }
}
```
