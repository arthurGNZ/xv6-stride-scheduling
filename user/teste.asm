
user/_teste: formato do arquivo elf64-littleriscv


Desmontagem da seção .text:

0000000000000000 <waste_time>:
#include "kernel/types.h"
#include "user/user.h"

#define N 3

void waste_time() {
   0:	1101                	addi	sp,sp,-32
   2:	ec06                	sd	ra,24(sp)
   4:	e822                	sd	s0,16(sp)
   6:	1000                	addi	s0,sp,32
  printf("start\n");
   8:	00001517          	auipc	a0,0x1
   c:	91850513          	addi	a0,a0,-1768 # 920 <malloc+0x100>
  10:	75c000ef          	jal	76c <printf>
  
  volatile unsigned long long i;
  for (i = 0; i < 1000000000ULL; ++i);
  14:	fe043423          	sd	zero,-24(s0)
  18:	fe843703          	ld	a4,-24(s0)
  1c:	3b9ad7b7          	lui	a5,0x3b9ad
  20:	9ff78793          	addi	a5,a5,-1537 # 3b9ac9ff <base+0x3b9ab9ef>
  24:	00e7ec63          	bltu	a5,a4,3c <waste_time+0x3c>
  28:	873e                	mv	a4,a5
  2a:	fe843783          	ld	a5,-24(s0)
  2e:	0785                	addi	a5,a5,1
  30:	fef43423          	sd	a5,-24(s0)
  34:	fe843783          	ld	a5,-24(s0)
  38:	fef779e3          	bgeu	a4,a5,2a <waste_time+0x2a>
  
  printf("stop\n");
  3c:	00001517          	auipc	a0,0x1
  40:	8f450513          	addi	a0,a0,-1804 # 930 <malloc+0x110>
  44:	728000ef          	jal	76c <printf>
}
  48:	60e2                	ld	ra,24(sp)
  4a:	6442                	ld	s0,16(sp)
  4c:	6105                	addi	sp,sp,32
  4e:	8082                	ret

0000000000000050 <main>:

int main(int argc, char *argv[])
{
  50:	7179                	addi	sp,sp,-48
  52:	f406                	sd	ra,40(sp)
  54:	f022                	sd	s0,32(sp)
  56:	ec26                	sd	s1,24(sp)
  58:	e84a                	sd	s2,16(sp)
  5a:	1800                	addi	s0,sp,48
  int n, pid;
  int tickets_para_dar[] = {150, 100, 50};
  5c:	09600793          	li	a5,150
  60:	fcf42823          	sw	a5,-48(s0)
  64:	06400793          	li	a5,100
  68:	fcf42a23          	sw	a5,-44(s0)
  6c:	03200793          	li	a5,50
  70:	fcf42c23          	sw	a5,-40(s0)

  for(n = 0; n < N; n++) {
    pid = fork();
  74:	2d0000ef          	jal	344 <fork>
    if(pid == 0) {
  78:	c91d                	beqz	a0,ae <main+0x5e>
    pid = fork();
  7a:	2ca000ef          	jal	344 <fork>
    if(pid == 0) {
  7e:	c51d                	beqz	a0,ac <main+0x5c>
    pid = fork();
  80:	2c4000ef          	jal	344 <fork>
    if(pid == 0) {
  84:	448d                	li	s1,3
    }
  }

  for(n = 0; n < N; n++) {
    int finished_pid = wait(0);
    printf("Child pid = %d finished!\n", finished_pid);
  86:	00001917          	auipc	s2,0x1
  8a:	8e290913          	addi	s2,s2,-1822 # 968 <malloc+0x148>
    if(pid == 0) {
  8e:	cd09                	beqz	a0,a8 <main+0x58>
    int finished_pid = wait(0);
  90:	4501                	li	a0,0
  92:	2c2000ef          	jal	354 <wait>
  96:	85aa                	mv	a1,a0
    printf("Child pid = %d finished!\n", finished_pid);
  98:	854a                	mv	a0,s2
  9a:	6d2000ef          	jal	76c <printf>
  for(n = 0; n < N; n++) {
  9e:	34fd                	addiw	s1,s1,-1
  a0:	f8e5                	bnez	s1,90 <main+0x40>
  }

  exit(0);
  a2:	4501                	li	a0,0
  a4:	2a8000ef          	jal	34c <exit>
  a8:	4509                	li	a0,2
  aa:	a011                	j	ae <main+0x5e>
  for(n = 0; n < N; n++) {
  ac:	4505                	li	a0,1
      if (settickets(tickets_para_dar[n]) < 0) {
  ae:	050a                	slli	a0,a0,0x2
  b0:	fe050793          	addi	a5,a0,-32
  b4:	00878533          	add	a0,a5,s0
  b8:	ff052503          	lw	a0,-16(a0)
  bc:	330000ef          	jal	3ec <settickets>
  c0:	00054763          	bltz	a0,ce <main+0x7e>
      waste_time();
  c4:	f3dff0ef          	jal	0 <waste_time>
      exit(0);
  c8:	4501                	li	a0,0
  ca:	282000ef          	jal	34c <exit>
          printf("Erro: settickets() falhou para o PID %d\n", getpid());
  ce:	2fe000ef          	jal	3cc <getpid>
  d2:	85aa                	mv	a1,a0
  d4:	00001517          	auipc	a0,0x1
  d8:	86450513          	addi	a0,a0,-1948 # 938 <malloc+0x118>
  dc:	690000ef          	jal	76c <printf>
  e0:	b7d5                	j	c4 <main+0x74>

00000000000000e2 <start>:
//
// wrapper so that it's OK if main() does not call exit().
//
void
start()
{
  e2:	1141                	addi	sp,sp,-16
  e4:	e406                	sd	ra,8(sp)
  e6:	e022                	sd	s0,0(sp)
  e8:	0800                	addi	s0,sp,16
  extern int main();
  main();
  ea:	f67ff0ef          	jal	50 <main>
  exit(0);
  ee:	4501                	li	a0,0
  f0:	25c000ef          	jal	34c <exit>

00000000000000f4 <strcpy>:
}

char*
strcpy(char *s, const char *t)
{
  f4:	1141                	addi	sp,sp,-16
  f6:	e422                	sd	s0,8(sp)
  f8:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while((*s++ = *t++) != 0)
  fa:	87aa                	mv	a5,a0
  fc:	0585                	addi	a1,a1,1
  fe:	0785                	addi	a5,a5,1
 100:	fff5c703          	lbu	a4,-1(a1)
 104:	fee78fa3          	sb	a4,-1(a5)
 108:	fb75                	bnez	a4,fc <strcpy+0x8>
    ;
  return os;
}
 10a:	6422                	ld	s0,8(sp)
 10c:	0141                	addi	sp,sp,16
 10e:	8082                	ret

0000000000000110 <strcmp>:

int
strcmp(const char *p, const char *q)
{
 110:	1141                	addi	sp,sp,-16
 112:	e422                	sd	s0,8(sp)
 114:	0800                	addi	s0,sp,16
  while(*p && *p == *q)
 116:	00054783          	lbu	a5,0(a0)
 11a:	cb91                	beqz	a5,12e <strcmp+0x1e>
 11c:	0005c703          	lbu	a4,0(a1)
 120:	00f71763          	bne	a4,a5,12e <strcmp+0x1e>
    p++, q++;
 124:	0505                	addi	a0,a0,1
 126:	0585                	addi	a1,a1,1
  while(*p && *p == *q)
 128:	00054783          	lbu	a5,0(a0)
 12c:	fbe5                	bnez	a5,11c <strcmp+0xc>
  return (uchar)*p - (uchar)*q;
 12e:	0005c503          	lbu	a0,0(a1)
}
 132:	40a7853b          	subw	a0,a5,a0
 136:	6422                	ld	s0,8(sp)
 138:	0141                	addi	sp,sp,16
 13a:	8082                	ret

000000000000013c <strlen>:

uint
strlen(const char *s)
{
 13c:	1141                	addi	sp,sp,-16
 13e:	e422                	sd	s0,8(sp)
 140:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
 142:	00054783          	lbu	a5,0(a0)
 146:	cf91                	beqz	a5,162 <strlen+0x26>
 148:	0505                	addi	a0,a0,1
 14a:	87aa                	mv	a5,a0
 14c:	86be                	mv	a3,a5
 14e:	0785                	addi	a5,a5,1
 150:	fff7c703          	lbu	a4,-1(a5)
 154:	ff65                	bnez	a4,14c <strlen+0x10>
 156:	40a6853b          	subw	a0,a3,a0
 15a:	2505                	addiw	a0,a0,1
    ;
  return n;
}
 15c:	6422                	ld	s0,8(sp)
 15e:	0141                	addi	sp,sp,16
 160:	8082                	ret
  for(n = 0; s[n]; n++)
 162:	4501                	li	a0,0
 164:	bfe5                	j	15c <strlen+0x20>

0000000000000166 <memset>:

void*
memset(void *dst, int c, uint n)
{
 166:	1141                	addi	sp,sp,-16
 168:	e422                	sd	s0,8(sp)
 16a:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
 16c:	ca19                	beqz	a2,182 <memset+0x1c>
 16e:	87aa                	mv	a5,a0
 170:	1602                	slli	a2,a2,0x20
 172:	9201                	srli	a2,a2,0x20
 174:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
 178:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
 17c:	0785                	addi	a5,a5,1
 17e:	fee79de3          	bne	a5,a4,178 <memset+0x12>
  }
  return dst;
}
 182:	6422                	ld	s0,8(sp)
 184:	0141                	addi	sp,sp,16
 186:	8082                	ret

0000000000000188 <strchr>:

char*
strchr(const char *s, char c)
{
 188:	1141                	addi	sp,sp,-16
 18a:	e422                	sd	s0,8(sp)
 18c:	0800                	addi	s0,sp,16
  for(; *s; s++)
 18e:	00054783          	lbu	a5,0(a0)
 192:	cb99                	beqz	a5,1a8 <strchr+0x20>
    if(*s == c)
 194:	00f58763          	beq	a1,a5,1a2 <strchr+0x1a>
  for(; *s; s++)
 198:	0505                	addi	a0,a0,1
 19a:	00054783          	lbu	a5,0(a0)
 19e:	fbfd                	bnez	a5,194 <strchr+0xc>
      return (char*)s;
  return 0;
 1a0:	4501                	li	a0,0
}
 1a2:	6422                	ld	s0,8(sp)
 1a4:	0141                	addi	sp,sp,16
 1a6:	8082                	ret
  return 0;
 1a8:	4501                	li	a0,0
 1aa:	bfe5                	j	1a2 <strchr+0x1a>

00000000000001ac <gets>:

char*
gets(char *buf, int max)
{
 1ac:	711d                	addi	sp,sp,-96
 1ae:	ec86                	sd	ra,88(sp)
 1b0:	e8a2                	sd	s0,80(sp)
 1b2:	e4a6                	sd	s1,72(sp)
 1b4:	e0ca                	sd	s2,64(sp)
 1b6:	fc4e                	sd	s3,56(sp)
 1b8:	f852                	sd	s4,48(sp)
 1ba:	f456                	sd	s5,40(sp)
 1bc:	f05a                	sd	s6,32(sp)
 1be:	ec5e                	sd	s7,24(sp)
 1c0:	1080                	addi	s0,sp,96
 1c2:	8baa                	mv	s7,a0
 1c4:	8a2e                	mv	s4,a1
  int i, cc;
  char c;

  for(i=0; i+1 < max; ){
 1c6:	892a                	mv	s2,a0
 1c8:	4481                	li	s1,0
    cc = read(0, &c, 1);
    if(cc < 1)
      break;
    buf[i++] = c;
    if(c == '\n' || c == '\r')
 1ca:	4aa9                	li	s5,10
 1cc:	4b35                	li	s6,13
  for(i=0; i+1 < max; ){
 1ce:	89a6                	mv	s3,s1
 1d0:	2485                	addiw	s1,s1,1
 1d2:	0344d663          	bge	s1,s4,1fe <gets+0x52>
    cc = read(0, &c, 1);
 1d6:	4605                	li	a2,1
 1d8:	faf40593          	addi	a1,s0,-81
 1dc:	4501                	li	a0,0
 1de:	186000ef          	jal	364 <read>
    if(cc < 1)
 1e2:	00a05e63          	blez	a0,1fe <gets+0x52>
    buf[i++] = c;
 1e6:	faf44783          	lbu	a5,-81(s0)
 1ea:	00f90023          	sb	a5,0(s2)
    if(c == '\n' || c == '\r')
 1ee:	01578763          	beq	a5,s5,1fc <gets+0x50>
 1f2:	0905                	addi	s2,s2,1
 1f4:	fd679de3          	bne	a5,s6,1ce <gets+0x22>
    buf[i++] = c;
 1f8:	89a6                	mv	s3,s1
 1fa:	a011                	j	1fe <gets+0x52>
 1fc:	89a6                	mv	s3,s1
      break;
  }
  buf[i] = '\0';
 1fe:	99de                	add	s3,s3,s7
 200:	00098023          	sb	zero,0(s3)
  return buf;
}
 204:	855e                	mv	a0,s7
 206:	60e6                	ld	ra,88(sp)
 208:	6446                	ld	s0,80(sp)
 20a:	64a6                	ld	s1,72(sp)
 20c:	6906                	ld	s2,64(sp)
 20e:	79e2                	ld	s3,56(sp)
 210:	7a42                	ld	s4,48(sp)
 212:	7aa2                	ld	s5,40(sp)
 214:	7b02                	ld	s6,32(sp)
 216:	6be2                	ld	s7,24(sp)
 218:	6125                	addi	sp,sp,96
 21a:	8082                	ret

000000000000021c <stat>:

int
stat(const char *n, struct stat *st)
{
 21c:	1101                	addi	sp,sp,-32
 21e:	ec06                	sd	ra,24(sp)
 220:	e822                	sd	s0,16(sp)
 222:	e04a                	sd	s2,0(sp)
 224:	1000                	addi	s0,sp,32
 226:	892e                	mv	s2,a1
  int fd;
  int r;

  fd = open(n, O_RDONLY);
 228:	4581                	li	a1,0
 22a:	162000ef          	jal	38c <open>
  if(fd < 0)
 22e:	02054263          	bltz	a0,252 <stat+0x36>
 232:	e426                	sd	s1,8(sp)
 234:	84aa                	mv	s1,a0
    return -1;
  r = fstat(fd, st);
 236:	85ca                	mv	a1,s2
 238:	16c000ef          	jal	3a4 <fstat>
 23c:	892a                	mv	s2,a0
  close(fd);
 23e:	8526                	mv	a0,s1
 240:	134000ef          	jal	374 <close>
  return r;
 244:	64a2                	ld	s1,8(sp)
}
 246:	854a                	mv	a0,s2
 248:	60e2                	ld	ra,24(sp)
 24a:	6442                	ld	s0,16(sp)
 24c:	6902                	ld	s2,0(sp)
 24e:	6105                	addi	sp,sp,32
 250:	8082                	ret
    return -1;
 252:	597d                	li	s2,-1
 254:	bfcd                	j	246 <stat+0x2a>

0000000000000256 <atoi>:

int
atoi(const char *s)
{
 256:	1141                	addi	sp,sp,-16
 258:	e422                	sd	s0,8(sp)
 25a:	0800                	addi	s0,sp,16
  int n;

  n = 0;
  while('0' <= *s && *s <= '9')
 25c:	00054683          	lbu	a3,0(a0)
 260:	fd06879b          	addiw	a5,a3,-48
 264:	0ff7f793          	zext.b	a5,a5
 268:	4625                	li	a2,9
 26a:	02f66863          	bltu	a2,a5,29a <atoi+0x44>
 26e:	872a                	mv	a4,a0
  n = 0;
 270:	4501                	li	a0,0
    n = n*10 + *s++ - '0';
 272:	0705                	addi	a4,a4,1
 274:	0025179b          	slliw	a5,a0,0x2
 278:	9fa9                	addw	a5,a5,a0
 27a:	0017979b          	slliw	a5,a5,0x1
 27e:	9fb5                	addw	a5,a5,a3
 280:	fd07851b          	addiw	a0,a5,-48
  while('0' <= *s && *s <= '9')
 284:	00074683          	lbu	a3,0(a4)
 288:	fd06879b          	addiw	a5,a3,-48
 28c:	0ff7f793          	zext.b	a5,a5
 290:	fef671e3          	bgeu	a2,a5,272 <atoi+0x1c>
  return n;
}
 294:	6422                	ld	s0,8(sp)
 296:	0141                	addi	sp,sp,16
 298:	8082                	ret
  n = 0;
 29a:	4501                	li	a0,0
 29c:	bfe5                	j	294 <atoi+0x3e>

000000000000029e <memmove>:

void*
memmove(void *vdst, const void *vsrc, int n)
{
 29e:	1141                	addi	sp,sp,-16
 2a0:	e422                	sd	s0,8(sp)
 2a2:	0800                	addi	s0,sp,16
  char *dst;
  const char *src;

  dst = vdst;
  src = vsrc;
  if (src > dst) {
 2a4:	02b57463          	bgeu	a0,a1,2cc <memmove+0x2e>
    while(n-- > 0)
 2a8:	00c05f63          	blez	a2,2c6 <memmove+0x28>
 2ac:	1602                	slli	a2,a2,0x20
 2ae:	9201                	srli	a2,a2,0x20
 2b0:	00c507b3          	add	a5,a0,a2
  dst = vdst;
 2b4:	872a                	mv	a4,a0
      *dst++ = *src++;
 2b6:	0585                	addi	a1,a1,1
 2b8:	0705                	addi	a4,a4,1
 2ba:	fff5c683          	lbu	a3,-1(a1)
 2be:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
 2c2:	fef71ae3          	bne	a4,a5,2b6 <memmove+0x18>
    src += n;
    while(n-- > 0)
      *--dst = *--src;
  }
  return vdst;
}
 2c6:	6422                	ld	s0,8(sp)
 2c8:	0141                	addi	sp,sp,16
 2ca:	8082                	ret
    dst += n;
 2cc:	00c50733          	add	a4,a0,a2
    src += n;
 2d0:	95b2                	add	a1,a1,a2
    while(n-- > 0)
 2d2:	fec05ae3          	blez	a2,2c6 <memmove+0x28>
 2d6:	fff6079b          	addiw	a5,a2,-1
 2da:	1782                	slli	a5,a5,0x20
 2dc:	9381                	srli	a5,a5,0x20
 2de:	fff7c793          	not	a5,a5
 2e2:	97ba                	add	a5,a5,a4
      *--dst = *--src;
 2e4:	15fd                	addi	a1,a1,-1
 2e6:	177d                	addi	a4,a4,-1
 2e8:	0005c683          	lbu	a3,0(a1)
 2ec:	00d70023          	sb	a3,0(a4)
    while(n-- > 0)
 2f0:	fee79ae3          	bne	a5,a4,2e4 <memmove+0x46>
 2f4:	bfc9                	j	2c6 <memmove+0x28>

00000000000002f6 <memcmp>:

int
memcmp(const void *s1, const void *s2, uint n)
{
 2f6:	1141                	addi	sp,sp,-16
 2f8:	e422                	sd	s0,8(sp)
 2fa:	0800                	addi	s0,sp,16
  const char *p1 = s1, *p2 = s2;
  while (n-- > 0) {
 2fc:	ca05                	beqz	a2,32c <memcmp+0x36>
 2fe:	fff6069b          	addiw	a3,a2,-1
 302:	1682                	slli	a3,a3,0x20
 304:	9281                	srli	a3,a3,0x20
 306:	0685                	addi	a3,a3,1
 308:	96aa                	add	a3,a3,a0
    if (*p1 != *p2) {
 30a:	00054783          	lbu	a5,0(a0)
 30e:	0005c703          	lbu	a4,0(a1)
 312:	00e79863          	bne	a5,a4,322 <memcmp+0x2c>
      return *p1 - *p2;
    }
    p1++;
 316:	0505                	addi	a0,a0,1
    p2++;
 318:	0585                	addi	a1,a1,1
  while (n-- > 0) {
 31a:	fed518e3          	bne	a0,a3,30a <memcmp+0x14>
  }
  return 0;
 31e:	4501                	li	a0,0
 320:	a019                	j	326 <memcmp+0x30>
      return *p1 - *p2;
 322:	40e7853b          	subw	a0,a5,a4
}
 326:	6422                	ld	s0,8(sp)
 328:	0141                	addi	sp,sp,16
 32a:	8082                	ret
  return 0;
 32c:	4501                	li	a0,0
 32e:	bfe5                	j	326 <memcmp+0x30>

0000000000000330 <memcpy>:

void *
memcpy(void *dst, const void *src, uint n)
{
 330:	1141                	addi	sp,sp,-16
 332:	e406                	sd	ra,8(sp)
 334:	e022                	sd	s0,0(sp)
 336:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
 338:	f67ff0ef          	jal	29e <memmove>
}
 33c:	60a2                	ld	ra,8(sp)
 33e:	6402                	ld	s0,0(sp)
 340:	0141                	addi	sp,sp,16
 342:	8082                	ret

0000000000000344 <fork>:
# generated by usys.pl - do not edit
#include "kernel/syscall.h"
.global fork
fork:
 li a7, SYS_fork
 344:	4885                	li	a7,1
 ecall
 346:	00000073          	ecall
 ret
 34a:	8082                	ret

000000000000034c <exit>:
.global exit
exit:
 li a7, SYS_exit
 34c:	4889                	li	a7,2
 ecall
 34e:	00000073          	ecall
 ret
 352:	8082                	ret

0000000000000354 <wait>:
.global wait
wait:
 li a7, SYS_wait
 354:	488d                	li	a7,3
 ecall
 356:	00000073          	ecall
 ret
 35a:	8082                	ret

000000000000035c <pipe>:
.global pipe
pipe:
 li a7, SYS_pipe
 35c:	4891                	li	a7,4
 ecall
 35e:	00000073          	ecall
 ret
 362:	8082                	ret

0000000000000364 <read>:
.global read
read:
 li a7, SYS_read
 364:	4895                	li	a7,5
 ecall
 366:	00000073          	ecall
 ret
 36a:	8082                	ret

000000000000036c <write>:
.global write
write:
 li a7, SYS_write
 36c:	48c1                	li	a7,16
 ecall
 36e:	00000073          	ecall
 ret
 372:	8082                	ret

0000000000000374 <close>:
.global close
close:
 li a7, SYS_close
 374:	48d5                	li	a7,21
 ecall
 376:	00000073          	ecall
 ret
 37a:	8082                	ret

000000000000037c <kill>:
.global kill
kill:
 li a7, SYS_kill
 37c:	4899                	li	a7,6
 ecall
 37e:	00000073          	ecall
 ret
 382:	8082                	ret

0000000000000384 <exec>:
.global exec
exec:
 li a7, SYS_exec
 384:	489d                	li	a7,7
 ecall
 386:	00000073          	ecall
 ret
 38a:	8082                	ret

000000000000038c <open>:
.global open
open:
 li a7, SYS_open
 38c:	48bd                	li	a7,15
 ecall
 38e:	00000073          	ecall
 ret
 392:	8082                	ret

0000000000000394 <mknod>:
.global mknod
mknod:
 li a7, SYS_mknod
 394:	48c5                	li	a7,17
 ecall
 396:	00000073          	ecall
 ret
 39a:	8082                	ret

000000000000039c <unlink>:
.global unlink
unlink:
 li a7, SYS_unlink
 39c:	48c9                	li	a7,18
 ecall
 39e:	00000073          	ecall
 ret
 3a2:	8082                	ret

00000000000003a4 <fstat>:
.global fstat
fstat:
 li a7, SYS_fstat
 3a4:	48a1                	li	a7,8
 ecall
 3a6:	00000073          	ecall
 ret
 3aa:	8082                	ret

00000000000003ac <link>:
.global link
link:
 li a7, SYS_link
 3ac:	48cd                	li	a7,19
 ecall
 3ae:	00000073          	ecall
 ret
 3b2:	8082                	ret

00000000000003b4 <mkdir>:
.global mkdir
mkdir:
 li a7, SYS_mkdir
 3b4:	48d1                	li	a7,20
 ecall
 3b6:	00000073          	ecall
 ret
 3ba:	8082                	ret

00000000000003bc <chdir>:
.global chdir
chdir:
 li a7, SYS_chdir
 3bc:	48a5                	li	a7,9
 ecall
 3be:	00000073          	ecall
 ret
 3c2:	8082                	ret

00000000000003c4 <dup>:
.global dup
dup:
 li a7, SYS_dup
 3c4:	48a9                	li	a7,10
 ecall
 3c6:	00000073          	ecall
 ret
 3ca:	8082                	ret

00000000000003cc <getpid>:
.global getpid
getpid:
 li a7, SYS_getpid
 3cc:	48ad                	li	a7,11
 ecall
 3ce:	00000073          	ecall
 ret
 3d2:	8082                	ret

00000000000003d4 <sbrk>:
.global sbrk
sbrk:
 li a7, SYS_sbrk
 3d4:	48b1                	li	a7,12
 ecall
 3d6:	00000073          	ecall
 ret
 3da:	8082                	ret

00000000000003dc <sleep>:
.global sleep
sleep:
 li a7, SYS_sleep
 3dc:	48b5                	li	a7,13
 ecall
 3de:	00000073          	ecall
 ret
 3e2:	8082                	ret

00000000000003e4 <uptime>:
.global uptime
uptime:
 li a7, SYS_uptime
 3e4:	48b9                	li	a7,14
 ecall
 3e6:	00000073          	ecall
 ret
 3ea:	8082                	ret

00000000000003ec <settickets>:
.global settickets
settickets:
 li a7, SYS_settickets
 3ec:	48d9                	li	a7,22
 ecall
 3ee:	00000073          	ecall
 ret
 3f2:	8082                	ret

00000000000003f4 <putc>:

static char digits[] = "0123456789ABCDEF";

static void
putc(int fd, char c)
{
 3f4:	1101                	addi	sp,sp,-32
 3f6:	ec06                	sd	ra,24(sp)
 3f8:	e822                	sd	s0,16(sp)
 3fa:	1000                	addi	s0,sp,32
 3fc:	feb407a3          	sb	a1,-17(s0)
  write(fd, &c, 1);
 400:	4605                	li	a2,1
 402:	fef40593          	addi	a1,s0,-17
 406:	f67ff0ef          	jal	36c <write>
}
 40a:	60e2                	ld	ra,24(sp)
 40c:	6442                	ld	s0,16(sp)
 40e:	6105                	addi	sp,sp,32
 410:	8082                	ret

0000000000000412 <printint>:

static void
printint(int fd, int xx, int base, int sgn)
{
 412:	7139                	addi	sp,sp,-64
 414:	fc06                	sd	ra,56(sp)
 416:	f822                	sd	s0,48(sp)
 418:	f426                	sd	s1,40(sp)
 41a:	0080                	addi	s0,sp,64
 41c:	84aa                	mv	s1,a0
  char buf[16];
  int i, neg;
  uint x;

  neg = 0;
  if(sgn && xx < 0){
 41e:	c299                	beqz	a3,424 <printint+0x12>
 420:	0805c963          	bltz	a1,4b2 <printint+0xa0>
    neg = 1;
    x = -xx;
  } else {
    x = xx;
 424:	2581                	sext.w	a1,a1
  neg = 0;
 426:	4881                	li	a7,0
 428:	fc040693          	addi	a3,s0,-64
  }

  i = 0;
 42c:	4701                	li	a4,0
  do{
    buf[i++] = digits[x % base];
 42e:	2601                	sext.w	a2,a2
 430:	00000517          	auipc	a0,0x0
 434:	56050513          	addi	a0,a0,1376 # 990 <digits>
 438:	883a                	mv	a6,a4
 43a:	2705                	addiw	a4,a4,1
 43c:	02c5f7bb          	remuw	a5,a1,a2
 440:	1782                	slli	a5,a5,0x20
 442:	9381                	srli	a5,a5,0x20
 444:	97aa                	add	a5,a5,a0
 446:	0007c783          	lbu	a5,0(a5)
 44a:	00f68023          	sb	a5,0(a3)
  }while((x /= base) != 0);
 44e:	0005879b          	sext.w	a5,a1
 452:	02c5d5bb          	divuw	a1,a1,a2
 456:	0685                	addi	a3,a3,1
 458:	fec7f0e3          	bgeu	a5,a2,438 <printint+0x26>
  if(neg)
 45c:	00088c63          	beqz	a7,474 <printint+0x62>
    buf[i++] = '-';
 460:	fd070793          	addi	a5,a4,-48
 464:	00878733          	add	a4,a5,s0
 468:	02d00793          	li	a5,45
 46c:	fef70823          	sb	a5,-16(a4)
 470:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
 474:	02e05a63          	blez	a4,4a8 <printint+0x96>
 478:	f04a                	sd	s2,32(sp)
 47a:	ec4e                	sd	s3,24(sp)
 47c:	fc040793          	addi	a5,s0,-64
 480:	00e78933          	add	s2,a5,a4
 484:	fff78993          	addi	s3,a5,-1
 488:	99ba                	add	s3,s3,a4
 48a:	377d                	addiw	a4,a4,-1
 48c:	1702                	slli	a4,a4,0x20
 48e:	9301                	srli	a4,a4,0x20
 490:	40e989b3          	sub	s3,s3,a4
    putc(fd, buf[i]);
 494:	fff94583          	lbu	a1,-1(s2)
 498:	8526                	mv	a0,s1
 49a:	f5bff0ef          	jal	3f4 <putc>
  while(--i >= 0)
 49e:	197d                	addi	s2,s2,-1
 4a0:	ff391ae3          	bne	s2,s3,494 <printint+0x82>
 4a4:	7902                	ld	s2,32(sp)
 4a6:	69e2                	ld	s3,24(sp)
}
 4a8:	70e2                	ld	ra,56(sp)
 4aa:	7442                	ld	s0,48(sp)
 4ac:	74a2                	ld	s1,40(sp)
 4ae:	6121                	addi	sp,sp,64
 4b0:	8082                	ret
    x = -xx;
 4b2:	40b005bb          	negw	a1,a1
    neg = 1;
 4b6:	4885                	li	a7,1
    x = -xx;
 4b8:	bf85                	j	428 <printint+0x16>

00000000000004ba <vprintf>:
}

// Print to the given fd. Only understands %d, %x, %p, %s.
void
vprintf(int fd, const char *fmt, va_list ap)
{
 4ba:	711d                	addi	sp,sp,-96
 4bc:	ec86                	sd	ra,88(sp)
 4be:	e8a2                	sd	s0,80(sp)
 4c0:	e0ca                	sd	s2,64(sp)
 4c2:	1080                	addi	s0,sp,96
  char *s;
  int c0, c1, c2, i, state;

  state = 0;
  for(i = 0; fmt[i]; i++){
 4c4:	0005c903          	lbu	s2,0(a1)
 4c8:	26090863          	beqz	s2,738 <vprintf+0x27e>
 4cc:	e4a6                	sd	s1,72(sp)
 4ce:	fc4e                	sd	s3,56(sp)
 4d0:	f852                	sd	s4,48(sp)
 4d2:	f456                	sd	s5,40(sp)
 4d4:	f05a                	sd	s6,32(sp)
 4d6:	ec5e                	sd	s7,24(sp)
 4d8:	e862                	sd	s8,16(sp)
 4da:	e466                	sd	s9,8(sp)
 4dc:	8b2a                	mv	s6,a0
 4de:	8a2e                	mv	s4,a1
 4e0:	8bb2                	mv	s7,a2
  state = 0;
 4e2:	4981                	li	s3,0
  for(i = 0; fmt[i]; i++){
 4e4:	4481                	li	s1,0
 4e6:	4701                	li	a4,0
      if(c0 == '%'){
        state = '%';
      } else {
        putc(fd, c0);
      }
    } else if(state == '%'){
 4e8:	02500a93          	li	s5,37
      c1 = c2 = 0;
      if(c0) c1 = fmt[i+1] & 0xff;
      if(c1) c2 = fmt[i+2] & 0xff;
      if(c0 == 'd'){
 4ec:	06400c13          	li	s8,100
        printint(fd, va_arg(ap, int), 10, 1);
      } else if(c0 == 'l' && c1 == 'd'){
 4f0:	06c00c93          	li	s9,108
 4f4:	a005                	j	514 <vprintf+0x5a>
        putc(fd, c0);
 4f6:	85ca                	mv	a1,s2
 4f8:	855a                	mv	a0,s6
 4fa:	efbff0ef          	jal	3f4 <putc>
 4fe:	a019                	j	504 <vprintf+0x4a>
    } else if(state == '%'){
 500:	03598263          	beq	s3,s5,524 <vprintf+0x6a>
  for(i = 0; fmt[i]; i++){
 504:	2485                	addiw	s1,s1,1
 506:	8726                	mv	a4,s1
 508:	009a07b3          	add	a5,s4,s1
 50c:	0007c903          	lbu	s2,0(a5)
 510:	20090c63          	beqz	s2,728 <vprintf+0x26e>
    c0 = fmt[i] & 0xff;
 514:	0009079b          	sext.w	a5,s2
    if(state == 0){
 518:	fe0994e3          	bnez	s3,500 <vprintf+0x46>
      if(c0 == '%'){
 51c:	fd579de3          	bne	a5,s5,4f6 <vprintf+0x3c>
        state = '%';
 520:	89be                	mv	s3,a5
 522:	b7cd                	j	504 <vprintf+0x4a>
      if(c0) c1 = fmt[i+1] & 0xff;
 524:	00ea06b3          	add	a3,s4,a4
 528:	0016c683          	lbu	a3,1(a3)
      c1 = c2 = 0;
 52c:	8636                	mv	a2,a3
      if(c1) c2 = fmt[i+2] & 0xff;
 52e:	c681                	beqz	a3,536 <vprintf+0x7c>
 530:	9752                	add	a4,a4,s4
 532:	00274603          	lbu	a2,2(a4)
      if(c0 == 'd'){
 536:	03878f63          	beq	a5,s8,574 <vprintf+0xba>
      } else if(c0 == 'l' && c1 == 'd'){
 53a:	05978963          	beq	a5,s9,58c <vprintf+0xd2>
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
        printint(fd, va_arg(ap, uint64), 10, 1);
        i += 2;
      } else if(c0 == 'u'){
 53e:	07500713          	li	a4,117
 542:	0ee78363          	beq	a5,a4,628 <vprintf+0x16e>
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
        printint(fd, va_arg(ap, uint64), 10, 0);
        i += 2;
      } else if(c0 == 'x'){
 546:	07800713          	li	a4,120
 54a:	12e78563          	beq	a5,a4,674 <vprintf+0x1ba>
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 1;
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
        printint(fd, va_arg(ap, uint64), 16, 0);
        i += 2;
      } else if(c0 == 'p'){
 54e:	07000713          	li	a4,112
 552:	14e78a63          	beq	a5,a4,6a6 <vprintf+0x1ec>
        printptr(fd, va_arg(ap, uint64));
      } else if(c0 == 's'){
 556:	07300713          	li	a4,115
 55a:	18e78a63          	beq	a5,a4,6ee <vprintf+0x234>
        if((s = va_arg(ap, char*)) == 0)
          s = "(null)";
        for(; *s; s++)
          putc(fd, *s);
      } else if(c0 == '%'){
 55e:	02500713          	li	a4,37
 562:	04e79563          	bne	a5,a4,5ac <vprintf+0xf2>
        putc(fd, '%');
 566:	02500593          	li	a1,37
 56a:	855a                	mv	a0,s6
 56c:	e89ff0ef          	jal	3f4 <putc>
        // Unknown % sequence.  Print it to draw attention.
        putc(fd, '%');
        putc(fd, c);
      }
#endif
      state = 0;
 570:	4981                	li	s3,0
 572:	bf49                	j	504 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 1);
 574:	008b8913          	addi	s2,s7,8
 578:	4685                	li	a3,1
 57a:	4629                	li	a2,10
 57c:	000ba583          	lw	a1,0(s7)
 580:	855a                	mv	a0,s6
 582:	e91ff0ef          	jal	412 <printint>
 586:	8bca                	mv	s7,s2
      state = 0;
 588:	4981                	li	s3,0
 58a:	bfad                	j	504 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'd'){
 58c:	06400793          	li	a5,100
 590:	02f68963          	beq	a3,a5,5c2 <vprintf+0x108>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 594:	06c00793          	li	a5,108
 598:	04f68263          	beq	a3,a5,5dc <vprintf+0x122>
      } else if(c0 == 'l' && c1 == 'u'){
 59c:	07500793          	li	a5,117
 5a0:	0af68063          	beq	a3,a5,640 <vprintf+0x186>
      } else if(c0 == 'l' && c1 == 'x'){
 5a4:	07800793          	li	a5,120
 5a8:	0ef68263          	beq	a3,a5,68c <vprintf+0x1d2>
        putc(fd, '%');
 5ac:	02500593          	li	a1,37
 5b0:	855a                	mv	a0,s6
 5b2:	e43ff0ef          	jal	3f4 <putc>
        putc(fd, c0);
 5b6:	85ca                	mv	a1,s2
 5b8:	855a                	mv	a0,s6
 5ba:	e3bff0ef          	jal	3f4 <putc>
      state = 0;
 5be:	4981                	li	s3,0
 5c0:	b791                	j	504 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 5c2:	008b8913          	addi	s2,s7,8
 5c6:	4685                	li	a3,1
 5c8:	4629                	li	a2,10
 5ca:	000ba583          	lw	a1,0(s7)
 5ce:	855a                	mv	a0,s6
 5d0:	e43ff0ef          	jal	412 <printint>
        i += 1;
 5d4:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 1);
 5d6:	8bca                	mv	s7,s2
      state = 0;
 5d8:	4981                	li	s3,0
        i += 1;
 5da:	b72d                	j	504 <vprintf+0x4a>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
 5dc:	06400793          	li	a5,100
 5e0:	02f60763          	beq	a2,a5,60e <vprintf+0x154>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
 5e4:	07500793          	li	a5,117
 5e8:	06f60963          	beq	a2,a5,65a <vprintf+0x1a0>
      } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
 5ec:	07800793          	li	a5,120
 5f0:	faf61ee3          	bne	a2,a5,5ac <vprintf+0xf2>
        printint(fd, va_arg(ap, uint64), 16, 0);
 5f4:	008b8913          	addi	s2,s7,8
 5f8:	4681                	li	a3,0
 5fa:	4641                	li	a2,16
 5fc:	000ba583          	lw	a1,0(s7)
 600:	855a                	mv	a0,s6
 602:	e11ff0ef          	jal	412 <printint>
        i += 2;
 606:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 16, 0);
 608:	8bca                	mv	s7,s2
      state = 0;
 60a:	4981                	li	s3,0
        i += 2;
 60c:	bde5                	j	504 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 1);
 60e:	008b8913          	addi	s2,s7,8
 612:	4685                	li	a3,1
 614:	4629                	li	a2,10
 616:	000ba583          	lw	a1,0(s7)
 61a:	855a                	mv	a0,s6
 61c:	df7ff0ef          	jal	412 <printint>
        i += 2;
 620:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 1);
 622:	8bca                	mv	s7,s2
      state = 0;
 624:	4981                	li	s3,0
        i += 2;
 626:	bdf9                	j	504 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 10, 0);
 628:	008b8913          	addi	s2,s7,8
 62c:	4681                	li	a3,0
 62e:	4629                	li	a2,10
 630:	000ba583          	lw	a1,0(s7)
 634:	855a                	mv	a0,s6
 636:	dddff0ef          	jal	412 <printint>
 63a:	8bca                	mv	s7,s2
      state = 0;
 63c:	4981                	li	s3,0
 63e:	b5d9                	j	504 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 640:	008b8913          	addi	s2,s7,8
 644:	4681                	li	a3,0
 646:	4629                	li	a2,10
 648:	000ba583          	lw	a1,0(s7)
 64c:	855a                	mv	a0,s6
 64e:	dc5ff0ef          	jal	412 <printint>
        i += 1;
 652:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 10, 0);
 654:	8bca                	mv	s7,s2
      state = 0;
 656:	4981                	li	s3,0
        i += 1;
 658:	b575                	j	504 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 10, 0);
 65a:	008b8913          	addi	s2,s7,8
 65e:	4681                	li	a3,0
 660:	4629                	li	a2,10
 662:	000ba583          	lw	a1,0(s7)
 666:	855a                	mv	a0,s6
 668:	dabff0ef          	jal	412 <printint>
        i += 2;
 66c:	2489                	addiw	s1,s1,2
        printint(fd, va_arg(ap, uint64), 10, 0);
 66e:	8bca                	mv	s7,s2
      state = 0;
 670:	4981                	li	s3,0
        i += 2;
 672:	bd49                	j	504 <vprintf+0x4a>
        printint(fd, va_arg(ap, int), 16, 0);
 674:	008b8913          	addi	s2,s7,8
 678:	4681                	li	a3,0
 67a:	4641                	li	a2,16
 67c:	000ba583          	lw	a1,0(s7)
 680:	855a                	mv	a0,s6
 682:	d91ff0ef          	jal	412 <printint>
 686:	8bca                	mv	s7,s2
      state = 0;
 688:	4981                	li	s3,0
 68a:	bdad                	j	504 <vprintf+0x4a>
        printint(fd, va_arg(ap, uint64), 16, 0);
 68c:	008b8913          	addi	s2,s7,8
 690:	4681                	li	a3,0
 692:	4641                	li	a2,16
 694:	000ba583          	lw	a1,0(s7)
 698:	855a                	mv	a0,s6
 69a:	d79ff0ef          	jal	412 <printint>
        i += 1;
 69e:	2485                	addiw	s1,s1,1
        printint(fd, va_arg(ap, uint64), 16, 0);
 6a0:	8bca                	mv	s7,s2
      state = 0;
 6a2:	4981                	li	s3,0
        i += 1;
 6a4:	b585                	j	504 <vprintf+0x4a>
 6a6:	e06a                	sd	s10,0(sp)
        printptr(fd, va_arg(ap, uint64));
 6a8:	008b8d13          	addi	s10,s7,8
 6ac:	000bb983          	ld	s3,0(s7)
  putc(fd, '0');
 6b0:	03000593          	li	a1,48
 6b4:	855a                	mv	a0,s6
 6b6:	d3fff0ef          	jal	3f4 <putc>
  putc(fd, 'x');
 6ba:	07800593          	li	a1,120
 6be:	855a                	mv	a0,s6
 6c0:	d35ff0ef          	jal	3f4 <putc>
 6c4:	4941                	li	s2,16
    putc(fd, digits[x >> (sizeof(uint64) * 8 - 4)]);
 6c6:	00000b97          	auipc	s7,0x0
 6ca:	2cab8b93          	addi	s7,s7,714 # 990 <digits>
 6ce:	03c9d793          	srli	a5,s3,0x3c
 6d2:	97de                	add	a5,a5,s7
 6d4:	0007c583          	lbu	a1,0(a5)
 6d8:	855a                	mv	a0,s6
 6da:	d1bff0ef          	jal	3f4 <putc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
 6de:	0992                	slli	s3,s3,0x4
 6e0:	397d                	addiw	s2,s2,-1
 6e2:	fe0916e3          	bnez	s2,6ce <vprintf+0x214>
        printptr(fd, va_arg(ap, uint64));
 6e6:	8bea                	mv	s7,s10
      state = 0;
 6e8:	4981                	li	s3,0
 6ea:	6d02                	ld	s10,0(sp)
 6ec:	bd21                	j	504 <vprintf+0x4a>
        if((s = va_arg(ap, char*)) == 0)
 6ee:	008b8993          	addi	s3,s7,8
 6f2:	000bb903          	ld	s2,0(s7)
 6f6:	00090f63          	beqz	s2,714 <vprintf+0x25a>
        for(; *s; s++)
 6fa:	00094583          	lbu	a1,0(s2)
 6fe:	c195                	beqz	a1,722 <vprintf+0x268>
          putc(fd, *s);
 700:	855a                	mv	a0,s6
 702:	cf3ff0ef          	jal	3f4 <putc>
        for(; *s; s++)
 706:	0905                	addi	s2,s2,1
 708:	00094583          	lbu	a1,0(s2)
 70c:	f9f5                	bnez	a1,700 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 70e:	8bce                	mv	s7,s3
      state = 0;
 710:	4981                	li	s3,0
 712:	bbcd                	j	504 <vprintf+0x4a>
          s = "(null)";
 714:	00000917          	auipc	s2,0x0
 718:	27490913          	addi	s2,s2,628 # 988 <malloc+0x168>
        for(; *s; s++)
 71c:	02800593          	li	a1,40
 720:	b7c5                	j	700 <vprintf+0x246>
        if((s = va_arg(ap, char*)) == 0)
 722:	8bce                	mv	s7,s3
      state = 0;
 724:	4981                	li	s3,0
 726:	bbf9                	j	504 <vprintf+0x4a>
 728:	64a6                	ld	s1,72(sp)
 72a:	79e2                	ld	s3,56(sp)
 72c:	7a42                	ld	s4,48(sp)
 72e:	7aa2                	ld	s5,40(sp)
 730:	7b02                	ld	s6,32(sp)
 732:	6be2                	ld	s7,24(sp)
 734:	6c42                	ld	s8,16(sp)
 736:	6ca2                	ld	s9,8(sp)
    }
  }
}
 738:	60e6                	ld	ra,88(sp)
 73a:	6446                	ld	s0,80(sp)
 73c:	6906                	ld	s2,64(sp)
 73e:	6125                	addi	sp,sp,96
 740:	8082                	ret

0000000000000742 <fprintf>:

void
fprintf(int fd, const char *fmt, ...)
{
 742:	715d                	addi	sp,sp,-80
 744:	ec06                	sd	ra,24(sp)
 746:	e822                	sd	s0,16(sp)
 748:	1000                	addi	s0,sp,32
 74a:	e010                	sd	a2,0(s0)
 74c:	e414                	sd	a3,8(s0)
 74e:	e818                	sd	a4,16(s0)
 750:	ec1c                	sd	a5,24(s0)
 752:	03043023          	sd	a6,32(s0)
 756:	03143423          	sd	a7,40(s0)
  va_list ap;

  va_start(ap, fmt);
 75a:	fe843423          	sd	s0,-24(s0)
  vprintf(fd, fmt, ap);
 75e:	8622                	mv	a2,s0
 760:	d5bff0ef          	jal	4ba <vprintf>
}
 764:	60e2                	ld	ra,24(sp)
 766:	6442                	ld	s0,16(sp)
 768:	6161                	addi	sp,sp,80
 76a:	8082                	ret

000000000000076c <printf>:

void
printf(const char *fmt, ...)
{
 76c:	711d                	addi	sp,sp,-96
 76e:	ec06                	sd	ra,24(sp)
 770:	e822                	sd	s0,16(sp)
 772:	1000                	addi	s0,sp,32
 774:	e40c                	sd	a1,8(s0)
 776:	e810                	sd	a2,16(s0)
 778:	ec14                	sd	a3,24(s0)
 77a:	f018                	sd	a4,32(s0)
 77c:	f41c                	sd	a5,40(s0)
 77e:	03043823          	sd	a6,48(s0)
 782:	03143c23          	sd	a7,56(s0)
  va_list ap;

  va_start(ap, fmt);
 786:	00840613          	addi	a2,s0,8
 78a:	fec43423          	sd	a2,-24(s0)
  vprintf(1, fmt, ap);
 78e:	85aa                	mv	a1,a0
 790:	4505                	li	a0,1
 792:	d29ff0ef          	jal	4ba <vprintf>
}
 796:	60e2                	ld	ra,24(sp)
 798:	6442                	ld	s0,16(sp)
 79a:	6125                	addi	sp,sp,96
 79c:	8082                	ret

000000000000079e <free>:
static Header base;
static Header *freep;

void
free(void *ap)
{
 79e:	1141                	addi	sp,sp,-16
 7a0:	e422                	sd	s0,8(sp)
 7a2:	0800                	addi	s0,sp,16
  Header *bp, *p;

  bp = (Header*)ap - 1;
 7a4:	ff050693          	addi	a3,a0,-16
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7a8:	00001797          	auipc	a5,0x1
 7ac:	8587b783          	ld	a5,-1960(a5) # 1000 <freep>
 7b0:	a02d                	j	7da <free+0x3c>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
      break;
  if(bp + bp->s.size == p->s.ptr){
    bp->s.size += p->s.ptr->s.size;
 7b2:	4618                	lw	a4,8(a2)
 7b4:	9f2d                	addw	a4,a4,a1
 7b6:	fee52c23          	sw	a4,-8(a0)
    bp->s.ptr = p->s.ptr->s.ptr;
 7ba:	6398                	ld	a4,0(a5)
 7bc:	6310                	ld	a2,0(a4)
 7be:	a83d                	j	7fc <free+0x5e>
  } else
    bp->s.ptr = p->s.ptr;
  if(p + p->s.size == bp){
    p->s.size += bp->s.size;
 7c0:	ff852703          	lw	a4,-8(a0)
 7c4:	9f31                	addw	a4,a4,a2
 7c6:	c798                	sw	a4,8(a5)
    p->s.ptr = bp->s.ptr;
 7c8:	ff053683          	ld	a3,-16(a0)
 7cc:	a091                	j	810 <free+0x72>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7ce:	6398                	ld	a4,0(a5)
 7d0:	00e7e463          	bltu	a5,a4,7d8 <free+0x3a>
 7d4:	00e6ea63          	bltu	a3,a4,7e8 <free+0x4a>
{
 7d8:	87ba                	mv	a5,a4
  for(p = freep; !(bp > p && bp < p->s.ptr); p = p->s.ptr)
 7da:	fed7fae3          	bgeu	a5,a3,7ce <free+0x30>
 7de:	6398                	ld	a4,0(a5)
 7e0:	00e6e463          	bltu	a3,a4,7e8 <free+0x4a>
    if(p >= p->s.ptr && (bp > p || bp < p->s.ptr))
 7e4:	fee7eae3          	bltu	a5,a4,7d8 <free+0x3a>
  if(bp + bp->s.size == p->s.ptr){
 7e8:	ff852583          	lw	a1,-8(a0)
 7ec:	6390                	ld	a2,0(a5)
 7ee:	02059813          	slli	a6,a1,0x20
 7f2:	01c85713          	srli	a4,a6,0x1c
 7f6:	9736                	add	a4,a4,a3
 7f8:	fae60de3          	beq	a2,a4,7b2 <free+0x14>
    bp->s.ptr = p->s.ptr->s.ptr;
 7fc:	fec53823          	sd	a2,-16(a0)
  if(p + p->s.size == bp){
 800:	4790                	lw	a2,8(a5)
 802:	02061593          	slli	a1,a2,0x20
 806:	01c5d713          	srli	a4,a1,0x1c
 80a:	973e                	add	a4,a4,a5
 80c:	fae68ae3          	beq	a3,a4,7c0 <free+0x22>
    p->s.ptr = bp->s.ptr;
 810:	e394                	sd	a3,0(a5)
  } else
    p->s.ptr = bp;
  freep = p;
 812:	00000717          	auipc	a4,0x0
 816:	7ef73723          	sd	a5,2030(a4) # 1000 <freep>
}
 81a:	6422                	ld	s0,8(sp)
 81c:	0141                	addi	sp,sp,16
 81e:	8082                	ret

0000000000000820 <malloc>:
  return freep;
}

void*
malloc(uint nbytes)
{
 820:	7139                	addi	sp,sp,-64
 822:	fc06                	sd	ra,56(sp)
 824:	f822                	sd	s0,48(sp)
 826:	f426                	sd	s1,40(sp)
 828:	ec4e                	sd	s3,24(sp)
 82a:	0080                	addi	s0,sp,64
  Header *p, *prevp;
  uint nunits;

  nunits = (nbytes + sizeof(Header) - 1)/sizeof(Header) + 1;
 82c:	02051493          	slli	s1,a0,0x20
 830:	9081                	srli	s1,s1,0x20
 832:	04bd                	addi	s1,s1,15
 834:	8091                	srli	s1,s1,0x4
 836:	0014899b          	addiw	s3,s1,1
 83a:	0485                	addi	s1,s1,1
  if((prevp = freep) == 0){
 83c:	00000517          	auipc	a0,0x0
 840:	7c453503          	ld	a0,1988(a0) # 1000 <freep>
 844:	c915                	beqz	a0,878 <malloc+0x58>
    base.s.ptr = freep = prevp = &base;
    base.s.size = 0;
  }
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 846:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 848:	4798                	lw	a4,8(a5)
 84a:	08977a63          	bgeu	a4,s1,8de <malloc+0xbe>
 84e:	f04a                	sd	s2,32(sp)
 850:	e852                	sd	s4,16(sp)
 852:	e456                	sd	s5,8(sp)
 854:	e05a                	sd	s6,0(sp)
  if(nu < 4096)
 856:	8a4e                	mv	s4,s3
 858:	0009871b          	sext.w	a4,s3
 85c:	6685                	lui	a3,0x1
 85e:	00d77363          	bgeu	a4,a3,864 <malloc+0x44>
 862:	6a05                	lui	s4,0x1
 864:	000a0b1b          	sext.w	s6,s4
  p = sbrk(nu * sizeof(Header));
 868:	004a1a1b          	slliw	s4,s4,0x4
        p->s.size = nunits;
      }
      freep = prevp;
      return (void*)(p + 1);
    }
    if(p == freep)
 86c:	00000917          	auipc	s2,0x0
 870:	79490913          	addi	s2,s2,1940 # 1000 <freep>
  if(p == (char*)-1)
 874:	5afd                	li	s5,-1
 876:	a081                	j	8b6 <malloc+0x96>
 878:	f04a                	sd	s2,32(sp)
 87a:	e852                	sd	s4,16(sp)
 87c:	e456                	sd	s5,8(sp)
 87e:	e05a                	sd	s6,0(sp)
    base.s.ptr = freep = prevp = &base;
 880:	00000797          	auipc	a5,0x0
 884:	79078793          	addi	a5,a5,1936 # 1010 <base>
 888:	00000717          	auipc	a4,0x0
 88c:	76f73c23          	sd	a5,1912(a4) # 1000 <freep>
 890:	e39c                	sd	a5,0(a5)
    base.s.size = 0;
 892:	0007a423          	sw	zero,8(a5)
    if(p->s.size >= nunits){
 896:	b7c1                	j	856 <malloc+0x36>
        prevp->s.ptr = p->s.ptr;
 898:	6398                	ld	a4,0(a5)
 89a:	e118                	sd	a4,0(a0)
 89c:	a8a9                	j	8f6 <malloc+0xd6>
  hp->s.size = nu;
 89e:	01652423          	sw	s6,8(a0)
  free((void*)(hp + 1));
 8a2:	0541                	addi	a0,a0,16
 8a4:	efbff0ef          	jal	79e <free>
  return freep;
 8a8:	00093503          	ld	a0,0(s2)
      if((p = morecore(nunits)) == 0)
 8ac:	c12d                	beqz	a0,90e <malloc+0xee>
  for(p = prevp->s.ptr; ; prevp = p, p = p->s.ptr){
 8ae:	611c                	ld	a5,0(a0)
    if(p->s.size >= nunits){
 8b0:	4798                	lw	a4,8(a5)
 8b2:	02977263          	bgeu	a4,s1,8d6 <malloc+0xb6>
    if(p == freep)
 8b6:	00093703          	ld	a4,0(s2)
 8ba:	853e                	mv	a0,a5
 8bc:	fef719e3          	bne	a4,a5,8ae <malloc+0x8e>
  p = sbrk(nu * sizeof(Header));
 8c0:	8552                	mv	a0,s4
 8c2:	b13ff0ef          	jal	3d4 <sbrk>
  if(p == (char*)-1)
 8c6:	fd551ce3          	bne	a0,s5,89e <malloc+0x7e>
        return 0;
 8ca:	4501                	li	a0,0
 8cc:	7902                	ld	s2,32(sp)
 8ce:	6a42                	ld	s4,16(sp)
 8d0:	6aa2                	ld	s5,8(sp)
 8d2:	6b02                	ld	s6,0(sp)
 8d4:	a03d                	j	902 <malloc+0xe2>
 8d6:	7902                	ld	s2,32(sp)
 8d8:	6a42                	ld	s4,16(sp)
 8da:	6aa2                	ld	s5,8(sp)
 8dc:	6b02                	ld	s6,0(sp)
      if(p->s.size == nunits)
 8de:	fae48de3          	beq	s1,a4,898 <malloc+0x78>
        p->s.size -= nunits;
 8e2:	4137073b          	subw	a4,a4,s3
 8e6:	c798                	sw	a4,8(a5)
        p += p->s.size;
 8e8:	02071693          	slli	a3,a4,0x20
 8ec:	01c6d713          	srli	a4,a3,0x1c
 8f0:	97ba                	add	a5,a5,a4
        p->s.size = nunits;
 8f2:	0137a423          	sw	s3,8(a5)
      freep = prevp;
 8f6:	00000717          	auipc	a4,0x0
 8fa:	70a73523          	sd	a0,1802(a4) # 1000 <freep>
      return (void*)(p + 1);
 8fe:	01078513          	addi	a0,a5,16
  }
}
 902:	70e2                	ld	ra,56(sp)
 904:	7442                	ld	s0,48(sp)
 906:	74a2                	ld	s1,40(sp)
 908:	69e2                	ld	s3,24(sp)
 90a:	6121                	addi	sp,sp,64
 90c:	8082                	ret
 90e:	7902                	ld	s2,32(sp)
 910:	6a42                	ld	s4,16(sp)
 912:	6aa2                	ld	s5,8(sp)
 914:	6b02                	ld	s6,0(sp)
 916:	b7f5                	j	902 <malloc+0xe2>
