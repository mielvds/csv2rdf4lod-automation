#/bin/bash
#
# https://github.com/timrdf/csv2rdf4lod-automation/blob/master/bin/util/tic.sh
#
#3> @prefix rdfs:    <http://www.w3.org/2000/01/rdf-schema#> .
#3> @prefix dcterms: <http://purl.org/dc/terms/> .
#3> @prefix doap:    <http://usefulinc.com/ns/doap#> .
#3>
#3> <> a doap:Project;
#3>   dcterms:description "Script to extract Turtle from comments.";
#3>   rdfs:seeAlso <https://github.com/timrdf/csv2rdf4lod-automation/wiki/tic-turtle-in-comments>;
#3> .

if [[ "$1" == "--help" || "$1" == "-h" ]]; then
   echo "usage: `basename $0` [file]*"
   echo "  file: a path of a file that has \"#3>\" designations for Turtle in Comments."
   echo "  If no files given, search for files to process in current directory."
   echo "  https://github.com/timrdf/csv2rdf4lod-automation/wiki/tic-turtle-in-comments"
   exit 1
fi

# If no parameters, process all files.
if [ $# -lt 1 ]; then
   for ttl in `grep "^#3>" * | sed 's/:.*$//' | sort -u`; do
      $0 $ttl
   done
fi

TEMP="_"`basename $0``date +%s`_$$.tmp

while [ $# -gt 0 ]; do
   file="$1"
   
   # Strip out the turtle from comments.
   grep "^#3>" $file | sed 's/^#3>//;s/^ //' > $TEMP

   # Are prefixes defined?
   grep "@prefix"                              $TEMP &>/dev/null
   if [ $? ]; then
      # No prefixes defined; add the defaults.
      cr-default-prefixes.sh --turtle > ${TEMP}_prefixes
      cat ${TEMP}_prefixes $TEMP | rapper -q -i turtle -o turtle -I $file -
   else
      # Prefixes defined.
      cat                  $TEMP | rapper -q -i turtle -o turtle -I $file -
   fi
   rm -f "_"`basename $0`* # Remove any temp files from this script.
   shift
done
