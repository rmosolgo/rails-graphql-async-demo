# Rails, GraphQL, Async demo

This app demonstrates parallel HTTP and ActiveRecord calls using [AsyncDataloader](https://graphql-ruby.org/dataloader/async_dataloader). You could use this to speed up GraphQL-Ruby queries that do long-running external service calls.

To enable the AsyncDataloader, use it in the schema configuration:

```diff
- use GraphQL::Dataloader
+ use GraphQL::Dataloader::AsyncDataloader
+ # from a development branch of graphql-ruby
```

Consider a query like this one:

```graphql
{
  count1: remoteDataloaderCount(set: "zen")
  count2: remoteDataloaderCount(set: "lrw")
  count3: remoteDataloaderCount(set: "m10")
}
```

Without `AsyncDataloader`, these operations run in sequence, for example:

```
Processing by GraphqlController#execute as */*

Started Sources::RemoteSet / zen
Finished Sources::RemoteSet / zen
Started Sources::RemoteSet / lrw
Finished Sources::RemoteSet / lrw
Started Sources::RemoteSet / m10
Finished Sources::RemoteSet / m10

Completed 200 OK in 219ms (Views: 0.2ms | ActiveRecord: 0.0ms | Allocations: 56576)
```

But, when `AsyncDataloader` is enabled, the operations run simultaneously:

```
Processing by GraphqlController#execute as */*

Started Sources::RemoteSet / zen
Started Sources::RemoteSet / lrw
Started Sources::RemoteSet / m10
Finished Sources::RemoteSet / lrw
Finished Sources::RemoteSet / m10
Finished Sources::RemoteSet / zen

Completed 200 OK in 120ms (Views: 0.2ms | ActiveRecord: 0.0ms | Allocations: 88201)
```

#### HTTP Calls


https://github.com/rmosolgo/rails-graphql-async-demo/blob/1e7ac9356f87e6a8b3d867a2c0815c8ab6b83e69/app/graphql/sources/remote_set.rb#L6-L13


#### ActiveRecord Calls

_Note: with sqlite3, these won't be parallel because sqlite only supports one operation at a time._

https://github.com/rmosolgo/rails-graphql-async-demo/blob/1e7ac9356f87e6a8b3d867a2c0815c8ab6b83e69/app/graphql/sources/local_set.rb#L6-L12
