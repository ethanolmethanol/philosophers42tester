# philosophers42tester
---
## Foreword
This repository contains my very own tester for philosophers, the 42 project in which you have to feed hungry philosophers plenty of spaghetti.
Love me some spaghetti.
## Using the tester
- Copy the tester in the root of your git repo/the parent directory of the philo (and philo_bonus) directories.
- With no argument, the tester performs tests on the mandatory part, checking if wrong entries cause errors, if certain parameters cause one and only one death, if certain parameters last for a certain amount of time (default is 10 seconds).
```usage: ./philotester.sh```
- For the bonus part, and since semaphores are inter-processes and I couldn't be bothered to make each process' semaphore unique to said process, performing multiple tests simultaneously could yield incorrect results.
- Thus, when adding `bonus` as an arguments to the tester, it shall access the executable philo located at ./philo_bonus, and wait between each test.
```usage: ./philotester.sh bonus```
