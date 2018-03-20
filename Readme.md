# timesheet automation for replicon. 
## my rant and reasoning  

replicon + pingone? here is some automation

# install

just get ruby and then
```
gem install watir
chmod +x timesheet.rb
```

mac requires an additional install
```
brew install chromedriver
```

## oh and i almost forgot, the usage 
```
Usage: ./timesheet.rb [options]
    -r, --[no-]refresh-session       refresh user session
    -u, --username USERNAME          your username
    -p, --password PASSWORD          your password
    -e, --enter-time ENTERTIME       the time you entered
    -x, --exit-time EXITTIME         the time you exited
    -o ORGANIZATION,                 the name of your organization as used by pingone
        --organization-name
```
### first use (to get the cookies)
```
./timesheet.rb -u <username> -p <password> -o <organization> -r
```
### then simply
```
./timesheet.rb -u <username> -p <password> -o <organization>

```

