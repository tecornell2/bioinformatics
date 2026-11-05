# Accessing ChatGPT Codex on HPC

### Running codex
```sh
# open new terminal window
salloc --nodes 1 --ntasks 1 --cpus-per-task 4 --mem 8G --time 02:00:00
module load codex
codex
```

---

### Set-up (one-time)
Open a terminal window and link the HPC to your ChatGPT account.
```sh
salloc --nodes 1 --ntasks 1 --cpus-per-task 4 --mem 8G --time 02:00:00
module load codex
codex login --device-auth
# close terminal window
```
