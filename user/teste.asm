
user/_teste: formato do arquivo elf64-littleriscv


Desmontagem da seção .text:

0000000000000000 <waste_time>:

#define N 4

int child[N];

void waste_time(){
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	addi	s0,sp,32
  volatile unsigned long long i;
  printf("start\n");
   8:	00001517          	auipc	a0,0x1
   c:	8d850513          	addi	a0,a0,-1832 # 8e0 <malloc+0xfa>
  10:	722000ef          	jal	732 <printf>
  for (i = 0; i < 3000000000ULL; ++i);
  14:	fe043423          	sd	zero,-24(s0)
  18:	fe843703          	ld	a4,-24(s0)
  1c:	596837b7          	lui	a5,0x59683
  20:	0786                	slli	a5,a5,0x1
  22:	dff78793          	addi	a5,a5,-513 # 59682dff <base+0x59681ddf>
  26:	00e7ec63          	bltu	a5,a4,3e <waste_time+0x3e>
  2a:	873e                	mv	a4,a5
  2c:	fe843783          	ld	a5,-24(s0)
  30:	0785                	addi	a5,a5,1
  32:	fef43423          	sd	a5,-24(s0)
  36:	fe843783          	ld	a5,-24(s0)
  3a:	fef779e3          	bgeu	a4,a5,2c <waste_time+0x2c>
  printf("stop\n");
  3e:	00001517          	auipc	a0,0x1
  42:	8b250513          	addi	a0,a0,-1870 # 8f0 <malloc+0x10a>
  46:	6ec000ef          	jal	732 <printf>
}
  4a:	60e2                	ld	ra,24(sp)
  4c:	6442                	ld	s0,16(sp)
  4e:	6105                	addi	sp,sp,32
  50:	8082                	ret

0000000000000052 <main>:

int
main(int argc, char *argv[])
{
  52:	1101                	addi	sp,sp,-32
  54:	ec06                	sd	ra,24(sp)
  56:	e822                	sd	s0,16(sp)
  58:	e426                	sd	s1,8(sp)
  5a:	e04a                	sd	s2,0(sp)
  5c:	1000                	addi	s0,sp,32
int n, pid;
for(n=0; n<N; n++){
  5e:	00001497          	auipc	s1,0x1
  62:	fb248493          	addi	s1,s1,-78 # 1010 <child>
  66:	00001917          	auipc	s2,0x1
  6a:	fba90913          	addi	s2,s2,-70 # 1020 <base>
   pid = fork();
  6e:	2a4000ef          	jal	312 <fork>
   if(pid == 0) {
  72:	c915                	beqz	a0,a6 <main+0x54>
     waste_time();
     exit(0);
   }
   else child[n] = pid;
  74:	c088                	sw	a0,0(s1)
for(n=0; n<N; n++){
  76:	0491                	addi	s1,s1,4
  78:	ff249be3          	bne	s1,s2,6e <main+0x1c>
  7c:	4491                	li	s1,4
}

for(n=0; n<N; n++){
   pid = wait(0);
   printf("Child pid = %d finished!", pid);
  7e:	00001917          	auipc	s2,0x1
  82:	87a90913          	addi	s2,s2,-1926 # 8f8 <malloc+0x112>
   pid = wait(0);
  86:	4501                	li	a0,0
  88:	29a000ef          	jal	322 <wait>
  8c:	85aa                	mv	a1,a0
   printf("Child pid = %d finished!", pid);
  8e:	854a                	mv	a0,s2
  90:	6a2000ef          	jal	732 <printf>
for(n=0; n<N; n++){
  94:	34fd                	addiw	s1,s1,-1
  96:	f8e5                	bnez	s1,86 <main+0x34>
}
return 0;

  98:	4501                	li	a0,0
  9a:	60e2                	ld	ra,24(sp)
  9c:	6442                	ld	s0,16(sp)
  9e:	64a2                	ld	s1,8(sp)
  a0:	6902                	ld	s2,0(sp)
  a2:	6105                	addi	sp,sp,32
  a4:	8082                	ret
     waste_time();
  a6:	f5bff0ef          	jal	0 <waste_time>
     exit(0);
  aa:	4501                	li	a0,0
  ac:	26e000ef          	jal	31a <exit>

00000000000000b0 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
  b0:	1141                	addi	sp,sp,-16
  b2:	e406                	sd	ra,8(sp)
  b4:	e022                	sd	s0,0(sp)
  b6:	0800                	addi	s0,sp,16
  extern int main();
  main();
  b8:	f9bff0ef          	jal	52 <main>
  exit(0);
  bc:	4501                	li	a0,0
  be:	25c000ef          	jal	31a <exit>

00000000000000c2 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  c2:	1141                	addi	sp,sp,-16
  c4:	e422                	sd	s0,8(sp)
  c6:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  c8:	87aa                	mv	a5,a0
  ca:	0585                	addi	a1,a1,1
  cc:	0785                	addi	a5,a5,1
  ce:	fff5c703          	lbu	a4,-1(a1)
  d2:	fee78fa3          	sb	a4,-1(a5)
  d6:	fb75                	bnez	a4,ca <strcpy+0x8>
    ;
  return os;
}
  d8:	6422                	ld	s0,8(sp)
  da:	0141                	addi	sp,sp,16
  dc:	8082                	ret

00000000000000de <strcmp>:

int
strcmp(const char *p, const char *q)
{
  de:	1141                	addi	sp,sp,-16
  e0:	e422                	sd	s0,8(sp)
  e2:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
  e4:	00054783          	lbu	a5,0(a0)
  e8:	cb91                	beqz	a5,fc <strcmp+0x1e>
  ea:	0005c703          	lbu	a4,0(a1)
  ee:	00f71763          	bne	a4,a5,fc <strcmp+0x1e>
    p++, q++;
  f2:	0505                	addi	a0,a0,1
  f4:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
  f6:	00054783          	lbu	a5,0(a0)
  fa:	fbe5                	bnez	a5,ea <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
  fc:	0005c503          	lbu	a0,0(a1)
}
 100:	40a7853b          	subw	a0,a5,a0
 104:	6422                	ld	s0,8(sp)
 106:	0141                	addi	sp,sp,16
 108:	8082                	ret

000000000000010a <strlen>:

uint
strlen(const char *s)
{
 10a:	1141                	addi	sp,sp,-16
 10c:	e422                	sd	s0,8(sp)
 10e:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 110:	00054783          	lbu	a5,0(a0)
 114:	cf91                	beqz	a5,130 <strlen+0x26>
 116:	0505                	addi	a0,a0,1
 118:	87aa                	mv	a5,a0
 11a:	86be                	mv	a3,a5
 11c:	0785                	addi	a5,a5,1
 11e:	fff7c703          	lbu	a4,-1(a5)
 122:	ff65                	bnez	a4,11a <strlen+0x10>
 124:	40a6853b          	subw	a0,a3,a0
 128:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 12a:	6422                	ld	s0,8(sp)
 12c:	0141                	addi	sp,sp,16
 12e:	8082                	ret
  for(n = 0; s[n]; n++)
 130:	4501                	li	a0,0
 132:	bfe5                	j	12a <strlen+0x20>

0000000000000134 <memset>:

void*
memset(void *dst, int c, uint n)
{
 134:	1141                	addi	sp,sp,-16
 136:	e422                	sd	s0,8(sp)
 138:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 13a:	ca19                	beqz	a2,150 <memset+0x1c>
 13c:	87aa                	mv	a5,a0
 13e:	1602                	slli	a2,a2,0x20
 140:	9201                	srli	a2,a2,0x20
 142:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 146:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 14a:	0785                	addi	a5,a5,1
 14c:	fee79de3          	bne	a5,a4,146 <memset+0x12>
  }
  return dst;
}
 150:	6422                	ld	s0,8(sp)
 152:	0141                	addi	sp,sp,16
 154:	8082                	ret

0000000000000156 <strchr>:

char*
strchr(const char *s, char c)
{
 156:	1141                	addi	sp,sp,-16
 158:	e422                	sd	s0,8(sp)
 15a:	0800                	addi	s0,sp,16
  for(; *s; s++)
 15c:	00054783          	lbu	a5,0(a0)
 160:	cb99                	beqz	a5,176 <strchr+0x20>
    if(*s == c)
 162:	00f58763          	beq	a1,a5,170 <strchr+0x1a>
  for(; *s; s++)
 166:	0505                	addi	a0,a0,1
 168:	00054783          	lbu	a5,0(a0)
 16c:	fbfd                	bnez	a5,162 <strchr+0xc>
      return (char*)s;
  return 0;
 16e:	4501                	li	a0,0
}
 170:	6422                	ld	s0,8(sp)
 172:	0141                	addi	sp,sp,16
 174:	8082                	ret
  return 0;
 176:	4501                	li	a0,0
 178:	bfe5                	j	170 <strchr+0x1a>

000000000000017a <gets>:

char*
gets(char *buf, int max)
{
 17a:	711d                	addi	sp,sp,-96
 17c:	ec86                	sd	ra,88(sp)
 17e:	e8a2                	sd	s0,80(sp)
 180:	e4a6                	sd	s1,72(sp)
 182:	e0ca                	sd	s2,64(sp)
 184:	fc4e                	sd	s3,56(sp)
 186:	f852                	sd	s4,48(sp)
 188:	f456                	sd	s5,40(sp)
 18a:	f05a                	sd	s6,32(sp)
 18c:	ec5e                	sd	s7,24(sp)
 18e:	1080                	addi	s0,sp,96
 190:	8baa                	mv	s7,a0
 192:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 194:	892a                	mv	s2,a0
 196:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 198:	4aa9                	li	s5,10
 19a:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 19c:	89a6                	mv	s3,s1
 19e:	2485                	addiw	s1,s1,1
 1a0:	0344d663          	bge	s1,s4,1cc <gets+0x52>
    cc = read(0, &c, 1);
 1a4:	4605                	li	a2,1
 1a6:	faf40593          	addi	a1,s0,-81
 1aa:	4501                	li	a0,0
 1ac:	186000ef          	jal	332 <read>
    if(cc < 1)
 1b0:	00a05e63          	blez	a0,1cc <gets+0x52>
    buf[i++] = c;
 1b4:	faf44783          	lbu	a5,-81(s0)
 1b8:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1bc:	01578763          	beq	a5,s5,1ca <gets+0x50>
 1c0:	0905                	addi	s2,s2,1
 1c2:	fd679de3          	bne	a5,s6,19c <gets+0x22>
    buf[i++] = c;
 1c6:	89a6                	mv	s3,s1
 1c8:	a011                	j	1cc <gets+0x52>
 1ca:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1cc:	99de                	add	s3,s3,s7
 1ce:	00098023          	sb	zero,0(s3)
  return buf;
}
 1d2:	855e                	mv	a0,s7
 1d4:	60e6                	ld	ra,88(sp)
 1d6:	6446                	ld	s0,80(sp)
 1d8:	64a6                	ld	s1,72(sp)
 1da:	6906                	ld	s2,64(sp)
 1dc:	79e2                	ld	s3,56(sp)
 1de:	7a42                	ld	s4,48(sp)
 1e0:	7aa2                	ld	s5,40(sp)
 1e2:	7b02                	ld	s6,32(sp)
 1e4:	6be2                	ld	s7,24(sp)
 1e6:	6125                	addi	sp,sp,96
 1e8:	8082                	ret

00000000000001ea <stat>:

int
stat(const char *n, struct stat *st)
{
 1ea:	1101                	addi	sp,sp,-32
 1ec:	ec06                	sd	ra,24(sp)
 1ee:	e822                	sd	s0,16(sp)
 1f0:	e04a                	sd	s2,0(sp)
 1f2:	1000                	addi	s0,sp,32
 1f4:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 1f6:	4581                	li	a1,0
 1f8:	162000ef          	jal	35a <open>
  if(fd < 0)
 1fc:	02054263          	bltz	a0,220 <stat+0x36>
 200:	e426                	sd	s1,8(sp)
 202:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 204:	85ca                	mv	a1,s2
 206:	16c000ef          	jal	372 <fstat>
 20a:	892a                	mv	s2,a0
  close(fd);
 20c:	8526                	mv	a0,s1
 20e:	134000ef          	jal	342 <close>
  return r;
 212:	64a2                	ld	s1,8(sp)
}
 214:	854a                	mv	a0,s2
 216:	60e2                	ld	ra,24(sp)
 218:	6442                	ld	s0,16(sp)
 21a:	6902                	ld	s2,0(sp)
 21c:	6105                	addi	sp,sp,32
 21e:	8082                	ret
    return -1;
 220:	597d                	li	s2,-1
 222:	bfcd                	j	214 <stat+0x2a>

0000000000000224 <atoi>:

int
atoi(const char *s)
{
 224:	1141                	addi	sp,sp,-16
 226:	e422                	sd	s0,8(sp)
 228:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 22a:	00054683          	lbu	a3,0(a0)
 22e:	fd06879b          	addiw	a5,a3,-48
 232:	0ff7f793          	zext.b	a5,a5
 236:	4625                	li	a2,9
 238:	02f66863          	bltu	a2,a5,268 <atoi+0x44>
 23c:	872a                	mv	a4,a0
  n = 0;
 23e:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 240:	0705                	addi	a4,a4,1
 242:	0025179b          	slliw	a5,a0,0x2
 246:	9fa9                	addw	a5,a5,a0
 248:	0017979b          	slliw	a5,a5,0x1
 24c:	9fb5                	addw	a5,a5,a3
 24e:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 252:	00074683          	lbu	a3,0(a4)
 256:	fd06879b          	addiw	a5,a3,-48
 25a:	0ff7f793          	zext.b	a5,a5
 25e:	fef671e3          	bgeu	a2,a5,240 <atoi+0x1c>
  return n;
}
 262:	6422                	ld	s0,8(sp)
 264:	0141                	addi	sp,sp,16
 266:	8082                	ret
  n = 0;
 268:	4501                	li	a0,0
 26a:	bfe5                	j	262 <atoi+0x3e>

000000000000026c <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 26c:	1141                	addi	sp,sp,-16
 26e:	e422                	sd	s0,8(sp)
 270:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 272:	02b57463          	bgeu	a0,a1,29a <memmove+0x2e>
    while(n-- > 0)
 276:	00c05f63          	blez	a2,294 <memmove+0x28>
 27a:	1602                	slli	a2,a2,0x20
 27c:	9201                	srli	a2,a2,0x20
 27e:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 282:	872a                	mv	a4,a0
      *dst++ = *src++;
 284:	0585                	addi	a1,a1,1
 286:	0705                	addi	a4,a4,1
 288:	fff5c683          	lbu	a3,-1(a1)
 28c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 290:	fef71ae3          	bne	a4,a5,284 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 294:	6422                	ld	s0,8(sp)
 296:	0141                	addi	sp,sp,16
 298:	8082                	ret
    dst += n;
 29a:	00c50733          	add	a4,a0,a2
    src += n;
 29e:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2a0:	fec05ae3          	blez	a2,294 <memmove+0x28>
 2a4:	fff6079b          	addiw	a5,a2,-1
 2a8:	1782                	slli	a5,a5,0x20
 2aa:	9381                	srli	a5,a5,0x20
 2ac:	fff7c793          	not	a5,a5
 2b0:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2b2:	15fd                	addi	a1,a1,-1
 2b4:	177d                	addi	a4,a4,-1
 2b6:	0005c683          	lbu	a3,0(a1)
 2ba:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2be:	fee79ae3          	bne	a5,a4,2b2 <memmove+0x46>
 2c2:	bfc9                	j	294 <memmove+0x28>

00000000000002c4 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2c4:	1141                	addi	sp,sp,-16
 2c6:	e422                	sd	s0,8(sp)
 2c8:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2ca:	ca05                	beqz	a2,2fa <memcmp+0x36>
 2cc:	fff6069b          	addiw	a3,a2,-1
 2d0:	1682                	slli	a3,a3,0x20
 2d2:	9281                	srli	a3,a3,0x20
 2d4:	0685                	addi	a3,a3,1
 2d6:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 2d8:	00054783          	lbu	a5,0(a0)
 2dc:	0005c703          	lbu	a4,0(a1)
 2e0:	00e79863          	bne	a5,a4,2f0 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 2e4:	0505                	addi	a0,a0,1
    p2++;
 2e6:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 2e8:	fed518e3          	bne	a0,a3,2d8 <memcmp+0x14>
  }
  return 0;
 2ec:	4501                	li	a0,0
 2ee:	a019                	j	2f4 <memcmp+0x30>
      return *p1 - *p2;
 2f0:	40e7853b          	subw	a0,a5,a4
}
 2f4:	6422                	ld	s0,8(sp)
 2f6:	0141                	addi	sp,sp,16
 2f8:	8082                	ret
  return 0;
 2fa:	4501                	li	a0,0
 2fc:	bfe5                	j	2f4 <memcmp+0x30>

00000000000002fe <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 2fe:	1141                	addi	sp,sp,-16
 300:	e406                	sd	ra,8(sp)
 302:	e022                	sd	s0,0(sp)
 304:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 306:	f67ff0ef          	jal	26c <memmove>
}
 30a:	60a2                	ld	ra,8(sp)
 30c:	6402                	ld	s0,0(sp)
 30e:	0141                	addi	sp,sp,16
 310:	8082                	ret

0000000000000312 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 312:	4885                	li	a7,1
 ecall
 314:	00000073          	ecall
 ret
 318:	8082                	ret

000000000000031a <exit>:
.global exit
exit:
 li a7, SYS_exit
 31a:	4889                	li	a7,2
 ecall
 31c:	00000073          	ecall
 ret
 320:	8082                	ret

0000000000000322 <wait>:
.global wait
wait:
 li a7, SYS_wait
 322:	488d                	li	a7,3
 ecall
 324:	00000073          	ecall
 ret
 328:	8082                	ret

000000000000032a <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 32a:	4891                	li	a7,4
 ecall
 32c:	00000073          	ecall
 ret
 330:	8082                	ret

0000000000000332 <read>:
.global read
read:
 li a7, SYS_read
 332:	4895                	li	a7,5
 ecall
 334:	00000073          	ecall
 ret
 338:	8082                	ret

000000000000033a <write>:
.global write
write:
 li a7, SYS_write
 33a:	48c1                	li	a7,16
 ecall
 33c:	00000073          	ecall
 ret
 340:	8082                	ret

0000000000000342 <close>:
.global close
close:
 li a7, SYS_close
 342:	48d5                	li	a7,21
 ecall
 344:	00000073          	ecall
 ret
 348:	8082                	ret

000000000000034a <kill>:
.global kill
kill:
 li a7, SYS_kill
 34a:	4899                	li	a7,6
 ecall
 34c:	00000073          	ecall
 ret
 350:	8082                	ret

0000000000000352 <exec>:
.global exec
exec:
 li a7, SYS_exec
 352:	489d                	li	a7,7
 ecall
 354:	00000073          	ecall
 ret
 358:	8082                	ret

000000000000035a <open>:
.global open
open:
 li a7, SYS_open
 35a:	48bd                	li	a7,15
 ecall
 35c:	00000073          	ecall
 ret
 360:	8082                	ret

0000000000000362 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 362:	48c5                	li	a7,17
 ecall
 364:	00000073          	ecall
 ret
 368:	8082                	ret

000000000000036a <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 36a:	48c9                	li	a7,18
 ecall
 36c:	00000073          	ecall
 ret
 370:	8082                	ret

0000000000000372 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 372:	48a1                	li	a7,8
 ecall
 374:	00000073          	ecall
 ret
 378:	8082                	ret

000000000000037a <link>:
.global link
link:
 li a7, SYS_link
 37a:	48cd                	li	a7,19
 ecall
 37c:	00000073          	ecall
 ret
 380:	8082                	ret

0000000000000382 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 382:	48d1                	li	a7,20
 ecall
 384:	00000073          	ecall
 ret
 388:	8082                	ret

000000000000038a <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 38a:	48a5                	li	a7,9
 ecall
 38c:	00000073          	ecall
 ret
 390:	8082                	ret

0000000000000392 <dup>:
.global dup
dup:
 li a7, SYS_dup
 392:	48a9                	li	a7,10
 ecall
 394:	00000073          	ecall
 ret
 398:	8082                	ret

000000000000039a <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 39a:	48ad                	li	a7,11
 ecall
 39c:	00000073          	ecall
 ret
 3a0:	8082                	ret

00000000000003a2 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3a2:	48b1                	li	a7,12
 ecall
 3a4:	00000073          	ecall
 ret
 3a8:	8082                	ret

00000000000003aa <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3aa:	48b5                	li	a7,13
 ecall
 3ac:	00000073          	ecall
 ret
 3b0:	8082                	ret

00000000000003b2 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3b2:	48b9                	li	a7,14
 ecall
 3b4:	00000073          	ecall
 ret
 3b8:	8082                	ret

00000000000003ba <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3ba:	1101                	addi	sp,sp,-32
 3bc:	ec06                	sd	ra,24(sp)
 3be:	e822                	sd	s0,16(sp)
 3c0:	1000                	addi	s0,sp,32
 3c2:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 3c6:	4605                	li	a2,1
 3c8:	fef40593          	addi	a1,s0,-17
 3cc:	f6fff0ef          	jal	33a <write>
}
 3d0:	60e2                	ld	ra,24(sp)
 3d2:	6442                	ld	s0,16(sp)
 3d4:	6105                	addi	sp,sp,32
 3d6:	8082                	ret

00000000000003d8 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 3d8:	7139                	addi	sp,sp,-64
 3da:	fc06                	sd	ra,56(sp)
 3dc:	f822                	sd	s0,48(sp)
 3de:	f426                	sd	s1,40(sp)
 3e0:	0080                	addi	s0,sp,64
 3e2:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 3e4:	c299                	beqz	a3,3ea <printint+0x12>
 3e6:	0805c963          	bltz	a1,478 <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 3ea:	2581                	sext.w	a1,a1
  neg = 0;
 3ec:	4881                	li	a7,0
 3ee:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 3f2:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 3f4:	2601                	sext.w	a2,a2
 3f6:	00000517          	auipc	a0,0x0
 3fa:	52a50513          	addi	a0,a0,1322 # 920 <digits>
 3fe:	883a                	mv	a6,a4
 400:	2705                	addiw	a4,a4,1
 402:	02c5f7bb          	remuw	a5,a1,a2
 406:	1782                	slli	a5,a5,0x20
 408:	9381                	srli	a5,a5,0x20
 40a:	97aa                	add	a5,a5,a0
 40c:	0007c783          	lbu	a5,0(a5)
 410:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 414:	0005879b          	sext.w	a5,a1
 418:	02c5d5bb          	divuw	a1,a1,a2
 41c:	0685                	addi	a3,a3,1
 41e:	fec7f0e3          	bgeu	a5,a2,3fe <printint+0x26>
  if(neg)
 422:	00088c63          	beqz	a7,43a <printint+0x62>
    buf[i++] = '-';
 426:	fd070793          	addi	a5,a4,-48
 42a:	00878733          	add	a4,a5,s0
 42e:	02d00793          	li	a5,45
 432:	fef70823          	sb	a5,-16(a4)
 436:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 43a:	02e05a63          	blez	a4,46e <printint+0x96>
 43e:	f04a                	sd	s2,32(sp)
 440:	ec4e                	sd	s3,24(sp)
 442:	fc040793          	addi	a5,s0,-64
 446:	00e78933          	add	s2,a5,a4
 44a:	fff78993          	addi	s3,a5,-1
 44e:	99ba                	add	s3,s3,a4
 450:	377d                	addiw	a4,a4,-1
 452:	1702                	slli	a4,a4,0x20
 454:	9301                	srli	a4,a4,0x20
 456:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 45a:	fff94583          	lbu	a1,-1(s2)
 45e:	8526                	mv	a0,s1
 460:	f5bff0ef          	jal	3ba <putc>
  while(--i >= 0)
 464:	197d                	addi	s2,s2,-1
 466:	ff391ae3          	bne	s2,s3,45a <printint+0x82>
 46a:	7902                	ld	s2,32(sp)
 46c:	69e2                	ld	s3,24(sp)
}
 46e:	70e2                	ld	ra,56(sp)
 470:	7442                	ld	s0,48(sp)
 472:	74a2                	ld	s1,40(sp)
 474:	6121                	addi	sp,sp,64
 476:	8082                	ret
    x = -xx;
 478:	40b005bb          	negw	a1,a1
    neg = 1;
 47c:	4885                	li	a7,1
    x = -xx;
 47e:	bf85                	j	3ee <printint+0x16>

0000000000000480 <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 480:	711d                	addi	sp,sp,-96
 482:	ec86                	sd	ra,88(sp)
 484:	e8a2                	sd	s0,80(sp)
 486:	e0ca                	sd	s2,64(sp)
 488:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 48a:	0005c903          	lbu	s2,0(a1)
 48e:	26090863          	beqz	s2,6fe <vprintf+0x27e>
 492:	e4a6                	sd	s1,72(sp)
 494:	fc4e                	sd	s3,56(sp)
 496:	f852                	sd	s4,48(sp)
 498:	f456                	sd	s5,40(sp)
 49a:	f05a                	sd	s6,32(sp)
 49c:	ec5e                	sd	s7,24(sp)
 49e:	e862                	sd	s8,16(sp)
 4a0:	e466                	sd	s9,8(sp)
 4a2:	8b2a                	mv	s6,a0
 4a4:	8a2e                	mv	s4,a1
 4a6:	8bb2                	mv	s7,a2
  state = 0;
 4a8:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4aa:	4481                	li	s1,0
 4ac:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4ae:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4b2:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4b6:	06c00c93          	li	s9,108
 4ba:	a005                	j	4da <vprintf+0x5a>
        putc(fd, c0);
 4bc:	85ca                	mv	a1,s2
 4be:	855a                	mv	a0,s6
 4c0:	efbff0ef          	jal	3ba <putc>
 4c4:	a019                	j	4ca <vprintf+0x4a>
    } else if(state == '%'){
 4c6:	03598263          	beq	s3,s5,4ea <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 4ca:	2485                	addiw	s1,s1,1
 4cc:	8726                	mv	a4,s1
 4ce:	009a07b3          	add	a5,s4,s1
 4d2:	0007c903          	lbu	s2,0(a5)
 4d6:	20090c63          	beqz	s2,6ee <vprintf+0x26e>
    c0 = fmt[i] & 0xff;
 4da:	0009079b          	sext.w	a5,s2
    if(state == 0){
 4de:	fe0994e3          	bnez	s3,4c6 <vprintf+0x46>
      if(c0 == '%'){
 4e2:	fd579de3          	bne	a5,s5,4bc <vprintf+0x3c>
        state = '%';
 4e6:	89be                	mv	s3,a5
 4e8:	b7cd                	j	4ca <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 4ea:	00ea06b3          	add	a3,s4,a4
 4ee:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 4f2:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 4f4:	c681                	beqz	a3,4fc <vprintf+0x7c>
 4f6:	9752                	add	a4,a4,s4
 4f8:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 4fc:	03878f63          	beq	a5,s8,53a <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 500:	05978963          	beq	a5,s9,552 <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 504:	07500713          	li	a4,117
 508:	0ee78363          	beq	a5,a4,5ee <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 50c:	07800713          	li	a4,120
 510:	12e78563          	beq	a5,a4,63a <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 514:	07000713          	li	a4,112
 518:	14e78a63          	beq	a5,a4,66c <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 51c:	07300713          	li	a4,115
 520:	18e78a63          	beq	a5,a4,6b4 <vprintf+0x234>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 524:	02500713          	li	a4,37
 528:	04e79563          	bne	a5,a4,572 <vprintf+0xf2>
        putc(fd, '%');
 52c:	02500593          	li	a1,37
 530:	855a                	mv	a0,s6
 532:	e89ff0ef          	jal	3ba <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 536:	4981                	li	s3,0
 538:	bf49                	j	4ca <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 53a:	008b8913          	addi	s2,s7,8
 53e:	4685                	li	a3,1
 540:	4629                	li	a2,10
 542:	000ba583          	lw	a1,0(s7)
 546:	855a                	mv	a0,s6
 548:	e91ff0ef          	jal	3d8 <printint>
 54c:	8bca                	mv	s7,s2
      state = 0;
 54e:	4981                	li	s3,0
 550:	bfad                	j	4ca <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 552:	06400793          	li	a5,100
 556:	02f68963          	beq	a3,a5,588 <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 55a:	06c00793          	li	a5,108
 55e:	04f68263          	beq	a3,a5,5a2 <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 562:	07500793          	li	a5,117
 566:	0af68063          	beq	a3,a5,606 <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 56a:	07800793          	li	a5,120
 56e:	0ef68263          	beq	a3,a5,652 <vprintf+0x1d2>
        putc(fd, '%');
 572:	02500593          	li	a1,37
 576:	855a                	mv	a0,s6
 578:	e43ff0ef          	jal	3ba <putc>
        putc(fd, c0);
 57c:	85ca                	mv	a1,s2
 57e:	855a                	mv	a0,s6
 580:	e3bff0ef          	jal	3ba <putc>
      state = 0;
 584:	4981                	li	s3,0
 586:	b791                	j	4ca <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 588:	008b8913          	addi	s2,s7,8
 58c:	4685                	li	a3,1
 58e:	4629                	li	a2,10
 590:	000ba583          	lw	a1,0(s7)
 594:	855a                	mv	a0,s6
 596:	e43ff0ef          	jal	3d8 <printint>
        i += 1;
 59a:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 59c:	8bca                	mv	s7,s2
      state = 0;
 59e:	4981                	li	s3,0
        i += 1;
 5a0:	b72d                	j	4ca <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5a2:	06400793          	li	a5,100
 5a6:	02f60763          	beq	a2,a5,5d4 <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5aa:	07500793          	li	a5,117
 5ae:	06f60963          	beq	a2,a5,620 <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 5b2:	07800793          	li	a5,120
 5b6:	faf61ee3          	bne	a2,a5,572 <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5ba:	008b8913          	addi	s2,s7,8
 5be:	4681                	li	a3,0
 5c0:	4641                	li	a2,16
 5c2:	000ba583          	lw	a1,0(s7)
 5c6:	855a                	mv	a0,s6
 5c8:	e11ff0ef          	jal	3d8 <printint>
        i += 2;
 5cc:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 5ce:	8bca                	mv	s7,s2
      state = 0;
 5d0:	4981                	li	s3,0
        i += 2;
 5d2:	bde5                	j	4ca <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5d4:	008b8913          	addi	s2,s7,8
 5d8:	4685                	li	a3,1
 5da:	4629                	li	a2,10
 5dc:	000ba583          	lw	a1,0(s7)
 5e0:	855a                	mv	a0,s6
 5e2:	df7ff0ef          	jal	3d8 <printint>
        i += 2;
 5e6:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 5e8:	8bca                	mv	s7,s2
      state = 0;
 5ea:	4981                	li	s3,0
        i += 2;
 5ec:	bdf9                	j	4ca <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 5ee:	008b8913          	addi	s2,s7,8
 5f2:	4681                	li	a3,0
 5f4:	4629                	li	a2,10
 5f6:	000ba583          	lw	a1,0(s7)
 5fa:	855a                	mv	a0,s6
 5fc:	dddff0ef          	jal	3d8 <printint>
 600:	8bca                	mv	s7,s2
      state = 0;
 602:	4981                	li	s3,0
 604:	b5d9                	j	4ca <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 606:	008b8913          	addi	s2,s7,8
 60a:	4681                	li	a3,0
 60c:	4629                	li	a2,10
 60e:	000ba583          	lw	a1,0(s7)
 612:	855a                	mv	a0,s6
 614:	dc5ff0ef          	jal	3d8 <printint>
        i += 1;
 618:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 61a:	8bca                	mv	s7,s2
      state = 0;
 61c:	4981                	li	s3,0
        i += 1;
 61e:	b575                	j	4ca <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 620:	008b8913          	addi	s2,s7,8
 624:	4681                	li	a3,0
 626:	4629                	li	a2,10
 628:	000ba583          	lw	a1,0(s7)
 62c:	855a                	mv	a0,s6
 62e:	dabff0ef          	jal	3d8 <printint>
        i += 2;
 632:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 634:	8bca                	mv	s7,s2
      state = 0;
 636:	4981                	li	s3,0
        i += 2;
 638:	bd49                	j	4ca <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 63a:	008b8913          	addi	s2,s7,8
 63e:	4681                	li	a3,0
 640:	4641                	li	a2,16
 642:	000ba583          	lw	a1,0(s7)
 646:	855a                	mv	a0,s6
 648:	d91ff0ef          	jal	3d8 <printint>
 64c:	8bca                	mv	s7,s2
      state = 0;
 64e:	4981                	li	s3,0
 650:	bdad                	j	4ca <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 652:	008b8913          	addi	s2,s7,8
 656:	4681                	li	a3,0
 658:	4641                	li	a2,16
 65a:	000ba583          	lw	a1,0(s7)
 65e:	855a                	mv	a0,s6
 660:	d79ff0ef          	jal	3d8 <printint>
        i += 1;
 664:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 666:	8bca                	mv	s7,s2
      state = 0;
 668:	4981                	li	s3,0
        i += 1;
 66a:	b585                	j	4ca <vprintf+0x4a>
 66c:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 66e:	008b8d13          	addi	s10,s7,8
 672:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 676:	03000593          	li	a1,48
 67a:	855a                	mv	a0,s6
 67c:	d3fff0ef          	jal	3ba <putc>
  putc(fd, 'x');
 680:	07800593          	li	a1,120
 684:	855a                	mv	a0,s6
 686:	d35ff0ef          	jal	3ba <putc>
 68a:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 68c:	00000b97          	auipc	s7,0x0
 690:	294b8b93          	addi	s7,s7,660 # 920 <digits>
 694:	03c9d793          	srli	a5,s3,0x3c
 698:	97de                	add	a5,a5,s7
 69a:	0007c583          	lbu	a1,0(a5)
 69e:	855a                	mv	a0,s6
 6a0:	d1bff0ef          	jal	3ba <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6a4:	0992                	slli	s3,s3,0x4
 6a6:	397d                	addiw	s2,s2,-1
 6a8:	fe0916e3          	bnez	s2,694 <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 6ac:	8bea                	mv	s7,s10
      state = 0;
 6ae:	4981                	li	s3,0
 6b0:	6d02                	ld	s10,0(sp)
 6b2:	bd21                	j	4ca <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 6b4:	008b8993          	addi	s3,s7,8
 6b8:	000bb903          	ld	s2,0(s7)
 6bc:	00090f63          	beqz	s2,6da <vprintf+0x25a>
        for(; *s; s++)
 6c0:	00094583          	lbu	a1,0(s2)
 6c4:	c195                	beqz	a1,6e8 <vprintf+0x268>
          putc(fd, *s);
 6c6:	855a                	mv	a0,s6
 6c8:	cf3ff0ef          	jal	3ba <putc>
        for(; *s; s++)
 6cc:	0905                	addi	s2,s2,1
 6ce:	00094583          	lbu	a1,0(s2)
 6d2:	f9f5                	bnez	a1,6c6 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 6d4:	8bce                	mv	s7,s3
      state = 0;
 6d6:	4981                	li	s3,0
 6d8:	bbcd                	j	4ca <vprintf+0x4a>
          s = "(null)";
 6da:	00000917          	auipc	s2,0x0
 6de:	23e90913          	addi	s2,s2,574 # 918 <malloc+0x132>
        for(; *s; s++)
 6e2:	02800593          	li	a1,40
 6e6:	b7c5                	j	6c6 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 6e8:	8bce                	mv	s7,s3
      state = 0;
 6ea:	4981                	li	s3,0
 6ec:	bbf9                	j	4ca <vprintf+0x4a>
 6ee:	64a6                	ld	s1,72(sp)
 6f0:	79e2                	ld	s3,56(sp)
 6f2:	7a42                	ld	s4,48(sp)
 6f4:	7aa2                	ld	s5,40(sp)
 6f6:	7b02                	ld	s6,32(sp)
 6f8:	6be2                	ld	s7,24(sp)
 6fa:	6c42                	ld	s8,16(sp)
 6fc:	6ca2                	ld	s9,8(sp)
    }
  }
}
 6fe:	60e6                	ld	ra,88(sp)
 700:	6446                	ld	s0,80(sp)
 702:	6906                	ld	s2,64(sp)
 704:	6125                	addi	sp,sp,96
 706:	8082                	ret

0000000000000708 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 708:	715d                	addi	sp,sp,-80
 70a:	ec06                	sd	ra,24(sp)
 70c:	e822                	sd	s0,16(sp)
 70e:	1000                	addi	s0,sp,32
 710:	e010                	sd	a2,0(s0)
 712:	e414                	sd	a3,8(s0)
 714:	e818                	sd	a4,16(s0)
 716:	ec1c                	sd	a5,24(s0)
 718:	03043023          	sd	a6,32(s0)
 71c:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 720:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 724:	8622                	mv	a2,s0
 726:	d5bff0ef          	jal	480 <vprintf>
}
 72a:	60e2                	ld	ra,24(sp)
 72c:	6442                	ld	s0,16(sp)
 72e:	6161                	addi	sp,sp,80
 730:	8082                	ret

0000000000000732 <printf>:

void
printf(const char *fmt, ...)
{
 732:	711d                	addi	sp,sp,-96
 734:	ec06                	sd	ra,24(sp)
 736:	e822                	sd	s0,16(sp)
 738:	1000                	addi	s0,sp,32
 73a:	e40c                	sd	a1,8(s0)
 73c:	e810                	sd	a2,16(s0)
 73e:	ec14                	sd	a3,24(s0)
 740:	f018                	sd	a4,32(s0)
 742:	f41c                	sd	a5,40(s0)
 744:	03043823          	sd	a6,48(s0)
 748:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 74c:	00840613          	addi	a2,s0,8
 750:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 754:	85aa                	mv	a1,a0
 756:	4505                	li	a0,1
 758:	d29ff0ef          	jal	480 <vprintf>
}
 75c:	60e2                	ld	ra,24(sp)
 75e:	6442                	ld	s0,16(sp)
 760:	6125                	addi	sp,sp,96
 762:	8082                	ret

0000000000000764 <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 764:	1141                	addi	sp,sp,-16
 766:	e422                	sd	s0,8(sp)
 768:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 76a:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 76e:	00001797          	auipc	a5,0x1
 772:	8927b783          	ld	a5,-1902(a5) # 1000 <freep>
 776:	a02d                	j	7a0 <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 778:	4618                	lw	a4,8(a2)
 77a:	9f2d                	addw	a4,a4,a1
 77c:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 780:	6398                	ld	a4,0(a5)
 782:	6310                	ld	a2,0(a4)
 784:	a83d                	j	7c2 <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 786:	ff852703          	lw	a4,-8(a0)
 78a:	9f31                	addw	a4,a4,a2
 78c:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 78e:	ff053683          	ld	a3,-16(a0)
 792:	a091                	j	7d6 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 794:	6398                	ld	a4,0(a5)
 796:	00e7e463          	bltu	a5,a4,79e <free+0x3a>
 79a:	00e6ea63          	bltu	a3,a4,7ae <free+0x4a>
{
 79e:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7a0:	fed7fae3          	bgeu	a5,a3,794 <free+0x30>
 7a4:	6398                	ld	a4,0(a5)
 7a6:	00e6e463          	bltu	a3,a4,7ae <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7aa:	fee7eae3          	bltu	a5,a4,79e <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7ae:	ff852583          	lw	a1,-8(a0)
 7b2:	6390                	ld	a2,0(a5)
 7b4:	02059813          	slli	a6,a1,0x20
 7b8:	01c85713          	srli	a4,a6,0x1c
 7bc:	9736                	add	a4,a4,a3
 7be:	fae60de3          	beq	a2,a4,778 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7c2:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 7c6:	4790                	lw	a2,8(a5)
 7c8:	02061593          	slli	a1,a2,0x20
 7cc:	01c5d713          	srli	a4,a1,0x1c
 7d0:	973e                	add	a4,a4,a5
 7d2:	fae68ae3          	beq	a3,a4,786 <free+0x22>
    p->s.ptr = bp->s.ptr;
 7d6:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 7d8:	00001717          	auipc	a4,0x1
 7dc:	82f73423          	sd	a5,-2008(a4) # 1000 <freep>
}
 7e0:	6422                	ld	s0,8(sp)
 7e2:	0141                	addi	sp,sp,16
 7e4:	8082                	ret

00000000000007e6 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 7e6:	7139                	addi	sp,sp,-64
 7e8:	fc06                	sd	ra,56(sp)
 7ea:	f822                	sd	s0,48(sp)
 7ec:	f426                	sd	s1,40(sp)
 7ee:	ec4e                	sd	s3,24(sp)
 7f0:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 7f2:	02051493          	slli	s1,a0,0x20
 7f6:	9081                	srli	s1,s1,0x20
 7f8:	04bd                	addi	s1,s1,15
 7fa:	8091                	srli	s1,s1,0x4
 7fc:	0014899b          	addiw	s3,s1,1
 800:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 802:	00000517          	auipc	a0,0x0
 806:	7fe53503          	ld	a0,2046(a0) # 1000 <freep>
 80a:	c915                	beqz	a0,83e <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 80c:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 80e:	4798                	lw	a4,8(a5)
 810:	08977a63          	bgeu	a4,s1,8a4 <malloc+0xbe>
 814:	f04a                	sd	s2,32(sp)
 816:	e852                	sd	s4,16(sp)
 818:	e456                	sd	s5,8(sp)
 81a:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 81c:	8a4e                	mv	s4,s3
 81e:	0009871b          	sext.w	a4,s3
 822:	6685                	lui	a3,0x1
 824:	00d77363          	bgeu	a4,a3,82a <malloc+0x44>
 828:	6a05                	lui	s4,0x1
 82a:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 82e:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 832:	00000917          	auipc	s2,0x0
 836:	7ce90913          	addi	s2,s2,1998 # 1000 <freep>
  if(p == (char*)-1)
 83a:	5afd                	li	s5,-1
 83c:	a081                	j	87c <malloc+0x96>
 83e:	f04a                	sd	s2,32(sp)
 840:	e852                	sd	s4,16(sp)
 842:	e456                	sd	s5,8(sp)
 844:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 846:	00000797          	auipc	a5,0x0
 84a:	7da78793          	addi	a5,a5,2010 # 1020 <base>
 84e:	00000717          	auipc	a4,0x0
 852:	7af73923          	sd	a5,1970(a4) # 1000 <freep>
 856:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 858:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 85c:	b7c1                	j	81c <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 85e:	6398                	ld	a4,0(a5)
 860:	e118                	sd	a4,0(a0)
 862:	a8a9                	j	8bc <malloc+0xd6>
  hp->s.size = nu;
 864:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 868:	0541                	addi	a0,a0,16
 86a:	efbff0ef          	jal	764 <free>
  return freep;
 86e:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 872:	c12d                	beqz	a0,8d4 <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 874:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 876:	4798                	lw	a4,8(a5)
 878:	02977263          	bgeu	a4,s1,89c <malloc+0xb6>
    if(p == freep)
 87c:	00093703          	ld	a4,0(s2)
 880:	853e                	mv	a0,a5
 882:	fef719e3          	bne	a4,a5,874 <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 886:	8552                	mv	a0,s4
 888:	b1bff0ef          	jal	3a2 <sbrk>
  if(p == (char*)-1)
 88c:	fd551ce3          	bne	a0,s5,864 <malloc+0x7e>
        return 0;
 890:	4501                	li	a0,0
 892:	7902                	ld	s2,32(sp)
 894:	6a42                	ld	s4,16(sp)
 896:	6aa2                	ld	s5,8(sp)
 898:	6b02                	ld	s6,0(sp)
 89a:	a03d                	j	8c8 <malloc+0xe2>
 89c:	7902                	ld	s2,32(sp)
 89e:	6a42                	ld	s4,16(sp)
 8a0:	6aa2                	ld	s5,8(sp)
 8a2:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8a4:	fae48de3          	beq	s1,a4,85e <malloc+0x78>
        p->s.size -= nunits;
 8a8:	4137073b          	subw	a4,a4,s3
 8ac:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8ae:	02071693          	slli	a3,a4,0x20
 8b2:	01c6d713          	srli	a4,a3,0x1c
 8b6:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8b8:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8bc:	00000717          	auipc	a4,0x0
 8c0:	74a73223          	sd	a0,1860(a4) # 1000 <freep>
      return (void*)(p + 1);
 8c4:	01078513          	addi	a0,a5,16
  }
}
 8c8:	70e2                	ld	ra,56(sp)
 8ca:	7442                	ld	s0,48(sp)
 8cc:	74a2                	ld	s1,40(sp)
 8ce:	69e2                	ld	s3,24(sp)
 8d0:	6121                	addi	sp,sp,64
 8d2:	8082                	ret
 8d4:	7902                	ld	s2,32(sp)
 8d6:	6a42                	ld	s4,16(sp)
 8d8:	6aa2                	ld	s5,8(sp)
 8da:	6b02                	ld	s6,0(sp)
 8dc:	b7f5                	j	8c8 <malloc+0xe2>
