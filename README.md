# 🧪 ClojureScript on AWS λ 🥼

... and `terraform`.

Why not use Python and stuff everyting in 100 LOC Cloud Formation YAML?

Because Clojure. And Terraform.

Works for me. Expect rough edges.

## Usage

Install dependencies
```shell
yarn install || npm install
```

Run dev process
```shell
AWS_SDK_LOAD_CONFIG=true # Needed for assume-role
AWS_PROFILE=...
AWS_DEFAULT_REGION=...
yarn start || npm start
```

Compile an optimized version

```shell
yarn release || npm run release
```
REPL
```shell
yarn run repl || npm run repl
```

Deploy (terraform)
```shell
yarn run deploy || npm run deploy
```

## TODO
- Tests (-> namespace `integration-test`)