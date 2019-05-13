#!/bin/bash
# find all text files and place all words into a text file
find $1 -name "*.txt" -exec cat {} \; > text.masterlist

# take each word and put it into a new line in the file
tr -sc 'A-Za-z' '\n' < text.masterlist > text.words

# create a list to act as the next word in the histogram
tail -n+2 text.words > text.nextword

# create list to act as the third word in each histogram
tail -n+3 text.words > text.thirdword

# put each list together to from all the histograms
paste text.words text.nextword text.thirdword > text.wordlist

# read the file to get the total word count
cat text.wordlist| wc -l > text.totalwords

# sort the file and combine repeats to get the number of times each histogram appears
paste text.words text.nextword text.thirdword| sort |uniq -ic| sort -nr > text.awk

# remove number values from histogram count to get the Histogram colomn for chart
sed 's/[0-9]*//g' text.awk > text.topwords

# read all the number values to get the number of times each histogram appears colomn for chart
grep -o [0-9]* < text.awk > text.countlist

# create list of top histograms and the number of times they appear
paste text.topwords text.countlist >text.final

# create variable form total word count
total=`cat text.totalwords`

# get decimal value of wordcount/total words then convert to percentage
awk -v c="$total" '{print $4/c}' text.final > text.percentage
awk '{printf ("%.4f\n", $1*100)}' text.percentage > text.newpercentage

# get decimal value of cumulative values of each histogram then convert to percentage
awk '{total += $0; $0 = total}1' text.percentage > text.cumulative
awk '{printf ("%.4f\n", $1*100)}' text.cumulative > text.newcumulative

# form final data sheet to be formated for charts
paste text.topwords text.countlist text.newpercentage text.newcumulative > text.newfinal

# Display Top 10 most frequent with title and correct format
awk 'BEGIN {printf("%s %s %s %30s %25s %22s \n" ,"Trigram", "_", "_", "Amount", "Percentage", "Cumulative")}{printf("%s %s %s %25.0f %20.4f%% %20.4f%%\n", $1,$2,$3, $4, $5, $6)}' text.newfinal | head -10| column -t

# Display closest histogram to 25th percentiale value
awk 'BEGIN {printf("%s %s %s %30s %25s %22s \n" ,"Trigram", "_", "_", "Amount", "Percentage", "Cumulative")}{printf("%s %s %s %25.0f %20.4f%% %20.4f%%\n", $1,$2,$3, $4, $5, $6)}' text.newfinal | grep "25\." |head -1| column -t

# Display closest histogram to 50th percentiale value
awk 'BEGIN {printf("%s %s %s %30s %25s %22s \n" ,"Trigram", "_", "_", "Amount", "Percentage", "Cumulative")}{printf("%s %s %s %25.0f %20.4f%% %20.4f%%\n", $1,$2,$3, $4, $5, $6)}' text.newfinal | grep "50\." |head -1| column -t

# Display closest histogram to 75th percentiale value
awk 'BEGIN {printf("%s %s %s %30s %25s %22s \n" ,"Trigram", "_", "_", "Amount", "Percentage", "Cumulative")}{printf("%s %s %s %25.0f %20.4f%% %20.4f%%\n", $1,$2,$3, $4, $5, $6)}' text.newfinal | grep "75\." |head -1| column -t

# Least frequent
paste text.words text.nextword text.thirdword| sort |uniq -ic| sort -n > text.leastawk

# remove number values from histogram count to get the Histogram colomn for chart
sed 's/[0-9]*//g' text.leastawk > text.bottomwords

# read all the number values to get the number of times each histogram appears colomn for chart
grep -o [0-9]* < text.leastawk > text.bottomcountlist

# create list of top histograms and the number of times they appear
paste text.bottomwords text.bottomcountlist >text.leastfinal

# Create decimal values of appearrance and cumulative value then convert to decimal
awk -v c="$total" '{print $4/c}' text.leastfinal > text.leastpercentage
awk '{printf ("%.4f\n", $1*100)}' text.leastpercentage > text.leastnewpercentage

# get cumulative values from bottom 10
paste text.newcumulative| sort -r > text.leastnewcumulative

# create least frequent master data for chart
paste text.bottomwords text.bottomcountlist text.leastnewpercentage text.leastnewcumulative > text.leastnewfinal

# Display least 10 frequent with proper titles and format
awk 'BEGIN {printf("%s %s %s %30s %25s %22s \n" ,"Trigram", "_", "_", "Amount", "Percentage", "Cumulative")}{printf("%s %s %s %25.0f %20.4f%% %20.4f%%\n", $1,$2,$3, $4, $5, $6)}' text.leastnewfinal | head -10| column -t

# exit gracefully