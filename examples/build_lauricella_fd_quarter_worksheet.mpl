restart:

markdownFile := "lauricella_fd_quarter.md":
worksheetFile := "lauricella_fd_quarter.mw":

markdownSource := FileTools:-Text:-ReadFile(markdownFile):
worksheetDocument := Worksheet:-FromMarkdown(markdownSource):
bytesWritten := Worksheet:-WriteFile(
    worksheetFile,worksheetDocument,
    'format'="mw",'newline'=false
):
roundTripDocument := Worksheet:-ReadFile(worksheetFile):

ValidateWorksheet := proc(document)
    if not type(document,function) then
        error "the generated worksheet did not pass the round-trip check";
    end if;
    return true;
end proc:
ValidateWorksheet(roundTripDocument):

printf("wrote %s (%d bytes)\n",worksheetFile,bytesWritten):
quit:
