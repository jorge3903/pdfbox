#!/bin/bash
projectName="pdfbox"
originalFolder="originalData"
outputFolder="outputData"
language="java"

sourceCodePath="${originalFolder}/pdfbox"
gitlogPath="${originalFolder}/gitlog.txt"
targetlistPath="${originalFolder}/BugIDFiltered.csv"
regex="PDFBOX-[0-9]+"

dependencyFileName="dependency"
dependencyFilePath="${outputFolder}/${dependencyFileName}.json"
dependencyMappingFileName="depends-dv8map"
dependPath="${outputFolder}/${dependencyMappingFileName}.json"
sdsmConfigPath="-Dextended.config=${originalFolder}/dv8-extended-config.xml"
hdsmConfigPath="-Dextended.config=${originalFolder}/dv8-history-extended-config.xml"

listFolderPath="${outputFolder}/lists"
changeListPath="${listFolderPath}/changefreqlist.csv"
changeChurnPath="${listFolderPath}/changechurnlist.csv"
bugListPath="${listFolderPath}/targetchurnlist.csv"
bugChurnPath="${listFolderPath}/targetcommitfreqlist.csv"

dsmOutputFolder="${outputFolder}/dsm"
structureDsmPath="${dsmOutputFolder}/${projectName}_structure.dv8-dsm"
historyDsmPath="${dsmOutputFolder}/${projectName}_history.dv8-dsm"
mergedDsmPath="${dsmOutputFolder}/${projectName}_merged.dv8-dsm"

archIssueFolder="${outputFolder}/archissue"
archIssueCostFolder="${outputFolder}/archissuecost"
archRootFolder="${outputFolder}/archroot"

echo "running preprocessor..."
java -jar depends-1.0-20181226.jar -s -p dot -d ${outputFolder} ${language} ${sourceCodePath} ${dependencyFileName}

