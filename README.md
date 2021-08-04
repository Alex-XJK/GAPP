# README

---

- **This branch is only used to DEPLOY**  
    PUSH permission will be restricted during non-deployment periods.  
    Please merge here only after you have completed the overall test in master!  
    *by alex 0731*

---

Set up development environment:

``` shell
bundle install

yarn install

#username is gapp

#for mac user
createuser --interactive

#for linux user
sudo su - postgres
createuser --interactive
exit


bin/rails db:create

bin/rails db:migrate
```
