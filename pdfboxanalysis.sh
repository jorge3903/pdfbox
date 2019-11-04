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

echo "generating structure dsm..."
dv8-console core:convert-matrix -outputFile $structureDsmPath -dependPath $dependPath "$sdsmConfigPath" $dependencyFilePath

echo "calculating DL..."
dv8-console metrics:decoupling-level $structureDsmPath

echo "calculating PC..."
dv8-console metrics:propagation-cost $structureDsmPath

echo "generating history dsm..."
dv8-console scm:history:gittxt:convert-matrix -matrix $structureDsmPath -maxCochangeCount 500 -outputFile $historyDsmPath "$hdsmConfigPath" $gitlogPath

echo "generating change list..."
dv8-console scm:history:genchangelist:gittxt:generate-changelist -outputFolder $listFolderPath $hdsmConfigPath $gitlogPath

echo "generating target list..."
dv8-console scm:history:gentargetlist:gittxt:generate-targetlist -regex $regex -targetissuecsv $targetlistPath -outputFolder $listFolderPath $hdsmConfigPath $gitlogPath

echo "merging structure and history dsm..."
dv8-console merge-matrix -outputFile $mergedDsmPath $structureDsmPath $historyDsmPath

echo "calculating arch issue..."
dv8-console arch-issue -outputFolder $archIssueFolder $mergedDsmPath

echo "calculating arch issue cost..."
dv8-console debt:arch-issue-cost -outputFolder $archIssueCostFolder -CF $changeListPath -CC $changeChurnPath -BF $bugListPath -BC $bugChurnPath -asDir $archIssueFolder $structureDsmPath

echo "calculating arch root..."
dv8-console arch-root:arch-root -outputFolder $archRootFolder -targetlist "${bugListPath}" $structureDsmPath
