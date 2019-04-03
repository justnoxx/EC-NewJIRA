// This procedure.dsl was generated automatically
// It will not be updated upon regeneration
// Additional code may be a added here
procedure 'Get Issue', description: 'Gets issue by its id', {

    step 'Get Issue', {
        description = ''
        command = new File("dsl/procedures/GetIssue/steps/GetIssue.pl").text
        shell = 'ec-perl'
        
        
        
    }
    
    formalOutputParameter 'issue',
        description: 'An issue details'
    

}
