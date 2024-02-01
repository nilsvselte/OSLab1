
user/_hello:     file format elf64-littleriscv


Disassembly of section .text:

0000000000000000 <main>:
#include "kernel/types.h"
#include "user/user.h"

int main(int argc, char *argv[]) {
   0:	1141                	addi	sp,sp,-16
   2:	e406                	sd	ra,8(sp)
   4:	e022                	sd	s0,0(sp)
   6:	0800                	addi	s0,sp,16
    if (argc < 2) {
   8:	4785                	li	a5,1
   a:	02a7d063          	bge	a5,a0,2a <main+0x2a>
        printf("Hello World.\n");
        return 1;
    }

    printf("\n Hello, %s!\n", argv[1]);
   e:	658c                	ld	a1,8(a1)
  10:	00000517          	auipc	a0,0x0
  14:	7f050513          	addi	a0,a0,2032 # 800 <malloc+0x102>
  18:	00000097          	auipc	ra,0x0
  1c:	62e080e7          	jalr	1582(ra) # 646 <printf>
    return 0;
  20:	4501                	li	a0,0
}
  22:	60a2                	ld	ra,8(sp)
  24:	6402                	ld	s0,0(sp)
  26:	0141                	addi	sp,sp,16
  28:	8082                	ret
        printf("Hello World.\n");
  2a:	00000517          	auipc	a0,0x0
  2e:	7c650513          	addi	a0,a0,1990 # 7f0 <malloc+0xf2>
  32:	00000097          	auipc	ra,0x0
  36:	614080e7          	jalr	1556(ra) # 646 <printf>
        return 1;
  3a:	4505                	li	a0,1
  3c:	b7dd                	j	22 <main+0x22>

000000000000003e <_main>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
_main()
{
  3e:	1141                	addi	sp,sp,-16
  40:	e406                	sd	ra,8(sp)
  42:	e022                	sd	s0,0(sp)
  44:	0800                	addi	s0,sp,16
  extern int main();
  main();
  46:	00000097          	auipc	ra,0x0
  4a:	fba080e7          	jalr	-70(ra) # 0 <main>
  exit(0);
  4e:	4501                	li	a0,0
  50:	00000097          	auipc	ra,0x0
  54:	274080e7          	jalr	628(ra) # 2c4 <exit>

0000000000000058 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  58:	1141                	addi	sp,sp,-16
  5a:	e422                	sd	s0,8(sp)
  5c:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  5e:	87aa                	mv	a5,a0
  60:	0585                	addi	a1,a1,1
  62:	0785                	addi	a5,a5,1
  64:	fff5c703          	lbu	a4,-1(a1)
  68:	fee78fa3          	sb	a4,-1(a5)
  6c:	fb75                	bnez	a4,60 <strcpy+0x8>
    ;
  return os;
}
  6e:	6422                	ld	s0,8(sp)
  70:	0141                	addi	sp,sp,16
  72:	8082                	ret

0000000000000074 <strcmp>:

int
strcmp(const char *p, const char *q)
{
  74:	1141                	addi	sp,sp,-16
  76:	e422                	sd	s0,8(sp)
  78:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  7a:	00054783          	lbu	a5,0(a0)
  7e:	cb91                	beqz	a5,92 <strcmp+0x1e>
  80:	0005c703          	lbu	a4,0(a1)
  84:	00f71763          	bne	a4,a5,92 <strcmp+0x1e>
    p++, q++;
  88:	0505                	addi	a0,a0,1
  8a:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  8c:	00054783          	lbu	a5,0(a0)
  90:	fbe5                	bnez	a5,80 <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  92:	0005c503          	lbu	a0,0(a1)
}
  96:	40a7853b          	subw	a0,a5,a0
  9a:	6422                	ld	s0,8(sp)
  9c:	0141                	addi	sp,sp,16
  9e:	8082                	ret

00000000000000a0 <strlen>:

uint
strlen(const char *s)
{
  a0:	1141                	addi	sp,sp,-16
  a2:	e422                	sd	s0,8(sp)
  a4:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
  a6:	00054783          	lbu	a5,0(a0)
  aa:	cf91                	beqz	a5,c6 <strlen+0x26>
  ac:	0505                	addi	a0,a0,1
  ae:	87aa                	mv	a5,a0
  b0:	4685                	li	a3,1
  b2:	9e89                	subw	a3,a3,a0
  b4:	00f6853b          	addw	a0,a3,a5
  b8:	0785                	addi	a5,a5,1
  ba:	fff7c703          	lbu	a4,-1(a5)
  be:	fb7d                	bnez	a4,b4 <strlen+0x14>
    ;
  return n;
}
  c0:	6422                	ld	s0,8(sp)
  c2:	0141                	addi	sp,sp,16
  c4:	8082                	ret
  for(n = 0; s[n]; n++)
  c6:	4501                	li	a0,0
  c8:	bfe5                	j	c0 <strlen+0x20>

00000000000000ca <memset>:

void*
memset(void *dst, int c, uint n)
{
  ca:	1141                	addi	sp,sp,-16
  cc:	e422                	sd	s0,8(sp)
  ce:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
  d0:	ca19                	beqz	a2,e6 <memset+0x1c>
  d2:	87aa                	mv	a5,a0
  d4:	1602                	slli	a2,a2,0x20
  d6:	9201                	srli	a2,a2,0x20
  d8:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
  dc:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
  e0:	0785                	addi	a5,a5,1
  e2:	fee79de3          	bne	a5,a4,dc <memset+0x12>
  }
  return dst;
}
  e6:	6422                	ld	s0,8(sp)
  e8:	0141                	addi	sp,sp,16
  ea:	8082                	ret

00000000000000ec <strchr>:

char*
strchr(const char *s, char c)
{
  ec:	1141                	addi	sp,sp,-16
  ee:	e422                	sd	s0,8(sp)
  f0:	0800                	addi	s0,sp,16
  for(; *s; s++)
  f2:	00054783          	lbu	a5,0(a0)
  f6:	cb99                	beqz	a5,10c <strchr+0x20>
    if(*s == c)
  f8:	00f58763          	beq	a1,a5,106 <strchr+0x1a>
  for(; *s; s++)
  fc:	0505                	addi	a0,a0,1
  fe:	00054783          	lbu	a5,0(a0)
 102:	fbfd                	bnez	a5,f8 <strchr+0xc>
      return (char*)s;
  return 0;
 104:	4501                	li	a0,0
}
 106:	6422                	ld	s0,8(sp)
 108:	0141                	addi	sp,sp,16
 10a:	8082                	ret
  return 0;
 10c:	4501                	li	a0,0
 10e:	bfe5                	j	106 <strchr+0x1a>

0000000000000110 <gets>:

char*
gets(char *buf, int max)
{
 110:	711d                	addi	sp,sp,-96
 112:	ec86                	sd	ra,88(sp)
 114:	e8a2                	sd	s0,80(sp)
 116:	e4a6                	sd	s1,72(sp)
 118:	e0ca                	sd	s2,64(sp)
 11a:	fc4e                	sd	s3,56(sp)
 11c:	f852                	sd	s4,48(sp)
 11e:	f456                	sd	s5,40(sp)
 120:	f05a                	sd	s6,32(sp)
 122:	ec5e                	sd	s7,24(sp)
 124:	1080                	addi	s0,sp,96
 126:	8baa                	mv	s7,a0
 128:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 12a:	892a                	mv	s2,a0
 12c:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 12e:	4aa9                	li	s5,10
 130:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 132:	89a6                	mv	s3,s1
 134:	2485                	addiw	s1,s1,1
 136:	0344d863          	bge	s1,s4,166 <gets+0x56>
    cc = read(0, &c, 1);
 13a:	4605                	li	a2,1
 13c:	faf40593          	addi	a1,s0,-81
 140:	4501                	li	a0,0
 142:	00000097          	auipc	ra,0x0
 146:	19a080e7          	jalr	410(ra) # 2dc <read>
    if(cc < 1)
 14a:	00a05e63          	blez	a0,166 <gets+0x56>
    buf[i++] = c;
 14e:	faf44783          	lbu	a5,-81(s0)
 152:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 156:	01578763          	beq	a5,s5,164 <gets+0x54>
 15a:	0905                	addi	s2,s2,1
 15c:	fd679be3          	bne	a5,s6,132 <gets+0x22>
  for(i=0; i+1 < max; ){
 160:	89a6                	mv	s3,s1
 162:	a011                	j	166 <gets+0x56>
 164:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 166:	99de                	add	s3,s3,s7
 168:	00098023          	sb	zero,0(s3)
  return buf;
}
 16c:	855e                	mv	a0,s7
 16e:	60e6                	ld	ra,88(sp)
 170:	6446                	ld	s0,80(sp)
 172:	64a6                	ld	s1,72(sp)
 174:	6906                	ld	s2,64(sp)
 176:	79e2                	ld	s3,56(sp)
 178:	7a42                	ld	s4,48(sp)
 17a:	7aa2                	ld	s5,40(sp)
 17c:	7b02                	ld	s6,32(sp)
 17e:	6be2                	ld	s7,24(sp)
 180:	6125                	addi	sp,sp,96
 182:	8082                	ret

0000000000000184 <stat>:

int
stat(const char *n, struct stat *st)
{
 184:	1101                	addi	sp,sp,-32
 186:	ec06                	sd	ra,24(sp)
 188:	e822                	sd	s0,16(sp)
 18a:	e426                	sd	s1,8(sp)
 18c:	e04a                	sd	s2,0(sp)
 18e:	1000                	addi	s0,sp,32
 190:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 192:	4581                	li	a1,0
 194:	00000097          	auipc	ra,0x0
 198:	170080e7          	jalr	368(ra) # 304 <open>
  if(fd < 0)
 19c:	02054563          	bltz	a0,1c6 <stat+0x42>
 1a0:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 1a2:	85ca                	mv	a1,s2
 1a4:	00000097          	auipc	ra,0x0
 1a8:	178080e7          	jalr	376(ra) # 31c <fstat>
 1ac:	892a                	mv	s2,a0
  close(fd);
 1ae:	8526                	mv	a0,s1
 1b0:	00000097          	auipc	ra,0x0
 1b4:	13c080e7          	jalr	316(ra) # 2ec <close>
  return r;
}
 1b8:	854a                	mv	a0,s2
 1ba:	60e2                	ld	ra,24(sp)
 1bc:	6442                	ld	s0,16(sp)
 1be:	64a2                	ld	s1,8(sp)
 1c0:	6902                	ld	s2,0(sp)
 1c2:	6105                	addi	sp,sp,32
 1c4:	8082                	ret
    return -1;
 1c6:	597d                	li	s2,-1
 1c8:	bfc5                	j	1b8 <stat+0x34>

00000000000001ca <atoi>:

int
atoi(const char *s)
{
 1ca:	1141                	addi	sp,sp,-16
 1cc:	e422                	sd	s0,8(sp)
 1ce:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 1d0:	00054683          	lbu	a3,0(a0)
 1d4:	fd06879b          	addiw	a5,a3,-48
 1d8:	0ff7f793          	zext.b	a5,a5
 1dc:	4625                	li	a2,9
 1de:	02f66863          	bltu	a2,a5,20e <atoi+0x44>
 1e2:	872a                	mv	a4,a0
  n = 0;
 1e4:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 1e6:	0705                	addi	a4,a4,1
 1e8:	0025179b          	slliw	a5,a0,0x2
 1ec:	9fa9                	addw	a5,a5,a0
 1ee:	0017979b          	slliw	a5,a5,0x1
 1f2:	9fb5                	addw	a5,a5,a3
 1f4:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 1f8:	00074683          	lbu	a3,0(a4)
 1fc:	fd06879b          	addiw	a5,a3,-48
 200:	0ff7f793          	zext.b	a5,a5
 204:	fef671e3          	bgeu	a2,a5,1e6 <atoi+0x1c>
  return n;
}
 208:	6422                	ld	s0,8(sp)
 20a:	0141                	addi	sp,sp,16
 20c:	8082                	ret
  n = 0;
 20e:	4501                	li	a0,0
 210:	bfe5                	j	208 <atoi+0x3e>

0000000000000212 <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 212:	1141                	addi	sp,sp,-16
 214:	e422                	sd	s0,8(sp)
 216:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 218:	02b57463          	bgeu	a0,a1,240 <memmove+0x2e>
    while(n-- > 0)
 21c:	00c05f63          	blez	a2,23a <memmove+0x28>
 220:	1602                	slli	a2,a2,0x20
 222:	9201                	srli	a2,a2,0x20
 224:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 228:	872a                	mv	a4,a0
      *dst++ = *src++;
 22a:	0585                	addi	a1,a1,1
 22c:	0705                	addi	a4,a4,1
 22e:	fff5c683          	lbu	a3,-1(a1)
 232:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 236:	fee79ae3          	bne	a5,a4,22a <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 23a:	6422                	ld	s0,8(sp)
 23c:	0141                	addi	sp,sp,16
 23e:	8082                	ret
    dst += n;
 240:	00c50733          	add	a4,a0,a2
    src += n;
 244:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 246:	fec05ae3          	blez	a2,23a <memmove+0x28>
 24a:	fff6079b          	addiw	a5,a2,-1
 24e:	1782                	slli	a5,a5,0x20
 250:	9381                	srli	a5,a5,0x20
 252:	fff7c793          	not	a5,a5
 256:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 258:	15fd                	addi	a1,a1,-1
 25a:	177d                	addi	a4,a4,-1
 25c:	0005c683          	lbu	a3,0(a1)
 260:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 264:	fee79ae3          	bne	a5,a4,258 <memmove+0x46>
 268:	bfc9                	j	23a <memmove+0x28>

000000000000026a <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 26a:	1141                	addi	sp,sp,-16
 26c:	e422                	sd	s0,8(sp)
 26e:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 270:	ca05                	beqz	a2,2a0 <memcmp+0x36>
 272:	fff6069b          	addiw	a3,a2,-1
 276:	1682                	slli	a3,a3,0x20
 278:	9281                	srli	a3,a3,0x20
 27a:	0685                	addi	a3,a3,1
 27c:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 27e:	00054783          	lbu	a5,0(a0)
 282:	0005c703          	lbu	a4,0(a1)
 286:	00e79863          	bne	a5,a4,296 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 28a:	0505                	addi	a0,a0,1
    p2++;
 28c:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 28e:	fed518e3          	bne	a0,a3,27e <memcmp+0x14>
  }
  return 0;
 292:	4501                	li	a0,0
 294:	a019                	j	29a <memcmp+0x30>
      return *p1 - *p2;
 296:	40e7853b          	subw	a0,a5,a4
}
 29a:	6422                	ld	s0,8(sp)
 29c:	0141                	addi	sp,sp,16
 29e:	8082                	ret
  return 0;
 2a0:	4501                	li	a0,0
 2a2:	bfe5                	j	29a <memcmp+0x30>

00000000000002a4 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2a4:	1141                	addi	sp,sp,-16
 2a6:	e406                	sd	ra,8(sp)
 2a8:	e022                	sd	s0,0(sp)
 2aa:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 2ac:	00000097          	auipc	ra,0x0
 2b0:	f66080e7          	jalr	-154(ra) # 212 <memmove>
}
 2b4:	60a2                	ld	ra,8(sp)
 2b6:	6402                	ld	s0,0(sp)
 2b8:	0141                	addi	sp,sp,16
 2ba:	8082                	ret

00000000000002bc <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 2bc:	4885                	li	a7,1
 ecall
 2be:	00000073          	ecall
 ret
 2c2:	8082                	ret

00000000000002c4 <exit>:
.global exit
exit:
 li a7, SYS_exit
 2c4:	4889                	li	a7,2
 ecall
 2c6:	00000073          	ecall
 ret
 2ca:	8082                	ret

00000000000002cc <wait>:
.global wait
wait:
 li a7, SYS_wait
 2cc:	488d                	li	a7,3
 ecall
 2ce:	00000073          	ecall
 ret
 2d2:	8082                	ret

00000000000002d4 <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 2d4:	4891                	li	a7,4
 ecall
 2d6:	00000073          	ecall
 ret
 2da:	8082                	ret

00000000000002dc <read>:
.global read
read:
 li a7, SYS_read
 2dc:	4895                	li	a7,5
 ecall
 2de:	00000073          	ecall
 ret
 2e2:	8082                	ret

00000000000002e4 <write>:
.global write
write:
 li a7, SYS_write
 2e4:	48c1                	li	a7,16
 ecall
 2e6:	00000073          	ecall
 ret
 2ea:	8082                	ret

00000000000002ec <close>:
.global close
close:
 li a7, SYS_close
 2ec:	48d5                	li	a7,21
 ecall
 2ee:	00000073          	ecall
 ret
 2f2:	8082                	ret

00000000000002f4 <kill>:
.global kill
kill:
 li a7, SYS_kill
 2f4:	4899                	li	a7,6
 ecall
 2f6:	00000073          	ecall
 ret
 2fa:	8082                	ret

00000000000002fc <exec>:
.global exec
exec:
 li a7, SYS_exec
 2fc:	489d                	li	a7,7
 ecall
 2fe:	00000073          	ecall
 ret
 302:	8082                	ret

0000000000000304 <open>:
.global open
open:
 li a7, SYS_open
 304:	48bd                	li	a7,15
 ecall
 306:	00000073          	ecall
 ret
 30a:	8082                	ret

000000000000030c <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 30c:	48c5                	li	a7,17
 ecall
 30e:	00000073          	ecall
 ret
 312:	8082                	ret

0000000000000314 <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 314:	48c9                	li	a7,18
 ecall
 316:	00000073          	ecall
 ret
 31a:	8082                	ret

000000000000031c <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 31c:	48a1                	li	a7,8
 ecall
 31e:	00000073          	ecall
 ret
 322:	8082                	ret

0000000000000324 <link>:
.global link
link:
 li a7, SYS_link
 324:	48cd                	li	a7,19
 ecall
 326:	00000073          	ecall
 ret
 32a:	8082                	ret

000000000000032c <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 32c:	48d1                	li	a7,20
 ecall
 32e:	00000073          	ecall
 ret
 332:	8082                	ret

0000000000000334 <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 334:	48a5                	li	a7,9
 ecall
 336:	00000073          	ecall
 ret
 33a:	8082                	ret

000000000000033c <dup>:
.global dup
dup:
 li a7, SYS_dup
 33c:	48a9                	li	a7,10
 ecall
 33e:	00000073          	ecall
 ret
 342:	8082                	ret

0000000000000344 <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 344:	48ad                	li	a7,11
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 34c:	48b1                	li	a7,12
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 354:	48b5                	li	a7,13
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 35c:	48b9                	li	a7,14
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <year>:
.global year
year:
 li a7, SYS_year
 364:	48d9                	li	a7,22
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 36c:	1101                	addi	sp,sp,-32
 36e:	ec06                	sd	ra,24(sp)
 370:	e822                	sd	s0,16(sp)
 372:	1000                	addi	s0,sp,32
 374:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 378:	4605                	li	a2,1
 37a:	fef40593          	addi	a1,s0,-17
 37e:	00000097          	auipc	ra,0x0
 382:	f66080e7          	jalr	-154(ra) # 2e4 <write>
}
 386:	60e2                	ld	ra,24(sp)
 388:	6442                	ld	s0,16(sp)
 38a:	6105                	addi	sp,sp,32
 38c:	8082                	ret

000000000000038e <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 38e:	7139                	addi	sp,sp,-64
 390:	fc06                	sd	ra,56(sp)
 392:	f822                	sd	s0,48(sp)
 394:	f426                	sd	s1,40(sp)
 396:	f04a                	sd	s2,32(sp)
 398:	ec4e                	sd	s3,24(sp)
 39a:	0080                	addi	s0,sp,64
 39c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 39e:	c299                	beqz	a3,3a4 <printint+0x16>
 3a0:	0805c963          	bltz	a1,432 <printint+0xa4>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3a4:	2581                	sext.w	a1,a1
  neg = 0;
 3a6:	4881                	li	a7,0
 3a8:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3ac:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3ae:	2601                	sext.w	a2,a2
 3b0:	00000517          	auipc	a0,0x0
 3b4:	4c050513          	addi	a0,a0,1216 # 870 <digits>
 3b8:	883a                	mv	a6,a4
 3ba:	2705                	addiw	a4,a4,1
 3bc:	02c5f7bb          	remuw	a5,a1,a2
 3c0:	1782                	slli	a5,a5,0x20
 3c2:	9381                	srli	a5,a5,0x20
 3c4:	97aa                	add	a5,a5,a0
 3c6:	0007c783          	lbu	a5,0(a5)
 3ca:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 3ce:	0005879b          	sext.w	a5,a1
 3d2:	02c5d5bb          	divuw	a1,a1,a2
 3d6:	0685                	addi	a3,a3,1
 3d8:	fec7f0e3          	bgeu	a5,a2,3b8 <printint+0x2a>
  if(neg)
 3dc:	00088c63          	beqz	a7,3f4 <printint+0x66>
    buf[i++] = '-';
 3e0:	fd070793          	addi	a5,a4,-48
 3e4:	00878733          	add	a4,a5,s0
 3e8:	02d00793          	li	a5,45
 3ec:	fef70823          	sb	a5,-16(a4)
 3f0:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 3f4:	02e05863          	blez	a4,424 <printint+0x96>
 3f8:	fc040793          	addi	a5,s0,-64
 3fc:	00e78933          	add	s2,a5,a4
 400:	fff78993          	addi	s3,a5,-1
 404:	99ba                	add	s3,s3,a4
 406:	377d                	addiw	a4,a4,-1
 408:	1702                	slli	a4,a4,0x20
 40a:	9301                	srli	a4,a4,0x20
 40c:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 410:	fff94583          	lbu	a1,-1(s2)
 414:	8526                	mv	a0,s1
 416:	00000097          	auipc	ra,0x0
 41a:	f56080e7          	jalr	-170(ra) # 36c <putc>
  while(--i >= 0)
 41e:	197d                	addi	s2,s2,-1
 420:	ff3918e3          	bne	s2,s3,410 <printint+0x82>
}
 424:	70e2                	ld	ra,56(sp)
 426:	7442                	ld	s0,48(sp)
 428:	74a2                	ld	s1,40(sp)
 42a:	7902                	ld	s2,32(sp)
 42c:	69e2                	ld	s3,24(sp)
 42e:	6121                	addi	sp,sp,64
 430:	8082                	ret
    x = -xx;
 432:	40b005bb          	negw	a1,a1
    neg = 1;
 436:	4885                	li	a7,1
    x = -xx;
 438:	bf85                	j	3a8 <printint+0x1a>

000000000000043a <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 43a:	7119                	addi	sp,sp,-128
 43c:	fc86                	sd	ra,120(sp)
 43e:	f8a2                	sd	s0,112(sp)
 440:	f4a6                	sd	s1,104(sp)
 442:	f0ca                	sd	s2,96(sp)
 444:	ecce                	sd	s3,88(sp)
 446:	e8d2                	sd	s4,80(sp)
 448:	e4d6                	sd	s5,72(sp)
 44a:	e0da                	sd	s6,64(sp)
 44c:	fc5e                	sd	s7,56(sp)
 44e:	f862                	sd	s8,48(sp)
 450:	f466                	sd	s9,40(sp)
 452:	f06a                	sd	s10,32(sp)
 454:	ec6e                	sd	s11,24(sp)
 456:	0100                	addi	s0,sp,128
  char *s;
  int c, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 458:	0005c903          	lbu	s2,0(a1)
 45c:	18090f63          	beqz	s2,5fa <vprintf+0x1c0>
 460:	8aaa                	mv	s5,a0
 462:	8b32                	mv	s6,a2
 464:	00158493          	addi	s1,a1,1
  state = 0;
 468:	4981                	li	s3,0
      if(c == '%'){
        state = '%';
      } else {
        putc(fd, c);
      }
    } else if(state == '%'){
 46a:	02500a13          	li	s4,37
 46e:	4c55                	li	s8,21
 470:	00000c97          	auipc	s9,0x0
 474:	3a8c8c93          	addi	s9,s9,936 # 818 <malloc+0x11a>
        printptr(fd, va_arg(ap, uint64));
      } else if(c == 's'){
        s = va_arg(ap, char*);
        if(s == 0)
          s = "(null)";
        while(*s != 0){
 478:	02800d93          	li	s11,40
  putc(fd, 'x');
 47c:	4d41                	li	s10,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 47e:	00000b97          	auipc	s7,0x0
 482:	3f2b8b93          	addi	s7,s7,1010 # 870 <digits>
 486:	a839                	j	4a4 <vprintf+0x6a>
        putc(fd, c);
 488:	85ca                	mv	a1,s2
 48a:	8556                	mv	a0,s5
 48c:	00000097          	auipc	ra,0x0
 490:	ee0080e7          	jalr	-288(ra) # 36c <putc>
 494:	a019                	j	49a <vprintf+0x60>
    } else if(state == '%'){
 496:	01498d63          	beq	s3,s4,4b0 <vprintf+0x76>
  for(i = 0; fmt[i]; i++){
 49a:	0485                	addi	s1,s1,1
 49c:	fff4c903          	lbu	s2,-1(s1)
 4a0:	14090d63          	beqz	s2,5fa <vprintf+0x1c0>
    if(state == 0){
 4a4:	fe0999e3          	bnez	s3,496 <vprintf+0x5c>
      if(c == '%'){
 4a8:	ff4910e3          	bne	s2,s4,488 <vprintf+0x4e>
        state = '%';
 4ac:	89d2                	mv	s3,s4
 4ae:	b7f5                	j	49a <vprintf+0x60>
      if(c == 'd'){
 4b0:	11490c63          	beq	s2,s4,5c8 <vprintf+0x18e>
 4b4:	f9d9079b          	addiw	a5,s2,-99
 4b8:	0ff7f793          	zext.b	a5,a5
 4bc:	10fc6e63          	bltu	s8,a5,5d8 <vprintf+0x19e>
 4c0:	f9d9079b          	addiw	a5,s2,-99
 4c4:	0ff7f713          	zext.b	a4,a5
 4c8:	10ec6863          	bltu	s8,a4,5d8 <vprintf+0x19e>
 4cc:	00271793          	slli	a5,a4,0x2
 4d0:	97e6                	add	a5,a5,s9
 4d2:	439c                	lw	a5,0(a5)
 4d4:	97e6                	add	a5,a5,s9
 4d6:	8782                	jr	a5
        printint(fd, va_arg(ap, int), 10, 1);
 4d8:	008b0913          	addi	s2,s6,8
 4dc:	4685                	li	a3,1
 4de:	4629                	li	a2,10
 4e0:	000b2583          	lw	a1,0(s6)
 4e4:	8556                	mv	a0,s5
 4e6:	00000097          	auipc	ra,0x0
 4ea:	ea8080e7          	jalr	-344(ra) # 38e <printint>
 4ee:	8b4a                	mv	s6,s2
      } else {
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
      state = 0;
 4f0:	4981                	li	s3,0
 4f2:	b765                	j	49a <vprintf+0x60>
        printint(fd, va_arg(ap, uint64), 10, 0);
 4f4:	008b0913          	addi	s2,s6,8
 4f8:	4681                	li	a3,0
 4fa:	4629                	li	a2,10
 4fc:	000b2583          	lw	a1,0(s6)
 500:	8556                	mv	a0,s5
 502:	00000097          	auipc	ra,0x0
 506:	e8c080e7          	jalr	-372(ra) # 38e <printint>
 50a:	8b4a                	mv	s6,s2
      state = 0;
 50c:	4981                	li	s3,0
 50e:	b771                	j	49a <vprintf+0x60>
        printint(fd, va_arg(ap, int), 16, 0);
 510:	008b0913          	addi	s2,s6,8
 514:	4681                	li	a3,0
 516:	866a                	mv	a2,s10
 518:	000b2583          	lw	a1,0(s6)
 51c:	8556                	mv	a0,s5
 51e:	00000097          	auipc	ra,0x0
 522:	e70080e7          	jalr	-400(ra) # 38e <printint>
 526:	8b4a                	mv	s6,s2
      state = 0;
 528:	4981                	li	s3,0
 52a:	bf85                	j	49a <vprintf+0x60>
        printptr(fd, va_arg(ap, uint64));
 52c:	008b0793          	addi	a5,s6,8
 530:	f8f43423          	sd	a5,-120(s0)
 534:	000b3983          	ld	s3,0(s6)
  putc(fd, '0');
 538:	03000593          	li	a1,48
 53c:	8556                	mv	a0,s5
 53e:	00000097          	auipc	ra,0x0
 542:	e2e080e7          	jalr	-466(ra) # 36c <putc>
  putc(fd, 'x');
 546:	07800593          	li	a1,120
 54a:	8556                	mv	a0,s5
 54c:	00000097          	auipc	ra,0x0
 550:	e20080e7          	jalr	-480(ra) # 36c <putc>
 554:	896a                	mv	s2,s10
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 556:	03c9d793          	srli	a5,s3,0x3c
 55a:	97de                	add	a5,a5,s7
 55c:	0007c583          	lbu	a1,0(a5)
 560:	8556                	mv	a0,s5
 562:	00000097          	auipc	ra,0x0
 566:	e0a080e7          	jalr	-502(ra) # 36c <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 56a:	0992                	slli	s3,s3,0x4
 56c:	397d                	addiw	s2,s2,-1
 56e:	fe0914e3          	bnez	s2,556 <vprintf+0x11c>
        printptr(fd, va_arg(ap, uint64));
 572:	f8843b03          	ld	s6,-120(s0)
      state = 0;
 576:	4981                	li	s3,0
 578:	b70d                	j	49a <vprintf+0x60>
        s = va_arg(ap, char*);
 57a:	008b0913          	addi	s2,s6,8
 57e:	000b3983          	ld	s3,0(s6)
        if(s == 0)
 582:	02098163          	beqz	s3,5a4 <vprintf+0x16a>
        while(*s != 0){
 586:	0009c583          	lbu	a1,0(s3)
 58a:	c5ad                	beqz	a1,5f4 <vprintf+0x1ba>
          putc(fd, *s);
 58c:	8556                	mv	a0,s5
 58e:	00000097          	auipc	ra,0x0
 592:	dde080e7          	jalr	-546(ra) # 36c <putc>
          s++;
 596:	0985                	addi	s3,s3,1
        while(*s != 0){
 598:	0009c583          	lbu	a1,0(s3)
 59c:	f9e5                	bnez	a1,58c <vprintf+0x152>
        s = va_arg(ap, char*);
 59e:	8b4a                	mv	s6,s2
      state = 0;
 5a0:	4981                	li	s3,0
 5a2:	bde5                	j	49a <vprintf+0x60>
          s = "(null)";
 5a4:	00000997          	auipc	s3,0x0
 5a8:	26c98993          	addi	s3,s3,620 # 810 <malloc+0x112>
        while(*s != 0){
 5ac:	85ee                	mv	a1,s11
 5ae:	bff9                	j	58c <vprintf+0x152>
        putc(fd, va_arg(ap, uint));
 5b0:	008b0913          	addi	s2,s6,8
 5b4:	000b4583          	lbu	a1,0(s6)
 5b8:	8556                	mv	a0,s5
 5ba:	00000097          	auipc	ra,0x0
 5be:	db2080e7          	jalr	-590(ra) # 36c <putc>
 5c2:	8b4a                	mv	s6,s2
      state = 0;
 5c4:	4981                	li	s3,0
 5c6:	bdd1                	j	49a <vprintf+0x60>
        putc(fd, c);
 5c8:	85d2                	mv	a1,s4
 5ca:	8556                	mv	a0,s5
 5cc:	00000097          	auipc	ra,0x0
 5d0:	da0080e7          	jalr	-608(ra) # 36c <putc>
      state = 0;
 5d4:	4981                	li	s3,0
 5d6:	b5d1                	j	49a <vprintf+0x60>
        putc(fd, '%');
 5d8:	85d2                	mv	a1,s4
 5da:	8556                	mv	a0,s5
 5dc:	00000097          	auipc	ra,0x0
 5e0:	d90080e7          	jalr	-624(ra) # 36c <putc>
        putc(fd, c);
 5e4:	85ca                	mv	a1,s2
 5e6:	8556                	mv	a0,s5
 5e8:	00000097          	auipc	ra,0x0
 5ec:	d84080e7          	jalr	-636(ra) # 36c <putc>
      state = 0;
 5f0:	4981                	li	s3,0
 5f2:	b565                	j	49a <vprintf+0x60>
        s = va_arg(ap, char*);
 5f4:	8b4a                	mv	s6,s2
      state = 0;
 5f6:	4981                	li	s3,0
 5f8:	b54d                	j	49a <vprintf+0x60>
    }
  }
}
 5fa:	70e6                	ld	ra,120(sp)
 5fc:	7446                	ld	s0,112(sp)
 5fe:	74a6                	ld	s1,104(sp)
 600:	7906                	ld	s2,96(sp)
 602:	69e6                	ld	s3,88(sp)
 604:	6a46                	ld	s4,80(sp)
 606:	6aa6                	ld	s5,72(sp)
 608:	6b06                	ld	s6,64(sp)
 60a:	7be2                	ld	s7,56(sp)
 60c:	7c42                	ld	s8,48(sp)
 60e:	7ca2                	ld	s9,40(sp)
 610:	7d02                	ld	s10,32(sp)
 612:	6de2                	ld	s11,24(sp)
 614:	6109                	addi	sp,sp,128
 616:	8082                	ret

0000000000000618 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 618:	715d                	addi	sp,sp,-80
 61a:	ec06                	sd	ra,24(sp)
 61c:	e822                	sd	s0,16(sp)
 61e:	1000                	addi	s0,sp,32
 620:	e010                	sd	a2,0(s0)
 622:	e414                	sd	a3,8(s0)
 624:	e818                	sd	a4,16(s0)
 626:	ec1c                	sd	a5,24(s0)
 628:	03043023          	sd	a6,32(s0)
 62c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 630:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 634:	8622                	mv	a2,s0
 636:	00000097          	auipc	ra,0x0
 63a:	e04080e7          	jalr	-508(ra) # 43a <vprintf>
}
 63e:	60e2                	ld	ra,24(sp)
 640:	6442                	ld	s0,16(sp)
 642:	6161                	addi	sp,sp,80
 644:	8082                	ret

0000000000000646 <printf>:

void
printf(const char *fmt, ...)
{
 646:	711d                	addi	sp,sp,-96
 648:	ec06                	sd	ra,24(sp)
 64a:	e822                	sd	s0,16(sp)
 64c:	1000                	addi	s0,sp,32
 64e:	e40c                	sd	a1,8(s0)
 650:	e810                	sd	a2,16(s0)
 652:	ec14                	sd	a3,24(s0)
 654:	f018                	sd	a4,32(s0)
 656:	f41c                	sd	a5,40(s0)
 658:	03043823          	sd	a6,48(s0)
 65c:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 660:	00840613          	addi	a2,s0,8
 664:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 668:	85aa                	mv	a1,a0
 66a:	4505                	li	a0,1
 66c:	00000097          	auipc	ra,0x0
 670:	dce080e7          	jalr	-562(ra) # 43a <vprintf>
}
 674:	60e2                	ld	ra,24(sp)
 676:	6442                	ld	s0,16(sp)
 678:	6125                	addi	sp,sp,96
 67a:	8082                	ret

000000000000067c <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 67c:	1141                	addi	sp,sp,-16
 67e:	e422                	sd	s0,8(sp)
 680:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 682:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 686:	00001797          	auipc	a5,0x1
 68a:	97a7b783          	ld	a5,-1670(a5) # 1000 <freep>
 68e:	a02d                	j	6b8 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 690:	4618                	lw	a4,8(a2)
 692:	9f2d                	addw	a4,a4,a1
 694:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 698:	6398                	ld	a4,0(a5)
 69a:	6310                	ld	a2,0(a4)
 69c:	a83d                	j	6da <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 69e:	ff852703          	lw	a4,-8(a0)
 6a2:	9f31                	addw	a4,a4,a2
 6a4:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 6a6:	ff053683          	ld	a3,-16(a0)
 6aa:	a091                	j	6ee <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6ac:	6398                	ld	a4,0(a5)
 6ae:	00e7e463          	bltu	a5,a4,6b6 <free+0x3a>
 6b2:	00e6ea63          	bltu	a3,a4,6c6 <free+0x4a>
{
 6b6:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 6b8:	fed7fae3          	bgeu	a5,a3,6ac <free+0x30>
 6bc:	6398                	ld	a4,0(a5)
 6be:	00e6e463          	bltu	a3,a4,6c6 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 6c2:	fee7eae3          	bltu	a5,a4,6b6 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 6c6:	ff852583          	lw	a1,-8(a0)
 6ca:	6390                	ld	a2,0(a5)
 6cc:	02059813          	slli	a6,a1,0x20
 6d0:	01c85713          	srli	a4,a6,0x1c
 6d4:	9736                	add	a4,a4,a3
 6d6:	fae60de3          	beq	a2,a4,690 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 6da:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 6de:	4790                	lw	a2,8(a5)
 6e0:	02061593          	slli	a1,a2,0x20
 6e4:	01c5d713          	srli	a4,a1,0x1c
 6e8:	973e                	add	a4,a4,a5
 6ea:	fae68ae3          	beq	a3,a4,69e <free+0x22>
    p->s.ptr = bp->s.ptr;
 6ee:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 6f0:	00001717          	auipc	a4,0x1
 6f4:	90f73823          	sd	a5,-1776(a4) # 1000 <freep>
}
 6f8:	6422                	ld	s0,8(sp)
 6fa:	0141                	addi	sp,sp,16
 6fc:	8082                	ret

00000000000006fe <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 6fe:	7139                	addi	sp,sp,-64
 700:	fc06                	sd	ra,56(sp)
 702:	f822                	sd	s0,48(sp)
 704:	f426                	sd	s1,40(sp)
 706:	f04a                	sd	s2,32(sp)
 708:	ec4e                	sd	s3,24(sp)
 70a:	e852                	sd	s4,16(sp)
 70c:	e456                	sd	s5,8(sp)
 70e:	e05a                	sd	s6,0(sp)
 710:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 712:	02051493          	slli	s1,a0,0x20
 716:	9081                	srli	s1,s1,0x20
 718:	04bd                	addi	s1,s1,15
 71a:	8091                	srli	s1,s1,0x4
 71c:	0014899b          	addiw	s3,s1,1
 720:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 722:	00001517          	auipc	a0,0x1
 726:	8de53503          	ld	a0,-1826(a0) # 1000 <freep>
 72a:	c515                	beqz	a0,756 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 72c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 72e:	4798                	lw	a4,8(a5)
 730:	02977f63          	bgeu	a4,s1,76e <malloc+0x70>
 734:	8a4e                	mv	s4,s3
 736:	0009871b          	sext.w	a4,s3
 73a:	6685                	lui	a3,0x1
 73c:	00d77363          	bgeu	a4,a3,742 <malloc+0x44>
 740:	6a05                	lui	s4,0x1
 742:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 746:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 74a:	00001917          	auipc	s2,0x1
 74e:	8b690913          	addi	s2,s2,-1866 # 1000 <freep>
  if(p == (char*)-1)
 752:	5afd                	li	s5,-1
 754:	a895                	j	7c8 <malloc+0xca>
    base.s.ptr = freep = prevp = &base;
 756:	00001797          	auipc	a5,0x1
 75a:	8ba78793          	addi	a5,a5,-1862 # 1010 <base>
 75e:	00001717          	auipc	a4,0x1
 762:	8af73123          	sd	a5,-1886(a4) # 1000 <freep>
 766:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 768:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 76c:	b7e1                	j	734 <malloc+0x36>
      if(p->s.size == nunits)
 76e:	02e48c63          	beq	s1,a4,7a6 <malloc+0xa8>
        p->s.size -= nunits;
 772:	4137073b          	subw	a4,a4,s3
 776:	c798                	sw	a4,8(a5)
        p += p->s.size;
 778:	02071693          	slli	a3,a4,0x20
 77c:	01c6d713          	srli	a4,a3,0x1c
 780:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 782:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 786:	00001717          	auipc	a4,0x1
 78a:	86a73d23          	sd	a0,-1926(a4) # 1000 <freep>
      return (void*)(p + 1);
 78e:	01078513          	addi	a0,a5,16
      if((p = morecore(nunits)) == 0)
        return 0;
  }
}
 792:	70e2                	ld	ra,56(sp)
 794:	7442                	ld	s0,48(sp)
 796:	74a2                	ld	s1,40(sp)
 798:	7902                	ld	s2,32(sp)
 79a:	69e2                	ld	s3,24(sp)
 79c:	6a42                	ld	s4,16(sp)
 79e:	6aa2                	ld	s5,8(sp)
 7a0:	6b02                	ld	s6,0(sp)
 7a2:	6121                	addi	sp,sp,64
 7a4:	8082                	ret
        prevp->s.ptr = p->s.ptr;
 7a6:	6398                	ld	a4,0(a5)
 7a8:	e118                	sd	a4,0(a0)
 7aa:	bff1                	j	786 <malloc+0x88>
  hp->s.size = nu;
 7ac:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 7b0:	0541                	addi	a0,a0,16
 7b2:	00000097          	auipc	ra,0x0
 7b6:	eca080e7          	jalr	-310(ra) # 67c <free>
  return freep;
 7ba:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 7be:	d971                	beqz	a0,792 <malloc+0x94>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 7c0:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 7c2:	4798                	lw	a4,8(a5)
 7c4:	fa9775e3          	bgeu	a4,s1,76e <malloc+0x70>
    if(p == freep)
 7c8:	00093703          	ld	a4,0(s2)
 7cc:	853e                	mv	a0,a5
 7ce:	fef719e3          	bne	a4,a5,7c0 <malloc+0xc2>
  p = sbrk(nu * sizeof(Header));
 7d2:	8552                	mv	a0,s4
 7d4:	00000097          	auipc	ra,0x0
 7d8:	b78080e7          	jalr	-1160(ra) # 34c <sbrk>
  if(p == (char*)-1)
 7dc:	fd5518e3          	bne	a0,s5,7ac <malloc+0xae>
        return 0;
 7e0:	4501                	li	a0,0
 7e2:	bf45                	j	792 <malloc+0x94>
