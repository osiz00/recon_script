## a simple recon bash script 
#### tools you need to be installed before using the script
- amass
- subfinder
- waybackurls
- httpx
- anew
- gf
- kxss
#### installtion 
`git clone https://github.com/osiz00/recon_script.git`

#### usage 
`./recon.sh -l domainlist -n directory_name`
- the script will take a list of wildcard domains, and then it will create a directory in ./recon directory with the name you provided
- also the script preform a simple xss scan on all of the urls using kxss and sore the results at the kxss.txt file, to check for possible xss you can use the command
  
`cat kxss.txt | grep -Ei '<|>|"'`
