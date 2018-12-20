# StockMarket

**The concept of GenStage as a way of communication between Umbrella
app.**

Using GenStage inside an Elixir Umbrella as a way of communication
between applications.

The application is based in the UK, but we have 2 counterparts in US and
Germany. They provide us with the country specific stock market info. In
return, we do the same for them. We are sending back real time UK stock
market data. Each of the 2 info providers is sending info in their
country currency. Also they must receive back information in the same
currency.

```bash
eg:
- the US data provider sends info in USD
- our app must receive it in GBP
- our app will send back info in GBP
- the US provider must receive it in USD
```

From the context above we can think about 4 applications in the
umbrella:

* `UsaMarket` - handle info from and to the US counterpart
* `GerMarket` - handle info from and to the German counterpart
* `Converter` - converts the prices between the currencies
* `MyUkApp`   - our actual stock market info app

```bash
+-------------+          +-------------+
|  UsaMarket  |          |  GerMarket  |
+------+------+          +-------+-----+
       |                         |
       |    +-------------+      |
       +---->  Converter  <------+
            +------+------+
                   |
            +------v------+
            |   MyUkApp   |
            +-------------+
```

To implement the reverse information flow we need to create more apps.
Each of them will fulfil a specific role, like a producer or a consumer
of data. The diagram below shows such a scenario:

```bash
+-------------+  +-------------+      +-------------+  +-------------+
|  UsaMarket  |  |  GerMarket  |      |  UsaMarket  |  |  GerMarket  |
|  Producer   |  |  Producer   |      |  Consumer   |  |  Consumer   |
+----------+--+  +--+----------+      +----------^--+  +--^----------+
           |        |                            |        |
         +-v--------v----------------------------+--------+-+
         |                    Converter                     |
         +------+------------------------------------^------+
                |                                    |
         +------v------+                      +------+------+
         |   MyUkApp   |                      |   MyUkApp   |
         |   Consumer  |                      |   Producer  |
         +-------------+                      +-------------+
```

All the apps in the Umbrella are created equal. We would want to get rid
of the app dependencies in the Umbrella. Calling a function from a child
is not the only way of communication between Umbrella apps. There can be
various ways: direct processes messages, PubSub messages, message
queues, etc. But we will pick the GenStage.

We will keep the four initial applications, without any dependency
between them. Each of them will "host" two GenStages:

* one for the receive information flow, for the data we get from the
  external sources. The two external counterparts will play the role of
  `provider`. Our app, in this case, will be the GenStage final
  `consumer`.
* the other for the send information flow, for the data we send back.
  `MyUkApp` will become the `producer` in this case. The external
  sources will be the `consumers`.

In both cases the `Converter` will be a `producer_consumer` who's
responsibility is to handle the currency exchange.

```bash
+-------------+    +-------------+    +-------------+    +-------------+
|  GerMarket  |    |  UsaMarket  |    |  Converter  |    |  MyUkApp    |
+-------------+    +-------------+    +-------------+    +-------------+
+-------------+    +-------------+    +-------------+    +-------------+
|  receive    |    |  receive    |    |  receive    |    |  receive    |
|  producer   |    |  producer   |    |  producer   |    |  consumer   |
|             |    |             |    |  consumer   |    |             |
+-------------+    +-------------+    +-------------+    +-------------+
|  send       |    |  send       |    |  send       |    |  send       |
|  consumer   |    |  consumer   |    |  producer   |    |  producer   |
|             |    |             |    |  consumer   |    |             |
+-------------+    +-------------+    +-------------+    +-------------+
```

This is not hard to implement and is easily extensible. Let's say we
will add another provider from China. We will create its `receive
producer` and `send consumer` and "plug" it to the Converter. That's
it. `MyUkAp` will not even know about it.

We will add two new applications to the Umbrella:

* `Master` - app which will have the four main ones as dependencies.
  This will allow us to write end to end tests without mocking.
* `Shared` - app that will hold code to be reused in the other apps.
  The four main apps will have `Shared` as a dependency.

This is what our umbrella will look like:

```bash
                             +-------------+
                             |    Master   |
                             +------+------+
                                    |
       +-------------------+--------+---------+------------------+
       |                   |                  |                  |
+------+------+    +-------+-----+    +-------+-----+    +-------+-----+
|  GerMarket  |    |  UsaMarket  |    |  Converter  |    |  MyUkApp    |
+------+------+    +-------+-----+    +-------+-----+    +-------+-----+
       |                   |                  |                  |
       +-------------------+--------+---------+------------------+
                                    |
                             +------+------+
                             |    Shared   |
                             +-------------+
```

Let's create the apps.

```bash
mix new stock_market --umbrella && cd stock_market/apps

mix new master --sup
mix new ger_market --sup
mix new usa_market --sup
mix new converter --sup
mix new my_uk_app --sup
mix new shared --sup
```

# Running test files in Umbrella

* Absolute path: `mix test absolute_path`
* Local path: `mix test test/receive_info_test.exs`
* If you want to test the sub apps isolated to make sure that there
  aren't any hidden deps, you need to iterate the sub apps with a shell
  script, but should be easy:

```bash
for app in apps/*; do
  pushd $app
  mix test
  popd
done
```

### 18 December 2018 by Oleg G.Kapranov
