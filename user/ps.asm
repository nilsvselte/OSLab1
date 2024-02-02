
user/_ps:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <string_state_to_int>:
#include "kernel/types.h"
#include "user.h"

int
string_state_to_int(char* stateStr)
{
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	e426                	sd	s1,8(sp)
   8:	1000                	addi	s0,sp,32
   a:	84aa                	mv	s1,a0
    if (strcmp(stateStr, "UNUSED") == 0) 
   c:	00001597          	auipc	a1,0x1
  10:	94458593          	addi	a1,a1,-1724 # 950 <malloc+0xf4>
  14:	00000097          	auipc	ra,0x0
  18:	1ae080e7          	jalr	430(ra) # 1c2 <strcmp>
  1c:	e511                	bnez	a0,28 <string_state_to_int+0x28>
    } else if (strcmp(stateStr, "ZOMBIE") == 0) {
        return 5;
    } else {
        return -1;
    }
}
  1e:	60e2                	ld	ra,24(sp)
  20:	6442                	ld	s0,16(sp)
  22:	64a2                	ld	s1,8(sp)
  24:	6105                	addi	sp,sp,32
  26:	8082                	ret
    } else if (strcmp(stateStr, "USED") == 0) {
  28:	00001597          	auipc	a1,0x1
  2c:	93058593          	addi	a1,a1,-1744 # 958 <malloc+0xfc>
  30:	8526                	mv	a0,s1
  32:	00000097          	auipc	ra,0x0
  36:	190080e7          	jalr	400(ra) # 1c2 <strcmp>
  3a:	87aa                	mv	a5,a0
        return 1;
  3c:	4505                	li	a0,1
    } else if (strcmp(stateStr, "USED") == 0) {
  3e:	d3e5                	beqz	a5,1e <string_state_to_int+0x1e>
    } else if (strcmp(stateStr, "SLEEPING") == 0) {
  40:	00001597          	auipc	a1,0x1
  44:	92058593          	addi	a1,a1,-1760 # 960 <malloc+0x104>
  48:	8526                	mv	a0,s1
  4a:	00000097          	auipc	ra,0x0
  4e:	178080e7          	jalr	376(ra) # 1c2 <strcmp>
  52:	87aa                	mv	a5,a0
        return 2;
  54:	4509                	li	a0,2
    } else if (strcmp(stateStr, "SLEEPING") == 0) {
  56:	d7e1                	beqz	a5,1e <string_state_to_int+0x1e>
    } else if (strcmp(stateStr, "RUNNABLE") == 0) {
  58:	00001597          	auipc	a1,0x1
  5c:	91858593          	addi	a1,a1,-1768 # 970 <malloc+0x114>
  60:	8526                	mv	a0,s1
  62:	00000097          	auipc	ra,0x0
  66:	160080e7          	jalr	352(ra) # 1c2 <strcmp>
  6a:	87aa                	mv	a5,a0
        return 3;
  6c:	450d                	li	a0,3
    } else if (strcmp(stateStr, "RUNNABLE") == 0) {
  6e:	dbc5                	beqz	a5,1e <string_state_to_int+0x1e>
    } else if (strcmp(stateStr, "RUNNING") == 0) {
  70:	00001597          	auipc	a1,0x1
  74:	91058593          	addi	a1,a1,-1776 # 980 <malloc+0x124>
  78:	8526                	mv	a0,s1
  7a:	00000097          	auipc	ra,0x0
  7e:	148080e7          	jalr	328(ra) # 1c2 <strcmp>
  82:	87aa                	mv	a5,a0
        return 4;
  84:	4511                	li	a0,4
    } else if (strcmp(stateStr, "RUNNING") == 0) {
  86:	dfc1                	beqz	a5,1e <string_state_to_int+0x1e>
    } else if (strcmp(stateStr, "ZOMBIE") == 0) {
  88:	00001597          	auipc	a1,0x1
  8c:	90058593          	addi	a1,a1,-1792 # 988 <malloc+0x12c>
  90:	8526                	mv	a0,s1
  92:	00000097          	auipc	ra,0x0
  96:	130080e7          	jalr	304(ra) # 1c2 <strcmp>
  9a:	87aa                	mv	a5,a0
        return 5;
  9c:	4515                	li	a0,5
    } else if (strcmp(stateStr, "ZOMBIE") == 0) {
  9e:	d3c1                	beqz	a5,1e <string_state_to_int+0x1e>
        return -1;
  a0:	557d                	li	a0,-1
  a2:	bfb5                	j	1e <string_state_to_int+0x1e>

00000000000000a4 <main>:

int 
main(void) 
{
  a4:	7105                	addi	sp,sp,-480
  a6:	ef86                	sd	ra,472(sp)
  a8:	eba2                	sd	s0,464(sp)
  aa:	e7a6                	sd	s1,456(sp)
  ac:	e3ca                	sd	s2,448(sp)
  ae:	ff4e                	sd	s3,440(sp)
  b0:	fb52                	sd	s4,432(sp)
  b2:	f756                	sd	s5,424(sp)
  b4:	f35a                	sd	s6,416(sp)
  b6:	ef5e                	sd	s7,408(sp)
  b8:	1380                	addi	s0,sp,480
    int pid_array[100];
    int num_pids;
    num_pids = year(pid_array, 100);
  ba:	06400593          	li	a1,100
  be:	e2040513          	addi	a0,s0,-480
  c2:	00000097          	auipc	ra,0x0
  c6:	3f0080e7          	jalr	1008(ra) # 4b2 <year>
  ca:	0005079b          	sext.w	a5,a0

    if (num_pids < 0) {
  ce:	0a07c263          	bltz	a5,172 <main+0xce>
        printf("Error in sys_year\n");
        exit(0);
    }
    // Process or print the PIDs
    //printf("Received %d PIDs:\n", num_pids);
    for (int i = 0; i < num_pids; i++) {
  d2:	08f05b63          	blez	a5,168 <main+0xc4>
  d6:	e2040493          	addi	s1,s0,-480
  da:	fff50a1b          	addiw	s4,a0,-1
  de:	020a1793          	slli	a5,s4,0x20
  e2:	01e7da13          	srli	s4,a5,0x1e
  e6:	e2440793          	addi	a5,s0,-476
  ea:	9a3e                	add	s4,s4,a5
        char* stateStr = (char*)malloc(16);
        char* nameStr = (char*)malloc(16);
        state(pid_array[i],stateStr);
        procname(pid_array[i],nameStr);
        printf("%s ", nameStr);
  ec:	00001b97          	auipc	s7,0x1
  f0:	8bcb8b93          	addi	s7,s7,-1860 # 9a8 <malloc+0x14c>
        printf("(%d):", pid_array[i]);
  f4:	00001b17          	auipc	s6,0x1
  f8:	8bcb0b13          	addi	s6,s6,-1860 # 9b0 <malloc+0x154>
        printf(" %d\n", string_state_to_int(stateStr));        
  fc:	00001a97          	auipc	s5,0x1
 100:	8bca8a93          	addi	s5,s5,-1860 # 9b8 <malloc+0x15c>
        char* stateStr = (char*)malloc(16);
 104:	4541                	li	a0,16
 106:	00000097          	auipc	ra,0x0
 10a:	756080e7          	jalr	1878(ra) # 85c <malloc>
 10e:	892a                	mv	s2,a0
        char* nameStr = (char*)malloc(16);
 110:	4541                	li	a0,16
 112:	00000097          	auipc	ra,0x0
 116:	74a080e7          	jalr	1866(ra) # 85c <malloc>
 11a:	89aa                	mv	s3,a0
        state(pid_array[i],stateStr);
 11c:	85ca                	mv	a1,s2
 11e:	4088                	lw	a0,0(s1)
 120:	00000097          	auipc	ra,0x0
 124:	39a080e7          	jalr	922(ra) # 4ba <state>
        procname(pid_array[i],nameStr);
 128:	85ce                	mv	a1,s3
 12a:	4088                	lw	a0,0(s1)
 12c:	00000097          	auipc	ra,0x0
 130:	396080e7          	jalr	918(ra) # 4c2 <procname>
        printf("%s ", nameStr);
 134:	85ce                	mv	a1,s3
 136:	855e                	mv	a0,s7
 138:	00000097          	auipc	ra,0x0
 13c:	66c080e7          	jalr	1644(ra) # 7a4 <printf>
        printf("(%d):", pid_array[i]);
 140:	408c                	lw	a1,0(s1)
 142:	855a                	mv	a0,s6
 144:	00000097          	auipc	ra,0x0
 148:	660080e7          	jalr	1632(ra) # 7a4 <printf>
        printf(" %d\n", string_state_to_int(stateStr));        
 14c:	854a                	mv	a0,s2
 14e:	00000097          	auipc	ra,0x0
 152:	eb2080e7          	jalr	-334(ra) # 0 <string_state_to_int>
 156:	85aa                	mv	a1,a0
 158:	8556                	mv	a0,s5
 15a:	00000097          	auipc	ra,0x0
 15e:	64a080e7          	jalr	1610(ra) # 7a4 <printf>
    for (int i = 0; i < num_pids; i++) {
 162:	0491                	addi	s1,s1,4
 164:	fb4490e3          	bne	s1,s4,104 <main+0x60>
    }
    exit(0);
 168:	4501                	li	a0,0
 16a:	00000097          	auipc	ra,0x0
 16e:	2a8080e7          	jalr	680(ra) # 412 <exit>
        printf("Error in sys_year\n");
 172:	00001517          	auipc	a0,0x1
 176:	81e50513          	addi	a0,a0,-2018 # 990 <malloc+0x134>
 17a:	00000097          	auipc	ra,0x0
 17e:	62a080e7          	jalr	1578(ra) # 7a4 <printf>
        exit(0);
 182:	4501                	li	a0,0
 184:	00000097          	auipc	ra,0x0
 188:	28e080e7          	jalr	654(ra) # 412 <exit>

000000000000018c <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
 18c:	1141                	addi	sp,sp,-16
 18e:	e406                	sd	ra,8(sp)
 190:	e022                	sd	s0,0(sp)
 192:	0800                	addi	s0,sp,16
  extern int main();
  main();
 194:	00000097          	auipc	ra,0x0
 198:	f10080e7          	jalr	-240(ra) # a4 <main>
  exit(0);
 19c:	4501                	li	a0,0
 19e:	00000097          	auipc	ra,0x0
 1a2:	274080e7          	jalr	628(ra) # 412 <exit>

00000000000001a6 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
 1a6:	1141                	addi	sp,sp,-16
 1a8:	e422                	sd	s0,8(sp)
 1aa:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
 1ac:	87aa                	mv	a5,a0
 1ae:	0585                	addi	a1,a1,1
 1b0:	0785                	addi	a5,a5,1
 1b2:	fff5c703          	lbu	a4,-1(a1)
 1b6:	fee78fa3          	sb	a4,-1(a5)
 1ba:	fb75                	bnez	a4,1ae <strcpy+0x8>
    ;
  return os;
}
 1bc:	6422                	ld	s0,8(sp)
 1be:	0141                	addi	sp,sp,16
 1c0:	8082                	ret

00000000000001c2 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 1c2:	1141                	addi	sp,sp,-16
 1c4:	e422                	sd	s0,8(sp)
 1c6:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 1c8:	00054783          	lbu	a5,0(a0)
 1cc:	cb91                	beqz	a5,1e0 <strcmp+0x1e>
 1ce:	0005c703          	lbu	a4,0(a1)
 1d2:	00f71763          	bne	a4,a5,1e0 <strcmp+0x1e>
    p++, q++;
 1d6:	0505                	addi	a0,a0,1
 1d8:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 1da:	00054783          	lbu	a5,0(a0)
 1de:	fbe5                	bnez	a5,1ce <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 1e0:	0005c503          	lbu	a0,0(a1)
}
 1e4:	40a7853b          	subw	a0,a5,a0
 1e8:	6422                	ld	s0,8(sp)
 1ea:	0141                	addi	sp,sp,16
 1ec:	8082                	ret

00000000000001ee <strlen>:

uint
strlen(const char *s)
{
 1ee:	1141                	addi	sp,sp,-16
 1f0:	e422                	sd	s0,8(sp)
 1f2:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 1f4:	00054783          	lbu	a5,0(a0)
 1f8:	cf91                	beqz	a5,214 <strlen+0x26>
 1fa:	0505                	addi	a0,a0,1
 1fc:	87aa                	mv	a5,a0
 1fe:	4685                	li	a3,1
 200:	9e89                	subw	a3,a3,a0
 202:	00f6853b          	addw	a0,a3,a5
 206:	0785                	addi	a5,a5,1
 208:	fff7c703          	lbu	a4,-1(a5)
 20c:	fb7d                	bnez	a4,202 <strlen+0x14>
    ;
  return n;
}
 20e:	6422                	ld	s0,8(sp)
 210:	0141                	addi	sp,sp,16
 212:	8082                	ret
  for(n = 0; s[n]; n++)
 214:	4501                	li	a0,0
 216:	bfe5                	j	20e <strlen+0x20>

0000000000000218 <memset>:

void*
memset(void *dst, int c, uint n)
{
 218:	1141                	addi	sp,sp,-16
 21a:	e422                	sd	s0,8(sp)
 21c:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 21e:	ca19                	beqz	a2,234 <memset+0x1c>
 220:	87aa                	mv	a5,a0
 222:	1602                	slli	a2,a2,0x20
 224:	9201                	srli	a2,a2,0x20
 226:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 22a:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 22e:	0785                	addi	a5,a5,1
 230:	fee79de3          	bne	a5,a4,22a <memset+0x12>
  }
  return dst;
}
 234:	6422                	ld	s0,8(sp)
 236:	0141                	addi	sp,sp,16
 238:	8082                	ret

000000000000023a <strchr>:

char*
strchr(const char *s, char c)
{
 23a:	1141                	addi	sp,sp,-16
 23c:	e422                	sd	s0,8(sp)
 23e:	0800                	addi	s0,sp,16
  for(; *s; s++)
 240:	00054783          	lbu	a5,0(a0)
 244:	cb99                	beqz	a5,25a <strchr+0x20>
    if(*s == c)
 246:	00f58763          	beq	a1,a5,254 <strchr+0x1a>
  for(; *s; s++)
 24a:	0505                	addi	a0,a0,1
 24c:	00054783          	lbu	a5,0(a0)
 250:	fbfd                	bnez	a5,246 <strchr+0xc>
      return (char*)s;
  return 0;
 252:	4501                	li	a0,0
}
 254:	6422                	ld	s0,8(sp)
 256:	0141                	addi	sp,sp,16
 258:	8082                	ret
  return 0;
 25a:	4501                	li	a0,0
 25c:	bfe5                	j	254 <strchr+0x1a>

000000000000025e <gets>:

char*
gets(char *buf, int max)
{
 25e:	711d                	addi	sp,sp,-96
 260:	ec86                	sd	ra,88(sp)
 262:	e8a2                	sd	s0,80(sp)
 264:	e4a6                	sd	s1,72(sp)
 266:	e0ca                	sd	s2,64(sp)
 268:	fc4e                	sd	s3,56(sp)
 26a:	f852                	sd	s4,48(sp)
 26c:	f456                	sd	s5,40(sp)
 26e:	f05a                	sd	s6,32(sp)
 270:	ec5e                	sd	s7,24(sp)
 272:	1080                	addi	s0,sp,96
 274:	8baa                	mv	s7,a0
 276:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 278:	892a                	mv	s2,a0
 27a:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 27c:	4aa9                	li	s5,10
 27e:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 280:	89a6                	mv	s3,s1
 282:	2485                	addiw	s1,s1,1
 284:	0344d863          	bge	s1,s4,2b4 <gets+0x56>
    cc = read(0, &c, 1);
 288:	4605                	li	a2,1
 28a:	faf40593          	addi	a1,s0,-81
 28e:	4501                	li	a0,0
 290:	00000097          	auipc	ra,0x0
 294:	19a080e7          	jalr	410(ra) # 42a <read>
    if(cc < 1)
 298:	00a05e63          	blez	a0,2b4 <gets+0x56>
    buf[i++] = c;
 29c:	faf44783          	lbu	a5,-81(s0)
 2a0:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 2a4:	01578763          	beq	a5,s5,2b2 <gets+0x54>
 2a8:	0905                	addi	s2,s2,1
 2aa:	fd679be3          	bne	a5,s6,280 <gets+0x22>
  for(i=0; i+1 < max; ){
 2ae:	89a6                	mv	s3,s1
 2b0:	a011                	j	2b4 <gets+0x56>
 2b2:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 2b4:	99de                	add	s3,s3,s7
 2b6:	00098023          	sb	zero,0(s3)
  return buf;
}
 2ba:	855e                	mv	a0,s7
 2bc:	60e6                	ld	ra,88(sp)
 2be:	6446                	ld	s0,80(sp)
 2c0:	64a6                	ld	s1,72(sp)
 2c2:	6906                	ld	s2,64(sp)
 2c4:	79e2                	ld	s3,56(sp)
 2c6:	7a42                	ld	s4,48(sp)
 2c8:	7aa2                	ld	s5,40(sp)
 2ca:	7b02                	ld	s6,32(sp)
 2cc:	6be2                	ld	s7,24(sp)
 2ce:	6125                	addi	sp,sp,96
 2d0:	8082                	ret

00000000000002d2 <stat>:

int
stat(const char *n, struct stat *st)
{
 2d2:	1101                	addi	sp,sp,-32
 2d4:	ec06                	sd	ra,24(sp)
 2d6:	e822                	sd	s0,16(sp)
 2d8:	e426                	sd	s1,8(sp)
 2da:	e04a                	sd	s2,0(sp)
 2dc:	1000                	addi	s0,sp,32
 2de:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 2e0:	4581                	li	a1,0
 2e2:	00000097          	auipc	ra,0x0
 2e6:	170080e7          	jalr	368(ra) # 452 <open>
  if(fd < 0)
 2ea:	02054563          	bltz	a0,314 <stat+0x42>
 2ee:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 2f0:	85ca                	mv	a1,s2
 2f2:	00000097          	auipc	ra,0x0
 2f6:	178080e7          	jalr	376(ra) # 46a <fstat>
 2fa:	892a                	mv	s2,a0
  close(fd);
 2fc:	8526                	mv	a0,s1
 2fe:	00000097          	auipc	ra,0x0
 302:	13c080e7          	jalr	316(ra) # 43a <close>
  return r;
}
 306:	854a                	mv	a0,s2
 308:	60e2                	ld	ra,24(sp)
 30a:	6442                	ld	s0,16(sp)
 30c:	64a2                	ld	s1,8(sp)
 30e:	6902                	ld	s2,0(sp)
 310:	6105                	addi	sp,sp,32
 312:	8082                	ret
    return -1;
 314:	597d                	li	s2,-1
 316:	bfc5                	j	306 <stat+0x34>

0000000000000318 <atoi>:

int
atoi(const char *s)
{
 318:	1141                	addi	sp,sp,-16
 31a:	e422                	sd	s0,8(sp)
 31c:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 31e:	00054683          	lbu	a3,0(a0)
 322:	fd06879b          	addiw	a5,a3,-48
 326:	0ff7f793          	zext.b	a5,a5
 32a:	4625                	li	a2,9
 32c:	02f66863          	bltu	a2,a5,35c <atoi+0x44>
 330:	872a                	mv	a4,a0
  n = 0;
 332:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 334:	0705                	addi	a4,a4,1
 336:	0025179b          	slliw	a5,a0,0x2
 33a:	9fa9                	addw	a5,a5,a0
 33c:	0017979b          	slliw	a5,a5,0x1
 340:	9fb5                	addw	a5,a5,a3
 342:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 346:	00074683          	lbu	a3,0(a4)
 34a:	fd06879b          	addiw	a5,a3,-48
 34e:	0ff7f793          	zext.b	a5,a5
 352:	fef671e3          	bgeu	a2,a5,334 <atoi+0x1c>
  return n;
}
 356:	6422                	ld	s0,8(sp)
 358:	0141                	addi	sp,sp,16
 35a:	8082                	ret
  n = 0;
 35c:	4501                	li	a0,0
 35e:	bfe5                	j	356 <atoi+0x3e>

0000000000000360 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 360:	1141                	addi	sp,sp,-16
 362:	e422                	sd	s0,8(sp)
 364:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 366:	02b57463          	bgeu	a0,a1,38e <memmove+0x2e>
    while(n-- > 0)
 36a:	00c05f63          	blez	a2,388 <memmove+0x28>
 36e:	1602                	slli	a2,a2,0x20
 370:	9201                	srli	a2,a2,0x20
 372:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 376:	872a                	mv	a4,a0
      *dst++ = *src++;
 378:	0585                	addi	a1,a1,1
 37a:	0705                	addi	a4,a4,1
 37c:	fff5c683          	lbu	a3,-1(a1)
 380:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 384:	fee79ae3          	bne	a5,a4,378 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 388:	6422                	ld	s0,8(sp)
 38a:	0141                	addi	sp,sp,16
 38c:	8082                	ret
    dst += n;
 38e:	00c50733          	add	a4,a0,a2
    src += n;
 392:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 394:	fec05ae3          	blez	a2,388 <memmove+0x28>
 398:	fff6079b          	addiw	a5,a2,-1
 39c:	1782                	slli	a5,a5,0x20
 39e:	9381                	srli	a5,a5,0x20
 3a0:	fff7c793          	not	a5,a5
 3a4:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 3a6:	15fd                	addi	a1,a1,-1
 3a8:	177d                	addi	a4,a4,-1
 3aa:	0005c683          	lbu	a3,0(a1)
 3ae:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 3b2:	fee79ae3          	bne	a5,a4,3a6 <memmove+0x46>
 3b6:	bfc9                	j	388 <memmove+0x28>

00000000000003b8 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 3b8:	1141                	addi	sp,sp,-16
 3ba:	e422                	sd	s0,8(sp)
 3bc:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 3be:	ca05                	beqz	a2,3ee <memcmp+0x36>
 3c0:	fff6069b          	addiw	a3,a2,-1
 3c4:	1682                	slli	a3,a3,0x20
 3c6:	9281                	srli	a3,a3,0x20
 3c8:	0685                	addi	a3,a3,1
 3ca:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 3cc:	00054783          	lbu	a5,0(a0)
 3d0:	0005c703          	lbu	a4,0(a1)
 3d4:	00e79863          	bne	a5,a4,3e4 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 3d8:	0505                	addi	a0,a0,1
    p2++;
 3da:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 3dc:	fed518e3          	bne	a0,a3,3cc <memcmp+0x14>
  }
  return 0;
 3e0:	4501                	li	a0,0
 3e2:	a019                	j	3e8 <memcmp+0x30>
      return *p1 - *p2;
 3e4:	40e7853b          	subw	a0,a5,a4
}
 3e8:	6422                	ld	s0,8(sp)
 3ea:	0141                	addi	sp,sp,16
 3ec:	8082                	ret
  return 0;
 3ee:	4501                	li	a0,0
 3f0:	bfe5                	j	3e8 <memcmp+0x30>

00000000000003f2 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 3f2:	1141                	addi	sp,sp,-16
 3f4:	e406                	sd	ra,8(sp)
 3f6:	e022                	sd	s0,0(sp)
 3f8:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 3fa:	00000097          	auipc	ra,0x0
 3fe:	f66080e7          	jalr	-154(ra) # 360 <memmove>
}
 402:	60a2                	ld	ra,8(sp)
 404:	6402                	ld	s0,0(sp)
 406:	0141                	addi	sp,sp,16
 408:	8082                	ret

000000000000040a <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 40a:	4885                	li	a7,1
 ecall
 40c:	00000073          	ecall
 ret
 410:	8082                	ret

0000000000000412 <exit>:
.global exit
exit:
 li a7, SYS_exit
 412:	4889                	li	a7,2
 ecall
 414:	00000073          	ecall
 ret
 418:	8082                	ret

000000000000041a <wait>:
.global wait
wait:
 li a7, SYS_wait
 41a:	488d                	li	a7,3
 ecall
 41c:	00000073          	ecall
 ret
 420:	8082                	ret

0000000000000422 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 422:	4891                	li	a7,4
 ecall
 424:	00000073          	ecall
 ret
 428:	8082                	ret

000000000000042a <read>:
.global read
read:
 li a7, SYS_read
 42a:	4895                	li	a7,5
 ecall
 42c:	00000073          	ecall
 ret
 430:	8082                	ret

0000000000000432 <write>:
.global write
write:
 li a7, SYS_write
 432:	48c1                	li	a7,16
 ecall
 434:	00000073          	ecall
 ret
 438:	8082                	ret

000000000000043a <close>:
.global close
close:
 li a7, SYS_close
 43a:	48d5                	li	a7,21
 ecall
 43c:	00000073          	ecall
 ret
 440:	8082                	ret

0000000000000442 <kill>:
.global kill
kill:
 li a7, SYS_kill
 442:	4899                	li	a7,6
 ecall
 444:	00000073          	ecall
 ret
 448:	8082                	ret

000000000000044a <exec>:
.global exec
exec:
 li a7, SYS_exec
 44a:	489d                	li	a7,7
 ecall
 44c:	00000073          	ecall
 ret
 450:	8082                	ret

0000000000000452 <open>:
.global open
open:
 li a7, SYS_open
 452:	48bd                	li	a7,15
 ecall
 454:	00000073          	ecall
 ret
 458:	8082                	ret

000000000000045a <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 45a:	48c5                	li	a7,17
 ecall
 45c:	00000073          	ecall
 ret
 460:	8082                	ret

0000000000000462 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 462:	48c9                	li	a7,18
 ecall
 464:	00000073          	ecall
 ret
 468:	8082                	ret

000000000000046a <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 46a:	48a1                	li	a7,8
 ecall
 46c:	00000073          	ecall
 ret
 470:	8082                	ret

0000000000000472 <link>:
.global link
link:
 li a7, SYS_link
 472:	48cd                	li	a7,19
 ecall
 474:	00000073          	ecall
 ret
 478:	8082                	ret

000000000000047a <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 47a:	48d1                	li	a7,20
 ecall
 47c:	00000073          	ecall
 ret
 480:	8082                	ret

0000000000000482 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 482:	48a5                	li	a7,9
 ecall
 484:	00000073          	ecall
 ret
 488:	8082                	ret

000000000000048a <dup>:
.global dup
dup:
 li a7, SYS_dup
 48a:	48a9                	li	a7,10
 ecall
 48c:	00000073          	ecall
 ret
 490:	8082                	ret

0000000000000492 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 492:	48ad                	li	a7,11
 ecall
 494:	00000073          	ecall
 ret
 498:	8082                	ret

000000000000049a <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 49a:	48b1                	li	a7,12
 ecall
 49c:	00000073          	ecall
 ret
 4a0:	8082                	ret

00000000000004a2 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 4a2:	48b5                	li	a7,13
 ecall
 4a4:	00000073          	ecall
 ret
 4a8:	8082                	ret

00000000000004aa <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 4aa:	48b9                	li	a7,14
 ecall
 4ac:	00000073          	ecall
 ret
 4b0:	8082                	ret

00000000000004b2 <year>:
.global year
year:
 li a7, SYS_year
 4b2:	48d9                	li	a7,22
 ecall
 4b4:	00000073          	ecall
 ret
 4b8:	8082                	ret

00000000000004ba <state>:
.global state
state:
 li a7, SYS_state
 4ba:	48e1                	li	a7,24
 ecall
 4bc:	00000073          	ecall
 ret
 4c0:	8082                	ret

00000000000004c2 <procname>:
.global procname
procname:
 li a7, SYS_procname
 4c2:	48dd                	li	a7,23
 ecall
 4c4:	00000073          	ecall
 ret
 4c8:	8082                	ret

00000000000004ca <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 4ca:	1101                	addi	sp,sp,-32
 4cc:	ec06                	sd	ra,24(sp)
 4ce:	e822                	sd	s0,16(sp)
 4d0:	1000                	addi	s0,sp,32
 4d2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 4d6:	4605                	li	a2,1
 4d8:	fef40593          	addi	a1,s0,-17
 4dc:	00000097          	auipc	ra,0x0
 4e0:	f56080e7          	jalr	-170(ra) # 432 <write>
}
 4e4:	60e2                	ld	ra,24(sp)
 4e6:	6442                	ld	s0,16(sp)
 4e8:	6105                	addi	sp,sp,32
 4ea:	8082                	ret

00000000000004ec <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 4ec:	7139                	addi	sp,sp,-64
 4ee:	fc06                	sd	ra,56(sp)
 4f0:	f822                	sd	s0,48(sp)
 4f2:	f426                	sd	s1,40(sp)
 4f4:	f04a                	sd	s2,32(sp)
 4f6:	ec4e                	sd	s3,24(sp)
 4f8:	0080                	addi	s0,sp,64
 4fa:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 4fc:	c299                	beqz	a3,502 <printint+0x16>
 4fe:	0805c963          	bltz	a1,590 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 502:	2581                	sext.w	a1,a1
  neg = 0;
 504:	4881                	li	a7,0
 506:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 50a:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 50c:	2601                	sext.w	a2,a2
 50e:	00000517          	auipc	a0,0x0
 512:	51250513          	addi	a0,a0,1298 # a20 <digits>
 516:	883a                	mv	a6,a4
 518:	2705                	addiw	a4,a4,1
 51a:	02c5f7bb          	remuw	a5,a1,a2
 51e:	1782                	slli	a5,a5,0x20
 520:	9381                	srli	a5,a5,0x20
 522:	97aa                	add	a5,a5,a0
 524:	0007c783          	lbu	a5,0(a5)
 528:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 52c:	0005879b          	sext.w	a5,a1
 530:	02c5d5bb          	divuw	a1,a1,a2
 534:	0685                	addi	a3,a3,1
 536:	fec7f0e3          	bgeu	a5,a2,516 <printint+0x2a>
  if(neg)
 53a:	00088c63          	beqz	a7,552 <printint+0x66>
    buf[i++] = '-';
 53e:	fd070793          	addi	a5,a4,-48
 542:	00878733          	add	a4,a5,s0
 546:	02d00793          	li	a5,45
 54a:	fef70823          	sb	a5,-16(a4)
 54e:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 552:	02e05863          	blez	a4,582 <printint+0x96>
 556:	fc040793          	addi	a5,s0,-64
 55a:	00e78933          	add	s2,a5,a4
 55e:	fff78993          	addi	s3,a5,-1
 562:	99ba                	add	s3,s3,a4
 564:	377d                	addiw	a4,a4,-1
 566:	1702                	slli	a4,a4,0x20
 568:	9301                	srli	a4,a4,0x20
 56a:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 56e:	fff94583          	lbu	a1,-1(s2)
 572:	8526                	mv	a0,s1
 574:	00000097          	auipc	ra,0x0
 578:	f56080e7          	jalr	-170(ra) # 4ca <putc>
  while(--i >= 0)
 57c:	197d                	addi	s2,s2,-1
 57e:	ff3918e3          	bne	s2,s3,56e <printint+0x82>
}
 582:	70e2                	ld	ra,56(sp)
 584:	7442                	ld	s0,48(sp)
 586:	74a2                	ld	s1,40(sp)
 588:	7902                	ld	s2,32(sp)
 58a:	69e2                	ld	s3,24(sp)
 58c:	6121                	addi	sp,sp,64
 58e:	8082                	ret
    x = -xx;
 590:	40b005bb          	negw	a1,a1
    neg = 1;
 594:	4885                	li	a7,1
    x = -xx;
 596:	bf85                	j	506 <printint+0x1a>

0000000000000598 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 598:	7119                	addi	sp,sp,-128
 59a:	fc86                	sd	ra,120(sp)
 59c:	f8a2                	sd	s0,112(sp)
 59e:	f4a6                	sd	s1,104(sp)
 5a0:	f0ca                	sd	s2,96(sp)
 5a2:	ecce                	sd	s3,88(sp)
 5a4:	e8d2                	sd	s4,80(sp)
 5a6:	e4d6                	sd	s5,72(sp)
 5a8:	e0da                	sd	s6,64(sp)
 5aa:	fc5e                	sd	s7,56(sp)
 5ac:	f862                	sd	s8,48(sp)
 5ae:	f466                	sd	s9,40(sp)
 5b0:	f06a                	sd	s10,32(sp)
 5b2:	ec6e                	sd	s11,24(sp)
 5b4:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 5b6:	0005c903          	lbu	s2,0(a1)
 5ba:	18090f63          	beqz	s2,758 <vprintf+0x1c0>
 5be:	8aaa                	mv	s5,a0
 5c0:	8b32                	mv	s6,a2
 5c2:	00158493          	addi	s1,a1,1
  state = 0;
 5c6:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 5c8:	02500a13          	li	s4,37
 5cc:	4c55                	li	s8,21
 5ce:	00000c97          	auipc	s9,0x0
 5d2:	3fac8c93          	addi	s9,s9,1018 # 9c8 <malloc+0x16c>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 5d6:	02800d93          	li	s11,40
  putc(fd, 'x');
 5da:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 5dc:	00000b97          	auipc	s7,0x0
 5e0:	444b8b93          	addi	s7,s7,1092 # a20 <digits>
 5e4:	a839                	j	602 <vprintf+0x6a>
        putc(fd, c);
 5e6:	85ca                	mv	a1,s2
 5e8:	8556                	mv	a0,s5
 5ea:	00000097          	auipc	ra,0x0
 5ee:	ee0080e7          	jalr	-288(ra) # 4ca <putc>
 5f2:	a019                	j	5f8 <vprintf+0x60>
    } else if(state == '%'){
 5f4:	01498d63          	beq	s3,s4,60e <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 5f8:	0485                	addi	s1,s1,1
 5fa:	fff4c903          	lbu	s2,-1(s1)
 5fe:	14090d63          	beqz	s2,758 <vprintf+0x1c0>
    if(state == 0){
 602:	fe0999e3          	bnez	s3,5f4 <vprintf+0x5c>
      if(c == '%'){
 606:	ff4910e3          	bne	s2,s4,5e6 <vprintf+0x4e>
        state = '%';
 60a:	89d2                	mv	s3,s4
 60c:	b7f5                	j	5f8 <vprintf+0x60>
      if(c == 'd'){
 60e:	11490c63          	beq	s2,s4,726 <vprintf+0x18e>
 612:	f9d9079b          	addiw	a5,s2,-99
 616:	0ff7f793          	zext.b	a5,a5
 61a:	10fc6e63          	bltu	s8,a5,736 <vprintf+0x19e>
 61e:	f9d9079b          	addiw	a5,s2,-99
 622:	0ff7f713          	zext.b	a4,a5
 626:	10ec6863          	bltu	s8,a4,736 <vprintf+0x19e>
 62a:	00271793          	slli	a5,a4,0x2
 62e:	97e6                	add	a5,a5,s9
 630:	439c                	lw	a5,0(a5)
 632:	97e6                	add	a5,a5,s9
 634:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 636:	008b0913          	addi	s2,s6,8
 63a:	4685                	li	a3,1
 63c:	4629                	li	a2,10
 63e:	000b2583          	lw	a1,0(s6)
 642:	8556                	mv	a0,s5
 644:	00000097          	auipc	ra,0x0
 648:	ea8080e7          	jalr	-344(ra) # 4ec <printint>
 64c:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 64e:	4981                	li	s3,0
 650:	b765                	j	5f8 <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 652:	008b0913          	addi	s2,s6,8
 656:	4681                	li	a3,0
 658:	4629                	li	a2,10
 65a:	000b2583          	lw	a1,0(s6)
 65e:	8556                	mv	a0,s5
 660:	00000097          	auipc	ra,0x0
 664:	e8c080e7          	jalr	-372(ra) # 4ec <printint>
 668:	8b4a                	mv	s6,s2
      state = 0;
 66a:	4981                	li	s3,0
 66c:	b771                	j	5f8 <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 66e:	008b0913          	addi	s2,s6,8
 672:	4681                	li	a3,0
 674:	866a                	mv	a2,s10
 676:	000b2583          	lw	a1,0(s6)
 67a:	8556                	mv	a0,s5
 67c:	00000097          	auipc	ra,0x0
 680:	e70080e7          	jalr	-400(ra) # 4ec <printint>
 684:	8b4a                	mv	s6,s2
      state = 0;
 686:	4981                	li	s3,0
 688:	bf85                	j	5f8 <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 68a:	008b0793          	addi	a5,s6,8
 68e:	f8f43423          	sd	a5,-120(s0)
 692:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 696:	03000593          	li	a1,48
 69a:	8556                	mv	a0,s5
 69c:	00000097          	auipc	ra,0x0
 6a0:	e2e080e7          	jalr	-466(ra) # 4ca <putc>
  putc(fd, 'x');
 6a4:	07800593          	li	a1,120
 6a8:	8556                	mv	a0,s5
 6aa:	00000097          	auipc	ra,0x0
 6ae:	e20080e7          	jalr	-480(ra) # 4ca <putc>
 6b2:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6b4:	03c9d793          	srli	a5,s3,0x3c
 6b8:	97de                	add	a5,a5,s7
 6ba:	0007c583          	lbu	a1,0(a5)
 6be:	8556                	mv	a0,s5
 6c0:	00000097          	auipc	ra,0x0
 6c4:	e0a080e7          	jalr	-502(ra) # 4ca <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6c8:	0992                	slli	s3,s3,0x4
 6ca:	397d                	addiw	s2,s2,-1
 6cc:	fe0914e3          	bnez	s2,6b4 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 6d0:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 6d4:	4981                	li	s3,0
 6d6:	b70d                	j	5f8 <vprintf+0x60>
        s = va_arg(ap, char*);
 6d8:	008b0913          	addi	s2,s6,8
 6dc:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 6e0:	02098163          	beqz	s3,702 <vprintf+0x16a>
        while(*s != 0){
 6e4:	0009c583          	lbu	a1,0(s3)
 6e8:	c5ad                	beqz	a1,752 <vprintf+0x1ba>
          putc(fd, *s);
 6ea:	8556                	mv	a0,s5
 6ec:	00000097          	auipc	ra,0x0
 6f0:	dde080e7          	jalr	-546(ra) # 4ca <putc>
          s++;
 6f4:	0985                	addi	s3,s3,1
        while(*s != 0){
 6f6:	0009c583          	lbu	a1,0(s3)
 6fa:	f9e5                	bnez	a1,6ea <vprintf+0x152>
        s = va_arg(ap, char*);
 6fc:	8b4a                	mv	s6,s2
      state = 0;
 6fe:	4981                	li	s3,0
 700:	bde5                	j	5f8 <vprintf+0x60>
          s = "(null)";
 702:	00000997          	auipc	s3,0x0
 706:	2be98993          	addi	s3,s3,702 # 9c0 <malloc+0x164>
        while(*s != 0){
 70a:	85ee                	mv	a1,s11
 70c:	bff9                	j	6ea <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 70e:	008b0913          	addi	s2,s6,8
 712:	000b4583          	lbu	a1,0(s6)
 716:	8556                	mv	a0,s5
 718:	00000097          	auipc	ra,0x0
 71c:	db2080e7          	jalr	-590(ra) # 4ca <putc>
 720:	8b4a                	mv	s6,s2
      state = 0;
 722:	4981                	li	s3,0
 724:	bdd1                	j	5f8 <vprintf+0x60>
        putc(fd, c);
 726:	85d2                	mv	a1,s4
 728:	8556                	mv	a0,s5
 72a:	00000097          	auipc	ra,0x0
 72e:	da0080e7          	jalr	-608(ra) # 4ca <putc>
      state = 0;
 732:	4981                	li	s3,0
 734:	b5d1                	j	5f8 <vprintf+0x60>
        putc(fd, '%');
 736:	85d2                	mv	a1,s4
 738:	8556                	mv	a0,s5
 73a:	00000097          	auipc	ra,0x0
 73e:	d90080e7          	jalr	-624(ra) # 4ca <putc>
        putc(fd, c);
 742:	85ca                	mv	a1,s2
 744:	8556                	mv	a0,s5
 746:	00000097          	auipc	ra,0x0
 74a:	d84080e7          	jalr	-636(ra) # 4ca <putc>
      state = 0;
 74e:	4981                	li	s3,0
 750:	b565                	j	5f8 <vprintf+0x60>
        s = va_arg(ap, char*);
 752:	8b4a                	mv	s6,s2
      state = 0;
 754:	4981                	li	s3,0
 756:	b54d                	j	5f8 <vprintf+0x60>
    }
  }
}
 758:	70e6                	ld	ra,120(sp)
 75a:	7446                	ld	s0,112(sp)
 75c:	74a6                	ld	s1,104(sp)
 75e:	7906                	ld	s2,96(sp)
 760:	69e6                	ld	s3,88(sp)
 762:	6a46                	ld	s4,80(sp)
 764:	6aa6                	ld	s5,72(sp)
 766:	6b06                	ld	s6,64(sp)
 768:	7be2                	ld	s7,56(sp)
 76a:	7c42                	ld	s8,48(sp)
 76c:	7ca2                	ld	s9,40(sp)
 76e:	7d02                	ld	s10,32(sp)
 770:	6de2                	ld	s11,24(sp)
 772:	6109                	addi	sp,sp,128
 774:	8082                	ret

0000000000000776 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 776:	715d                	addi	sp,sp,-80
 778:	ec06                	sd	ra,24(sp)
 77a:	e822                	sd	s0,16(sp)
 77c:	1000                	addi	s0,sp,32
 77e:	e010                	sd	a2,0(s0)
 780:	e414                	sd	a3,8(s0)
 782:	e818                	sd	a4,16(s0)
 784:	ec1c                	sd	a5,24(s0)
 786:	03043023          	sd	a6,32(s0)
 78a:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 78e:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 792:	8622                	mv	a2,s0
 794:	00000097          	auipc	ra,0x0
 798:	e04080e7          	jalr	-508(ra) # 598 <vprintf>
}
 79c:	60e2                	ld	ra,24(sp)
 79e:	6442                	ld	s0,16(sp)
 7a0:	6161                	addi	sp,sp,80
 7a2:	8082                	ret

00000000000007a4 <printf>:

void
printf(const char *fmt, ...)
{
 7a4:	711d                	addi	sp,sp,-96
 7a6:	ec06                	sd	ra,24(sp)
 7a8:	e822                	sd	s0,16(sp)
 7aa:	1000                	addi	s0,sp,32
 7ac:	e40c                	sd	a1,8(s0)
 7ae:	e810                	sd	a2,16(s0)
 7b0:	ec14                	sd	a3,24(s0)
 7b2:	f018                	sd	a4,32(s0)
 7b4:	f41c                	sd	a5,40(s0)
 7b6:	03043823          	sd	a6,48(s0)
 7ba:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 7be:	00840613          	addi	a2,s0,8
 7c2:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 7c6:	85aa                	mv	a1,a0
 7c8:	4505                	li	a0,1
 7ca:	00000097          	auipc	ra,0x0
 7ce:	dce080e7          	jalr	-562(ra) # 598 <vprintf>
}
 7d2:	60e2                	ld	ra,24(sp)
 7d4:	6442                	ld	s0,16(sp)
 7d6:	6125                	addi	sp,sp,96
 7d8:	8082                	ret

00000000000007da <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 7da:	1141                	addi	sp,sp,-16
 7dc:	e422                	sd	s0,8(sp)
 7de:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7e0:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7e4:	00001797          	auipc	a5,0x1
 7e8:	81c7b783          	ld	a5,-2020(a5) # 1000 <freep>
 7ec:	a02d                	j	816 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7ee:	4618                	lw	a4,8(a2)
 7f0:	9f2d                	addw	a4,a4,a1
 7f2:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7f6:	6398                	ld	a4,0(a5)
 7f8:	6310                	ld	a2,0(a4)
 7fa:	a83d                	j	838 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7fc:	ff852703          	lw	a4,-8(a0)
 800:	9f31                	addw	a4,a4,a2
 802:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 804:	ff053683          	ld	a3,-16(a0)
 808:	a091                	j	84c <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 80a:	6398                	ld	a4,0(a5)
 80c:	00e7e463          	bltu	a5,a4,814 <free+0x3a>
 810:	00e6ea63          	bltu	a3,a4,824 <free+0x4a>
{
 814:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 816:	fed7fae3          	bgeu	a5,a3,80a <free+0x30>
 81a:	6398                	ld	a4,0(a5)
 81c:	00e6e463          	bltu	a3,a4,824 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 820:	fee7eae3          	bltu	a5,a4,814 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 824:	ff852583          	lw	a1,-8(a0)
 828:	6390                	ld	a2,0(a5)
 82a:	02059813          	slli	a6,a1,0x20
 82e:	01c85713          	srli	a4,a6,0x1c
 832:	9736                	add	a4,a4,a3
 834:	fae60de3          	beq	a2,a4,7ee <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 838:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 83c:	4790                	lw	a2,8(a5)
 83e:	02061593          	slli	a1,a2,0x20
 842:	01c5d713          	srli	a4,a1,0x1c
 846:	973e                	add	a4,a4,a5
 848:	fae68ae3          	beq	a3,a4,7fc <free+0x22>
    p->s.ptr = bp->s.ptr;
 84c:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 84e:	00000717          	auipc	a4,0x0
 852:	7af73923          	sd	a5,1970(a4) # 1000 <freep>
}
 856:	6422                	ld	s0,8(sp)
 858:	0141                	addi	sp,sp,16
 85a:	8082                	ret

000000000000085c <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 85c:	7139                	addi	sp,sp,-64
 85e:	fc06                	sd	ra,56(sp)
 860:	f822                	sd	s0,48(sp)
 862:	f426                	sd	s1,40(sp)
 864:	f04a                	sd	s2,32(sp)
 866:	ec4e                	sd	s3,24(sp)
 868:	e852                	sd	s4,16(sp)
 86a:	e456                	sd	s5,8(sp)
 86c:	e05a                	sd	s6,0(sp)
 86e:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 870:	02051493          	slli	s1,a0,0x20
 874:	9081                	srli	s1,s1,0x20
 876:	04bd                	addi	s1,s1,15
 878:	8091                	srli	s1,s1,0x4
 87a:	0014899b          	addiw	s3,s1,1
 87e:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 880:	00000517          	auipc	a0,0x0
 884:	78053503          	ld	a0,1920(a0) # 1000 <freep>
 888:	c515                	beqz	a0,8b4 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 88a:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 88c:	4798                	lw	a4,8(a5)
 88e:	02977f63          	bgeu	a4,s1,8cc <malloc+0x70>
 892:	8a4e                	mv	s4,s3
 894:	0009871b          	sext.w	a4,s3
 898:	6685                	lui	a3,0x1
 89a:	00d77363          	bgeu	a4,a3,8a0 <malloc+0x44>
 89e:	6a05                	lui	s4,0x1
 8a0:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 8a4:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 8a8:	00000917          	auipc	s2,0x0
 8ac:	75890913          	addi	s2,s2,1880 # 1000 <freep>
  if(p == (char*)-1)
 8b0:	5afd                	li	s5,-1
 8b2:	a895                	j	926 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 8b4:	00000797          	auipc	a5,0x0
 8b8:	75c78793          	addi	a5,a5,1884 # 1010 <base>
 8bc:	00000717          	auipc	a4,0x0
 8c0:	74f73223          	sd	a5,1860(a4) # 1000 <freep>
 8c4:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 8c6:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 8ca:	b7e1                	j	892 <malloc+0x36>
      if(p->s.size == nunits)
 8cc:	02e48c63          	beq	s1,a4,904 <malloc+0xa8>
        p->s.size -= nunits;
 8d0:	4137073b          	subw	a4,a4,s3
 8d4:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8d6:	02071693          	slli	a3,a4,0x20
 8da:	01c6d713          	srli	a4,a3,0x1c
 8de:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8e0:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8e4:	00000717          	auipc	a4,0x0
 8e8:	70a73e23          	sd	a0,1820(a4) # 1000 <freep>
      return (void*)(p + 1);
 8ec:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 8f0:	70e2                	ld	ra,56(sp)
 8f2:	7442                	ld	s0,48(sp)
 8f4:	74a2                	ld	s1,40(sp)
 8f6:	7902                	ld	s2,32(sp)
 8f8:	69e2                	ld	s3,24(sp)
 8fa:	6a42                	ld	s4,16(sp)
 8fc:	6aa2                	ld	s5,8(sp)
 8fe:	6b02                	ld	s6,0(sp)
 900:	6121                	addi	sp,sp,64
 902:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 904:	6398                	ld	a4,0(a5)
 906:	e118                	sd	a4,0(a0)
 908:	bff1                	j	8e4 <malloc+0x88>
  hp->s.size = nu;
 90a:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 90e:	0541                	addi	a0,a0,16
 910:	00000097          	auipc	ra,0x0
 914:	eca080e7          	jalr	-310(ra) # 7da <free>
  return freep;
 918:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 91c:	d971                	beqz	a0,8f0 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 91e:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 920:	4798                	lw	a4,8(a5)
 922:	fa9775e3          	bgeu	a4,s1,8cc <malloc+0x70>
    if(p == freep)
 926:	00093703          	ld	a4,0(s2)
 92a:	853e                	mv	a0,a5
 92c:	fef719e3          	bne	a4,a5,91e <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 930:	8552                	mv	a0,s4
 932:	00000097          	auipc	ra,0x0
 936:	b68080e7          	jalr	-1176(ra) # 49a <sbrk>
  if(p == (char*)-1)
 93a:	fd5518e3          	bne	a0,s5,90a <malloc+0xae>
        return 0;
 93e:	4501                	li	a0,0
 940:	bf45                	j	8f0 <malloc+0x94>
