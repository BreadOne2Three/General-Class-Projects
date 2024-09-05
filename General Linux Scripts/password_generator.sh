#!/bin/bash
#if there are any characters you want to add to this list, just add it, no additional changes necessary
randomReplace="aAbBcCdDeEfFgGhHiIjJkKlLmMnNoOpPqQrRsStTuUvVwWxXyYzZ0123456789!@#$%^&*()_+-=[]{}\|;:',.<>/?éîøêôóíøπœ∑´®åß∂ƒ©≈ç√∫˜µ©˙∆˚¬"

#convert random to a value between 0 and 99
randomFloat=$(( RANDOM % 100))
while getopts n:t: flag; do
	case $flag in
        n)
            words=$OPTARG
            customWords="yes"
            ;;
        t)
            customPermute="yes"
            permute=$OPTARG
            ;;
        *)
            ;;
    esac
done


if [ "$customWords" != "yes" ]
then
    words=4
fi

if [ "$customPermute" != "yes" ]
then 
    #default won't change any letters
    permute=0
else
    #in case the user omits a digit on left side of decimal (e.g. '.12' = '0.12' and '1.12' = '01.12')
    permute=0$permute
    #in case the user fat-fingers an extra decimal (e.g. '0.12.' it will still just grab '12')
    #also, set to just grab the first two decimals after the decimal to make it equal to the random number generated
    permute=$(echo "$permute" | awk -F'.' '{print substr($2, 1, 2)}')
    #if the length of permute is equal to one (e.g '.1' it will convert it to '.10' to prevent it being read as '1' instead of '10')
    if [ ${#permute} -eq 1 ]
    then
        permute=$permute\0
    fi
fi

passwordString=""
#in a range, append to the end of passwordString x times with x being either 4 or the input from '-n'
for i in $(seq 1 "$words");
do
    #grab the HTML file from this site, grab the 60th line (the line with the random word) and extract just the word that is contained between a <div> and </div>
    passwordString+=$(wget -q https://randomword.com -O - /dev/null | sed -n '60!d; s/.*>\([^<]*\)<.*/\1/p')
done
#while loop to keep generating a random number, and if the random number is less than the input-permute, will keep looping
while [[ $randomFloat -lt $permute ]]
do
    #generate random numbers for the equation
    randomInt=$((RANDOM % ${#randomReplace}))
    randomPosition=$((RANDOM % ${#passwordString}))
    newPasswordString="${passwordString:0:randomPosition}${randomReplace:randomInt:1}${passwordString:randomPosition+1}"
    #store the new password string in passwordString (because strings are immutable in bash)
    passwordString=$newPasswordString
    randomFloat=$((RANDOM % 100))
done

#you're done!
echo "$passwordString"