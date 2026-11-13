/* Independent scalar oracle. This file includes no candidate geometry code.
 * Host process checks are Linux/POSIX acceptance, not Android acceptance. */
#include <errno.h>
#include <math.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <sys/types.h>
#include <sys/wait.h>
#include <unistd.h>

typedef struct { const char *name; long double value; } expected_field;
static size_t make_expectations(expected_field expected[34])
{
    const long double distance=logl(2.0L);
    const expected_field values[34]={
        {"point.x",3.0L/4.0L},{"point.y",0},{"point.z",0},{"point.time",5.0L/4.0L},
        {"direction.x",5.0L/4.0L},{"direction.y",0},{"direction.z",0},{"direction.time",3.0L/4.0L},
        {"travelled",2.0L+distance},{"distance",distance},
        {"upper.position.0",3.0L/5.0L},{"upper.velocity.0",16.0L/25.0L},
        {"upper.position.1",0},{"upper.velocity.1",0},
        {"upper.position.2",4.0L/5.0L},{"upper.velocity.2",-12.0L/25.0L},
        {"klein.position.0",3.0L/5.0L},{"klein.velocity.0",16.0L/25.0L},
        {"klein.position.1",0},{"klein.velocity.1",0},{"klein.position.2",0},{"klein.velocity.2",0},
        {"poincare.position.0",1.0L/3.0L},{"poincare.velocity.0",4.0L/9.0L},
        {"poincare.position.1",0},{"poincare.velocity.1",0},
        {"poincare.position.2",0},{"poincare.velocity.2",0},
        {"frame.forward.x",5.0L/4.0L},{"frame.forward.y",0},
        {"frame.forward.z",0},{"frame.forward.time",3.0L/4.0L},
        {"plane.distance",distance},{"sphere.distance",distance}
    };
    memcpy(expected,values,sizeof values);
    return 34;
}
static int check_stream(FILE *input, int report)
{
    expected_field expected[34];
    size_t count=make_expectations(expected);
    long double observed[34];
    char line[192];
    for (size_t index=0; index<count; ++index) {
        if (!fgets(line,sizeof line,input)) {
            if (report) fprintf(stderr,"missing field %s\n",expected[index].name);
            return 1;
        }
        char *separator=strchr(line,'\t');
        if (!separator) return 1;
        *separator='\0';
        if (strcmp(line,expected[index].name)!=0) {
            if (report) fprintf(stderr,"unexpected field %s, expected %s\n",line,expected[index].name);
            return 1;
        }
        char *end;
        errno=0;
        observed[index]=strtold(separator+1,&end);
        if (errno || end==separator+1 || *end!='\n' || end[1]!='\0' ||
            !isfinite(observed[index]) ||
            fabsl(observed[index]-expected[index].value)>2e-10L) {
            if (report) fprintf(stderr,"incorrect or nonfinite field %s\n",expected[index].name);
            return 1;
        }
    }
    if (fgetc(input)!=EOF || ferror(input)) return 1;
    /* Distance and speed use upper-half-space metric identities, rather than
       reimplementing the candidate's hyperboloid propagation. */
    long double horizontal=observed[10], height=observed[14];
    long double cosine_distance=1.0L+
        (horizontal*horizontal+(height-1.0L)*(height-1.0L))/(2.0L*height);
    long double independent_distance=acoshl(cosine_distance);
    long double speed_squared=(observed[11]*observed[11]+observed[13]*observed[13]+
        observed[15]*observed[15])/(height*height);
    if (fabsl(independent_distance-observed[9])>2e-10L ||
        fabsl(speed_squared-1.0L)>2e-10L) return 1;
    return 0;
}
static int rejected_bytes(const char *first, size_t first_length,
                          const char *second, size_t second_length,
                          const char *third, size_t third_length)
{
    FILE *input=tmpfile();
    if (!input) return 0;
    int success=fwrite(first,1,first_length,input)==first_length &&
        fwrite(second,1,second_length,input)==second_length &&
        fwrite(third,1,third_length,input)==third_length;
    rewind(input);
    int rejected=success && check_stream(input,0)!=0;
    fclose(input);
    return rejected;
}
static int oracle_negative_cases(const char *path)
{
    FILE *input=fopen(path,"rb");
    if (!input) return 1;
    char bytes[8192];
    size_t length=fread(bytes,1,sizeof bytes,input);
    int oversized=fgetc(input)!=EOF || ferror(input);
    fclose(input);
    if (oversized || length<2) return 1;
    char *first_end=memchr(bytes,'\n',length);
    if (!first_end) return 1;
    size_t first_length=(size_t)(first_end-bytes)+1;
    char *second_end=memchr(bytes+first_length,'\n',length-first_length);
    if (!second_end) return 1;
    size_t second_length=(size_t)(second_end-(bytes+first_length))+1;
    const char nonfinite[]="point.x\tNaN\n";
    const char zero[]="point.x\t0\n";
    if (!rejected_bytes(nonfinite,sizeof nonfinite-1,bytes+first_length,length-first_length,"",0) ||
        !rejected_bytes(zero,sizeof zero-1,bytes+first_length,length-first_length,"",0) ||
        !rejected_bytes(bytes+first_length,second_length,bytes,first_length,
            bytes+first_length+second_length,length-first_length-second_length)) return 1;
    size_t truncated=length-1;
    while (truncated>0 && bytes[truncated-1]!='\n') --truncated;
    if (!rejected_bytes(bytes,truncated,"",0,"",0) ||
        !rejected_bytes(bytes,length,bytes,first_length,"",0)) return 1;
    puts("AI-CI H3 oracle: five corrupt-output cases rejected");
    return 0;
}
static int rejected_process(const char *executable, const char *argument,
                            const char *label)
{
    pid_t child=fork();
    if (child<0) return 1;
    if (child==0) {
        if (argument) execl(executable,executable,argument,(char *)NULL);
        else execl(executable,executable,(char *)NULL);
        _exit(127);
    }
    int result;
    while (waitpid(child,&result,0)<0) if (errno!=EINTR) return 1;
    if (!WIFEXITED(result) || WEXITSTATUS(result)!=1) {
        fprintf(stderr,"%s did not reject its bad input with exit 1\n",label);
        return 1;
    }
    printf("AI-CI H3 oracle: %s rejected\n",label);
    return 0;
}
int main(int argc, char **argv)
{
    if (argc!=5) {
        fprintf(stderr,"usage: h3-ray-accept OUTPUT.tsv RECENTER_TEST FROZEN_DIRECTION_TEST RESET_TRAVEL_TEST\n");
        return 2;
    }
    FILE *input=fopen(argv[1],"rb");
    if (!input) return 2;
    int result=check_stream(input,1);
    fclose(input);
    if (result || oracle_negative_cases(argv[1])) return 1;
    if (rejected_process(argv[2],"--reject-nan-assertion","nonfinite scalar assertion") ||
        rejected_process(argv[2],"--reject-nan-matrix","nonfinite matrix assertion") ||
        rejected_process(argv[3],NULL,"frozen ray direction") ||
        rejected_process(argv[4],NULL,"reset accumulated travel")) return 1;
    puts("AI-CI H3 oracle: PASS (34 exact-fraction fields, distance and speed, nine rejecting cases)");
    return 0;
}
