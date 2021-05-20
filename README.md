# Koinly transaction export scripts

Collection of script to help import transactions to [Koinly|https://koinly.io/?via=E8ED4EB5]. 

Sign up to Koinly to track your crypto currency investments and get tax report. Koinly provides also Finnish tax report.

## Dependencies

* Docker

## Build

You can build a ruby docker image with all the required gems

```
build.sh 
```

## Run

```
run.sh [rubyscript] [args] 
```

Example:

```
run.sh cryptoOrgChain.rb cro1j3g7qrha6nxh6guvtsz56j06ej8cn3rnyegjz0 
```

## Scripts

* cryptoOrgChain.rb Crypto.org chain account transactions export
