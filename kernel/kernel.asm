
kernel/kernel: formato do arquivo elf64-littleriscv


Desmontagem da seção .text:

0000000080000000 <_entry>:
    80000000:	0000a117          	auipc	sp,0xa
    80000004:	22013103          	ld	sp,544(sp) # 8000a220 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	04a000ef          	jal	80000060 <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
}

// ask each hart to generate timer interrupts.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
#define MIE_STIE (1L << 5)  // supervisor timer
static inline uint64
r_mie()
{
  uint64 x;
  asm volatile("csrr %0, mie" : "=r" (x) );
    80000022:	304027f3          	csrr	a5,mie
  // enable supervisor-mode timer interrupts.
  w_mie(r_mie() | MIE_STIE);
    80000026:	0207e793          	ori	a5,a5,32
}

static inline void 
w_mie(uint64 x)
{
  asm volatile("csrw mie, %0" : : "r" (x));
    8000002a:	30479073          	csrw	mie,a5
static inline uint64
r_menvcfg()
{
  uint64 x;
  // asm volatile("csrr %0, menvcfg" : "=r" (x) );
  asm volatile("csrr %0, 0x30a" : "=r" (x) );
    8000002e:	30a027f3          	csrr	a5,0x30a
  
  // enable the sstc extension (i.e. stimecmp).
  w_menvcfg(r_menvcfg() | (1L << 63)); 
    80000032:	577d                	li	a4,-1
    80000034:	177e                	slli	a4,a4,0x3f
    80000036:	8fd9                	or	a5,a5,a4

static inline void 
w_menvcfg(uint64 x)
{
  // asm volatile("csrw menvcfg, %0" : : "r" (x));
  asm volatile("csrw 0x30a, %0" : : "r" (x));
    80000038:	30a79073          	csrw	0x30a,a5

static inline uint64
r_mcounteren()
{
  uint64 x;
  asm volatile("csrr %0, mcounteren" : "=r" (x) );
    8000003c:	306027f3          	csrr	a5,mcounteren
  
  // allow supervisor to use stimecmp and time.
  w_mcounteren(r_mcounteren() | 2);
    80000040:	0027e793          	ori	a5,a5,2
  asm volatile("csrw mcounteren, %0" : : "r" (x));
    80000044:	30679073          	csrw	mcounteren,a5
// machine-mode cycle counter
static inline uint64
r_time()
{
  uint64 x;
  asm volatile("csrr %0, time" : "=r" (x) );
    80000048:	c01027f3          	rdtime	a5
  
  // ask for the very first timer interrupt.
  w_stimecmp(r_time() + 1000000);
    8000004c:	000f4737          	lui	a4,0xf4
    80000050:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80000054:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80000056:	14d79073          	csrw	stimecmp,a5
}
    8000005a:	6422                	ld	s0,8(sp)
    8000005c:	0141                	addi	sp,sp,16
    8000005e:	8082                	ret

0000000080000060 <start>:
{
    80000060:	1141                	addi	sp,sp,-16
    80000062:	e406                	sd	ra,8(sp)
    80000064:	e022                	sd	s0,0(sp)
    80000066:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000068:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    8000006c:	7779                	lui	a4,0xffffe
    8000006e:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdac4f>
    80000072:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    80000074:	6705                	lui	a4,0x1
    80000076:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    8000007a:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    8000007c:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    80000080:	00001797          	auipc	a5,0x1
    80000084:	de278793          	addi	a5,a5,-542 # 80000e62 <main>
    80000088:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    8000008c:	4781                	li	a5,0
    8000008e:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    80000092:	67c1                	lui	a5,0x10
    80000094:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    80000096:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    8000009a:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    8000009e:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000a2:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000a6:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000aa:	57fd                	li	a5,-1
    800000ac:	83a9                	srli	a5,a5,0xa
    800000ae:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000b2:	47bd                	li	a5,15
    800000b4:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000b8:	f65ff0ef          	jal	8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000bc:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000c0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000c2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000c4:	30200073          	mret
}
    800000c8:	60a2                	ld	ra,8(sp)
    800000ca:	6402                	ld	s0,0(sp)
    800000cc:	0141                	addi	sp,sp,16
    800000ce:	8082                	ret

00000000800000d0 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    800000d0:	715d                	addi	sp,sp,-80
    800000d2:	e486                	sd	ra,72(sp)
    800000d4:	e0a2                	sd	s0,64(sp)
    800000d6:	f84a                	sd	s2,48(sp)
    800000d8:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    800000da:	04c05263          	blez	a2,8000011e <consolewrite+0x4e>
    800000de:	fc26                	sd	s1,56(sp)
    800000e0:	f44e                	sd	s3,40(sp)
    800000e2:	f052                	sd	s4,32(sp)
    800000e4:	ec56                	sd	s5,24(sp)
    800000e6:	8a2a                	mv	s4,a0
    800000e8:	84ae                	mv	s1,a1
    800000ea:	89b2                	mv	s3,a2
    800000ec:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    800000ee:	5afd                	li	s5,-1
    800000f0:	4685                	li	a3,1
    800000f2:	8626                	mv	a2,s1
    800000f4:	85d2                	mv	a1,s4
    800000f6:	fbf40513          	addi	a0,s0,-65
    800000fa:	1d8020ef          	jal	800022d2 <either_copyin>
    800000fe:	03550263          	beq	a0,s5,80000122 <consolewrite+0x52>
      break;
    uartputc(c);
    80000102:	fbf44503          	lbu	a0,-65(s0)
    80000106:	035000ef          	jal	8000093a <uartputc>
  for(i = 0; i < n; i++){
    8000010a:	2905                	addiw	s2,s2,1
    8000010c:	0485                	addi	s1,s1,1
    8000010e:	ff2991e3          	bne	s3,s2,800000f0 <consolewrite+0x20>
    80000112:	894e                	mv	s2,s3
    80000114:	74e2                	ld	s1,56(sp)
    80000116:	79a2                	ld	s3,40(sp)
    80000118:	7a02                	ld	s4,32(sp)
    8000011a:	6ae2                	ld	s5,24(sp)
    8000011c:	a039                	j	8000012a <consolewrite+0x5a>
    8000011e:	4901                	li	s2,0
    80000120:	a029                	j	8000012a <consolewrite+0x5a>
    80000122:	74e2                	ld	s1,56(sp)
    80000124:	79a2                	ld	s3,40(sp)
    80000126:	7a02                	ld	s4,32(sp)
    80000128:	6ae2                	ld	s5,24(sp)
  }

  return i;
}
    8000012a:	854a                	mv	a0,s2
    8000012c:	60a6                	ld	ra,72(sp)
    8000012e:	6406                	ld	s0,64(sp)
    80000130:	7942                	ld	s2,48(sp)
    80000132:	6161                	addi	sp,sp,80
    80000134:	8082                	ret

0000000080000136 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000136:	711d                	addi	sp,sp,-96
    80000138:	ec86                	sd	ra,88(sp)
    8000013a:	e8a2                	sd	s0,80(sp)
    8000013c:	e4a6                	sd	s1,72(sp)
    8000013e:	e0ca                	sd	s2,64(sp)
    80000140:	fc4e                	sd	s3,56(sp)
    80000142:	f852                	sd	s4,48(sp)
    80000144:	f456                	sd	s5,40(sp)
    80000146:	f05a                	sd	s6,32(sp)
    80000148:	1080                	addi	s0,sp,96
    8000014a:	8aaa                	mv	s5,a0
    8000014c:	8a2e                	mv	s4,a1
    8000014e:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000150:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    80000154:	00012517          	auipc	a0,0x12
    80000158:	12c50513          	addi	a0,a0,300 # 80012280 <cons>
    8000015c:	299000ef          	jal	80000bf4 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    80000160:	00012497          	auipc	s1,0x12
    80000164:	12048493          	addi	s1,s1,288 # 80012280 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    80000168:	00012917          	auipc	s2,0x12
    8000016c:	1b090913          	addi	s2,s2,432 # 80012318 <cons+0x98>
  while(n > 0){
    80000170:	0b305d63          	blez	s3,8000022a <consoleread+0xf4>
    while(cons.r == cons.w){
    80000174:	0984a783          	lw	a5,152(s1)
    80000178:	09c4a703          	lw	a4,156(s1)
    8000017c:	0af71263          	bne	a4,a5,80000220 <consoleread+0xea>
      if(killed(myproc())){
    80000180:	760010ef          	jal	800018e0 <myproc>
    80000184:	7e1010ef          	jal	80002164 <killed>
    80000188:	e12d                	bnez	a0,800001ea <consoleread+0xb4>
      sleep(&cons.r, &cons.lock);
    8000018a:	85a6                	mv	a1,s1
    8000018c:	854a                	mv	a0,s2
    8000018e:	59f010ef          	jal	80001f2c <sleep>
    while(cons.r == cons.w){
    80000192:	0984a783          	lw	a5,152(s1)
    80000196:	09c4a703          	lw	a4,156(s1)
    8000019a:	fef703e3          	beq	a4,a5,80000180 <consoleread+0x4a>
    8000019e:	ec5e                	sd	s7,24(sp)
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001a0:	00012717          	auipc	a4,0x12
    800001a4:	0e070713          	addi	a4,a4,224 # 80012280 <cons>
    800001a8:	0017869b          	addiw	a3,a5,1
    800001ac:	08d72c23          	sw	a3,152(a4)
    800001b0:	07f7f693          	andi	a3,a5,127
    800001b4:	9736                	add	a4,a4,a3
    800001b6:	01874703          	lbu	a4,24(a4)
    800001ba:	00070b9b          	sext.w	s7,a4

    if(c == C('D')){  // end-of-file
    800001be:	4691                	li	a3,4
    800001c0:	04db8663          	beq	s7,a3,8000020c <consoleread+0xd6>
      }
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    800001c4:	fae407a3          	sb	a4,-81(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001c8:	4685                	li	a3,1
    800001ca:	faf40613          	addi	a2,s0,-81
    800001ce:	85d2                	mv	a1,s4
    800001d0:	8556                	mv	a0,s5
    800001d2:	0b6020ef          	jal	80002288 <either_copyout>
    800001d6:	57fd                	li	a5,-1
    800001d8:	04f50863          	beq	a0,a5,80000228 <consoleread+0xf2>
      break;

    dst++;
    800001dc:	0a05                	addi	s4,s4,1
    --n;
    800001de:	39fd                	addiw	s3,s3,-1

    if(c == '\n'){
    800001e0:	47a9                	li	a5,10
    800001e2:	04fb8d63          	beq	s7,a5,8000023c <consoleread+0x106>
    800001e6:	6be2                	ld	s7,24(sp)
    800001e8:	b761                	j	80000170 <consoleread+0x3a>
        release(&cons.lock);
    800001ea:	00012517          	auipc	a0,0x12
    800001ee:	09650513          	addi	a0,a0,150 # 80012280 <cons>
    800001f2:	29b000ef          	jal	80000c8c <release>
        return -1;
    800001f6:	557d                	li	a0,-1
    }
  }
  release(&cons.lock);

  return target - n;
}
    800001f8:	60e6                	ld	ra,88(sp)
    800001fa:	6446                	ld	s0,80(sp)
    800001fc:	64a6                	ld	s1,72(sp)
    800001fe:	6906                	ld	s2,64(sp)
    80000200:	79e2                	ld	s3,56(sp)
    80000202:	7a42                	ld	s4,48(sp)
    80000204:	7aa2                	ld	s5,40(sp)
    80000206:	7b02                	ld	s6,32(sp)
    80000208:	6125                	addi	sp,sp,96
    8000020a:	8082                	ret
      if(n < target){
    8000020c:	0009871b          	sext.w	a4,s3
    80000210:	01677a63          	bgeu	a4,s6,80000224 <consoleread+0xee>
        cons.r--;
    80000214:	00012717          	auipc	a4,0x12
    80000218:	10f72223          	sw	a5,260(a4) # 80012318 <cons+0x98>
    8000021c:	6be2                	ld	s7,24(sp)
    8000021e:	a031                	j	8000022a <consoleread+0xf4>
    80000220:	ec5e                	sd	s7,24(sp)
    80000222:	bfbd                	j	800001a0 <consoleread+0x6a>
    80000224:	6be2                	ld	s7,24(sp)
    80000226:	a011                	j	8000022a <consoleread+0xf4>
    80000228:	6be2                	ld	s7,24(sp)
  release(&cons.lock);
    8000022a:	00012517          	auipc	a0,0x12
    8000022e:	05650513          	addi	a0,a0,86 # 80012280 <cons>
    80000232:	25b000ef          	jal	80000c8c <release>
  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	bf7d                	j	800001f8 <consoleread+0xc2>
    8000023c:	6be2                	ld	s7,24(sp)
    8000023e:	b7f5                	j	8000022a <consoleread+0xf4>

0000000080000240 <consputc>:
{
    80000240:	1141                	addi	sp,sp,-16
    80000242:	e406                	sd	ra,8(sp)
    80000244:	e022                	sd	s0,0(sp)
    80000246:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000248:	10000793          	li	a5,256
    8000024c:	00f50863          	beq	a0,a5,8000025c <consputc+0x1c>
    uartputc_sync(c);
    80000250:	604000ef          	jal	80000854 <uartputc_sync>
}
    80000254:	60a2                	ld	ra,8(sp)
    80000256:	6402                	ld	s0,0(sp)
    80000258:	0141                	addi	sp,sp,16
    8000025a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000025c:	4521                	li	a0,8
    8000025e:	5f6000ef          	jal	80000854 <uartputc_sync>
    80000262:	02000513          	li	a0,32
    80000266:	5ee000ef          	jal	80000854 <uartputc_sync>
    8000026a:	4521                	li	a0,8
    8000026c:	5e8000ef          	jal	80000854 <uartputc_sync>
    80000270:	b7d5                	j	80000254 <consputc+0x14>

0000000080000272 <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    80000272:	1101                	addi	sp,sp,-32
    80000274:	ec06                	sd	ra,24(sp)
    80000276:	e822                	sd	s0,16(sp)
    80000278:	e426                	sd	s1,8(sp)
    8000027a:	1000                	addi	s0,sp,32
    8000027c:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    8000027e:	00012517          	auipc	a0,0x12
    80000282:	00250513          	addi	a0,a0,2 # 80012280 <cons>
    80000286:	16f000ef          	jal	80000bf4 <acquire>

  switch(c){
    8000028a:	47d5                	li	a5,21
    8000028c:	08f48f63          	beq	s1,a5,8000032a <consoleintr+0xb8>
    80000290:	0297c563          	blt	a5,s1,800002ba <consoleintr+0x48>
    80000294:	47a1                	li	a5,8
    80000296:	0ef48463          	beq	s1,a5,8000037e <consoleintr+0x10c>
    8000029a:	47c1                	li	a5,16
    8000029c:	10f49563          	bne	s1,a5,800003a6 <consoleintr+0x134>
  case C('P'):  // Print process list.
    procdump();
    800002a0:	07c020ef          	jal	8000231c <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002a4:	00012517          	auipc	a0,0x12
    800002a8:	fdc50513          	addi	a0,a0,-36 # 80012280 <cons>
    800002ac:	1e1000ef          	jal	80000c8c <release>
}
    800002b0:	60e2                	ld	ra,24(sp)
    800002b2:	6442                	ld	s0,16(sp)
    800002b4:	64a2                	ld	s1,8(sp)
    800002b6:	6105                	addi	sp,sp,32
    800002b8:	8082                	ret
  switch(c){
    800002ba:	07f00793          	li	a5,127
    800002be:	0cf48063          	beq	s1,a5,8000037e <consoleintr+0x10c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800002c2:	00012717          	auipc	a4,0x12
    800002c6:	fbe70713          	addi	a4,a4,-66 # 80012280 <cons>
    800002ca:	0a072783          	lw	a5,160(a4)
    800002ce:	09872703          	lw	a4,152(a4)
    800002d2:	9f99                	subw	a5,a5,a4
    800002d4:	07f00713          	li	a4,127
    800002d8:	fcf766e3          	bltu	a4,a5,800002a4 <consoleintr+0x32>
      c = (c == '\r') ? '\n' : c;
    800002dc:	47b5                	li	a5,13
    800002de:	0cf48763          	beq	s1,a5,800003ac <consoleintr+0x13a>
      consputc(c);
    800002e2:	8526                	mv	a0,s1
    800002e4:	f5dff0ef          	jal	80000240 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800002e8:	00012797          	auipc	a5,0x12
    800002ec:	f9878793          	addi	a5,a5,-104 # 80012280 <cons>
    800002f0:	0a07a683          	lw	a3,160(a5)
    800002f4:	0016871b          	addiw	a4,a3,1
    800002f8:	0007061b          	sext.w	a2,a4
    800002fc:	0ae7a023          	sw	a4,160(a5)
    80000300:	07f6f693          	andi	a3,a3,127
    80000304:	97b6                	add	a5,a5,a3
    80000306:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000030a:	47a9                	li	a5,10
    8000030c:	0cf48563          	beq	s1,a5,800003d6 <consoleintr+0x164>
    80000310:	4791                	li	a5,4
    80000312:	0cf48263          	beq	s1,a5,800003d6 <consoleintr+0x164>
    80000316:	00012797          	auipc	a5,0x12
    8000031a:	0027a783          	lw	a5,2(a5) # 80012318 <cons+0x98>
    8000031e:	9f1d                	subw	a4,a4,a5
    80000320:	08000793          	li	a5,128
    80000324:	f8f710e3          	bne	a4,a5,800002a4 <consoleintr+0x32>
    80000328:	a07d                	j	800003d6 <consoleintr+0x164>
    8000032a:	e04a                	sd	s2,0(sp)
    while(cons.e != cons.w &&
    8000032c:	00012717          	auipc	a4,0x12
    80000330:	f5470713          	addi	a4,a4,-172 # 80012280 <cons>
    80000334:	0a072783          	lw	a5,160(a4)
    80000338:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000033c:	00012497          	auipc	s1,0x12
    80000340:	f4448493          	addi	s1,s1,-188 # 80012280 <cons>
    while(cons.e != cons.w &&
    80000344:	4929                	li	s2,10
    80000346:	02f70863          	beq	a4,a5,80000376 <consoleintr+0x104>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000034a:	37fd                	addiw	a5,a5,-1
    8000034c:	07f7f713          	andi	a4,a5,127
    80000350:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    80000352:	01874703          	lbu	a4,24(a4)
    80000356:	03270263          	beq	a4,s2,8000037a <consoleintr+0x108>
      cons.e--;
    8000035a:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    8000035e:	10000513          	li	a0,256
    80000362:	edfff0ef          	jal	80000240 <consputc>
    while(cons.e != cons.w &&
    80000366:	0a04a783          	lw	a5,160(s1)
    8000036a:	09c4a703          	lw	a4,156(s1)
    8000036e:	fcf71ee3          	bne	a4,a5,8000034a <consoleintr+0xd8>
    80000372:	6902                	ld	s2,0(sp)
    80000374:	bf05                	j	800002a4 <consoleintr+0x32>
    80000376:	6902                	ld	s2,0(sp)
    80000378:	b735                	j	800002a4 <consoleintr+0x32>
    8000037a:	6902                	ld	s2,0(sp)
    8000037c:	b725                	j	800002a4 <consoleintr+0x32>
    if(cons.e != cons.w){
    8000037e:	00012717          	auipc	a4,0x12
    80000382:	f0270713          	addi	a4,a4,-254 # 80012280 <cons>
    80000386:	0a072783          	lw	a5,160(a4)
    8000038a:	09c72703          	lw	a4,156(a4)
    8000038e:	f0f70be3          	beq	a4,a5,800002a4 <consoleintr+0x32>
      cons.e--;
    80000392:	37fd                	addiw	a5,a5,-1
    80000394:	00012717          	auipc	a4,0x12
    80000398:	f8f72623          	sw	a5,-116(a4) # 80012320 <cons+0xa0>
      consputc(BACKSPACE);
    8000039c:	10000513          	li	a0,256
    800003a0:	ea1ff0ef          	jal	80000240 <consputc>
    800003a4:	b701                	j	800002a4 <consoleintr+0x32>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    800003a6:	ee048fe3          	beqz	s1,800002a4 <consoleintr+0x32>
    800003aa:	bf21                	j	800002c2 <consoleintr+0x50>
      consputc(c);
    800003ac:	4529                	li	a0,10
    800003ae:	e93ff0ef          	jal	80000240 <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    800003b2:	00012797          	auipc	a5,0x12
    800003b6:	ece78793          	addi	a5,a5,-306 # 80012280 <cons>
    800003ba:	0a07a703          	lw	a4,160(a5)
    800003be:	0017069b          	addiw	a3,a4,1
    800003c2:	0006861b          	sext.w	a2,a3
    800003c6:	0ad7a023          	sw	a3,160(a5)
    800003ca:	07f77713          	andi	a4,a4,127
    800003ce:	97ba                	add	a5,a5,a4
    800003d0:	4729                	li	a4,10
    800003d2:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    800003d6:	00012797          	auipc	a5,0x12
    800003da:	f4c7a323          	sw	a2,-186(a5) # 8001231c <cons+0x9c>
        wakeup(&cons.r);
    800003de:	00012517          	auipc	a0,0x12
    800003e2:	f3a50513          	addi	a0,a0,-198 # 80012318 <cons+0x98>
    800003e6:	393010ef          	jal	80001f78 <wakeup>
    800003ea:	bd6d                	j	800002a4 <consoleintr+0x32>

00000000800003ec <consoleinit>:

void
consoleinit(void)
{
    800003ec:	1141                	addi	sp,sp,-16
    800003ee:	e406                	sd	ra,8(sp)
    800003f0:	e022                	sd	s0,0(sp)
    800003f2:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    800003f4:	00007597          	auipc	a1,0x7
    800003f8:	c0c58593          	addi	a1,a1,-1012 # 80007000 <etext>
    800003fc:	00012517          	auipc	a0,0x12
    80000400:	e8450513          	addi	a0,a0,-380 # 80012280 <cons>
    80000404:	770000ef          	jal	80000b74 <initlock>

  uartinit();
    80000408:	3f4000ef          	jal	800007fc <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    8000040c:	00022797          	auipc	a5,0x22
    80000410:	60c78793          	addi	a5,a5,1548 # 80022a18 <devsw>
    80000414:	00000717          	auipc	a4,0x0
    80000418:	d2270713          	addi	a4,a4,-734 # 80000136 <consoleread>
    8000041c:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000041e:	00000717          	auipc	a4,0x0
    80000422:	cb270713          	addi	a4,a4,-846 # 800000d0 <consolewrite>
    80000426:	ef98                	sd	a4,24(a5)
}
    80000428:	60a2                	ld	ra,8(sp)
    8000042a:	6402                	ld	s0,0(sp)
    8000042c:	0141                	addi	sp,sp,16
    8000042e:	8082                	ret

0000000080000430 <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(long long xx, int base, int sign)
{
    80000430:	7179                	addi	sp,sp,-48
    80000432:	f406                	sd	ra,40(sp)
    80000434:	f022                	sd	s0,32(sp)
    80000436:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  unsigned long long x;

  if(sign && (sign = (xx < 0)))
    80000438:	c219                	beqz	a2,8000043e <printint+0xe>
    8000043a:	08054063          	bltz	a0,800004ba <printint+0x8a>
    x = -xx;
  else
    x = xx;
    8000043e:	4881                	li	a7,0
    80000440:	fd040693          	addi	a3,s0,-48

  i = 0;
    80000444:	4781                	li	a5,0
  do {
    buf[i++] = digits[x % base];
    80000446:	00007617          	auipc	a2,0x7
    8000044a:	32a60613          	addi	a2,a2,810 # 80007770 <digits>
    8000044e:	883e                	mv	a6,a5
    80000450:	2785                	addiw	a5,a5,1
    80000452:	02b57733          	remu	a4,a0,a1
    80000456:	9732                	add	a4,a4,a2
    80000458:	00074703          	lbu	a4,0(a4)
    8000045c:	00e68023          	sb	a4,0(a3)
  } while((x /= base) != 0);
    80000460:	872a                	mv	a4,a0
    80000462:	02b55533          	divu	a0,a0,a1
    80000466:	0685                	addi	a3,a3,1
    80000468:	feb773e3          	bgeu	a4,a1,8000044e <printint+0x1e>

  if(sign)
    8000046c:	00088a63          	beqz	a7,80000480 <printint+0x50>
    buf[i++] = '-';
    80000470:	1781                	addi	a5,a5,-32
    80000472:	97a2                	add	a5,a5,s0
    80000474:	02d00713          	li	a4,45
    80000478:	fee78823          	sb	a4,-16(a5)
    8000047c:	0028079b          	addiw	a5,a6,2

  while(--i >= 0)
    80000480:	02f05963          	blez	a5,800004b2 <printint+0x82>
    80000484:	ec26                	sd	s1,24(sp)
    80000486:	e84a                	sd	s2,16(sp)
    80000488:	fd040713          	addi	a4,s0,-48
    8000048c:	00f704b3          	add	s1,a4,a5
    80000490:	fff70913          	addi	s2,a4,-1
    80000494:	993e                	add	s2,s2,a5
    80000496:	37fd                	addiw	a5,a5,-1
    80000498:	1782                	slli	a5,a5,0x20
    8000049a:	9381                	srli	a5,a5,0x20
    8000049c:	40f90933          	sub	s2,s2,a5
    consputc(buf[i]);
    800004a0:	fff4c503          	lbu	a0,-1(s1)
    800004a4:	d9dff0ef          	jal	80000240 <consputc>
  while(--i >= 0)
    800004a8:	14fd                	addi	s1,s1,-1
    800004aa:	ff249be3          	bne	s1,s2,800004a0 <printint+0x70>
    800004ae:	64e2                	ld	s1,24(sp)
    800004b0:	6942                	ld	s2,16(sp)
}
    800004b2:	70a2                	ld	ra,40(sp)
    800004b4:	7402                	ld	s0,32(sp)
    800004b6:	6145                	addi	sp,sp,48
    800004b8:	8082                	ret
    x = -xx;
    800004ba:	40a00533          	neg	a0,a0
  if(sign && (sign = (xx < 0)))
    800004be:	4885                	li	a7,1
    x = -xx;
    800004c0:	b741                	j	80000440 <printint+0x10>

00000000800004c2 <printf>:
}

// Print to the console.
int
printf(char *fmt, ...)
{
    800004c2:	7155                	addi	sp,sp,-208
    800004c4:	e506                	sd	ra,136(sp)
    800004c6:	e122                	sd	s0,128(sp)
    800004c8:	f0d2                	sd	s4,96(sp)
    800004ca:	0900                	addi	s0,sp,144
    800004cc:	8a2a                	mv	s4,a0
    800004ce:	e40c                	sd	a1,8(s0)
    800004d0:	e810                	sd	a2,16(s0)
    800004d2:	ec14                	sd	a3,24(s0)
    800004d4:	f018                	sd	a4,32(s0)
    800004d6:	f41c                	sd	a5,40(s0)
    800004d8:	03043823          	sd	a6,48(s0)
    800004dc:	03143c23          	sd	a7,56(s0)
  va_list ap;
  int i, cx, c0, c1, c2, locking;
  char *s;

  locking = pr.locking;
    800004e0:	00012797          	auipc	a5,0x12
    800004e4:	e607a783          	lw	a5,-416(a5) # 80012340 <pr+0x18>
    800004e8:	f6f43c23          	sd	a5,-136(s0)
  if(locking)
    800004ec:	e3a1                	bnez	a5,8000052c <printf+0x6a>
    acquire(&pr.lock);

  va_start(ap, fmt);
    800004ee:	00840793          	addi	a5,s0,8
    800004f2:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    800004f6:	00054503          	lbu	a0,0(a0)
    800004fa:	26050763          	beqz	a0,80000768 <printf+0x2a6>
    800004fe:	fca6                	sd	s1,120(sp)
    80000500:	f8ca                	sd	s2,112(sp)
    80000502:	f4ce                	sd	s3,104(sp)
    80000504:	ecd6                	sd	s5,88(sp)
    80000506:	e8da                	sd	s6,80(sp)
    80000508:	e0e2                	sd	s8,64(sp)
    8000050a:	fc66                	sd	s9,56(sp)
    8000050c:	f86a                	sd	s10,48(sp)
    8000050e:	f46e                	sd	s11,40(sp)
    80000510:	4981                	li	s3,0
    if(cx != '%'){
    80000512:	02500a93          	li	s5,37
    i++;
    c0 = fmt[i+0] & 0xff;
    c1 = c2 = 0;
    if(c0) c1 = fmt[i+1] & 0xff;
    if(c1) c2 = fmt[i+2] & 0xff;
    if(c0 == 'd'){
    80000516:	06400b13          	li	s6,100
      printint(va_arg(ap, int), 10, 1);
    } else if(c0 == 'l' && c1 == 'd'){
    8000051a:	06c00c13          	li	s8,108
      printint(va_arg(ap, uint64), 10, 1);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
      printint(va_arg(ap, uint64), 10, 1);
      i += 2;
    } else if(c0 == 'u'){
    8000051e:	07500c93          	li	s9,117
      printint(va_arg(ap, uint64), 10, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
      printint(va_arg(ap, uint64), 10, 0);
      i += 2;
    } else if(c0 == 'x'){
    80000522:	07800d13          	li	s10,120
      printint(va_arg(ap, uint64), 16, 0);
      i += 1;
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
      printint(va_arg(ap, uint64), 16, 0);
      i += 2;
    } else if(c0 == 'p'){
    80000526:	07000d93          	li	s11,112
    8000052a:	a815                	j	8000055e <printf+0x9c>
    acquire(&pr.lock);
    8000052c:	00012517          	auipc	a0,0x12
    80000530:	dfc50513          	addi	a0,a0,-516 # 80012328 <pr>
    80000534:	6c0000ef          	jal	80000bf4 <acquire>
  va_start(ap, fmt);
    80000538:	00840793          	addi	a5,s0,8
    8000053c:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    80000540:	000a4503          	lbu	a0,0(s4)
    80000544:	fd4d                	bnez	a0,800004fe <printf+0x3c>
    80000546:	a481                	j	80000786 <printf+0x2c4>
      consputc(cx);
    80000548:	cf9ff0ef          	jal	80000240 <consputc>
      continue;
    8000054c:	84ce                	mv	s1,s3
  for(i = 0; (cx = fmt[i] & 0xff) != 0; i++){
    8000054e:	0014899b          	addiw	s3,s1,1
    80000552:	013a07b3          	add	a5,s4,s3
    80000556:	0007c503          	lbu	a0,0(a5)
    8000055a:	1e050b63          	beqz	a0,80000750 <printf+0x28e>
    if(cx != '%'){
    8000055e:	ff5515e3          	bne	a0,s5,80000548 <printf+0x86>
    i++;
    80000562:	0019849b          	addiw	s1,s3,1
    c0 = fmt[i+0] & 0xff;
    80000566:	009a07b3          	add	a5,s4,s1
    8000056a:	0007c903          	lbu	s2,0(a5)
    if(c0) c1 = fmt[i+1] & 0xff;
    8000056e:	1e090163          	beqz	s2,80000750 <printf+0x28e>
    80000572:	0017c783          	lbu	a5,1(a5)
    c1 = c2 = 0;
    80000576:	86be                	mv	a3,a5
    if(c1) c2 = fmt[i+2] & 0xff;
    80000578:	c789                	beqz	a5,80000582 <printf+0xc0>
    8000057a:	009a0733          	add	a4,s4,s1
    8000057e:	00274683          	lbu	a3,2(a4)
    if(c0 == 'd'){
    80000582:	03690763          	beq	s2,s6,800005b0 <printf+0xee>
    } else if(c0 == 'l' && c1 == 'd'){
    80000586:	05890163          	beq	s2,s8,800005c8 <printf+0x106>
    } else if(c0 == 'u'){
    8000058a:	0d990b63          	beq	s2,s9,80000660 <printf+0x19e>
    } else if(c0 == 'x'){
    8000058e:	13a90163          	beq	s2,s10,800006b0 <printf+0x1ee>
    } else if(c0 == 'p'){
    80000592:	13b90b63          	beq	s2,s11,800006c8 <printf+0x206>
      printptr(va_arg(ap, uint64));
    } else if(c0 == 's'){
    80000596:	07300793          	li	a5,115
    8000059a:	16f90a63          	beq	s2,a5,8000070e <printf+0x24c>
      if((s = va_arg(ap, char*)) == 0)
        s = "(null)";
      for(; *s; s++)
        consputc(*s);
    } else if(c0 == '%'){
    8000059e:	1b590463          	beq	s2,s5,80000746 <printf+0x284>
      consputc('%');
    } else if(c0 == 0){
      break;
    } else {
      // Print unknown % sequence to draw attention.
      consputc('%');
    800005a2:	8556                	mv	a0,s5
    800005a4:	c9dff0ef          	jal	80000240 <consputc>
      consputc(c0);
    800005a8:	854a                	mv	a0,s2
    800005aa:	c97ff0ef          	jal	80000240 <consputc>
    800005ae:	b745                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 10, 1);
    800005b0:	f8843783          	ld	a5,-120(s0)
    800005b4:	00878713          	addi	a4,a5,8
    800005b8:	f8e43423          	sd	a4,-120(s0)
    800005bc:	4605                	li	a2,1
    800005be:	45a9                	li	a1,10
    800005c0:	4388                	lw	a0,0(a5)
    800005c2:	e6fff0ef          	jal	80000430 <printint>
    800005c6:	b761                	j	8000054e <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'd'){
    800005c8:	03678663          	beq	a5,s6,800005f4 <printf+0x132>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    800005cc:	05878263          	beq	a5,s8,80000610 <printf+0x14e>
    } else if(c0 == 'l' && c1 == 'u'){
    800005d0:	0b978463          	beq	a5,s9,80000678 <printf+0x1b6>
    } else if(c0 == 'l' && c1 == 'x'){
    800005d4:	fda797e3          	bne	a5,s10,800005a2 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    800005d8:	f8843783          	ld	a5,-120(s0)
    800005dc:	00878713          	addi	a4,a5,8
    800005e0:	f8e43423          	sd	a4,-120(s0)
    800005e4:	4601                	li	a2,0
    800005e6:	45c1                	li	a1,16
    800005e8:	6388                	ld	a0,0(a5)
    800005ea:	e47ff0ef          	jal	80000430 <printint>
      i += 1;
    800005ee:	0029849b          	addiw	s1,s3,2
    800005f2:	bfb1                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    800005f4:	f8843783          	ld	a5,-120(s0)
    800005f8:	00878713          	addi	a4,a5,8
    800005fc:	f8e43423          	sd	a4,-120(s0)
    80000600:	4605                	li	a2,1
    80000602:	45a9                	li	a1,10
    80000604:	6388                	ld	a0,0(a5)
    80000606:	e2bff0ef          	jal	80000430 <printint>
      i += 1;
    8000060a:	0029849b          	addiw	s1,s3,2
    8000060e:	b781                	j	8000054e <printf+0x8c>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'd'){
    80000610:	06400793          	li	a5,100
    80000614:	02f68863          	beq	a3,a5,80000644 <printf+0x182>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'u'){
    80000618:	07500793          	li	a5,117
    8000061c:	06f68c63          	beq	a3,a5,80000694 <printf+0x1d2>
    } else if(c0 == 'l' && c1 == 'l' && c2 == 'x'){
    80000620:	07800793          	li	a5,120
    80000624:	f6f69fe3          	bne	a3,a5,800005a2 <printf+0xe0>
      printint(va_arg(ap, uint64), 16, 0);
    80000628:	f8843783          	ld	a5,-120(s0)
    8000062c:	00878713          	addi	a4,a5,8
    80000630:	f8e43423          	sd	a4,-120(s0)
    80000634:	4601                	li	a2,0
    80000636:	45c1                	li	a1,16
    80000638:	6388                	ld	a0,0(a5)
    8000063a:	df7ff0ef          	jal	80000430 <printint>
      i += 2;
    8000063e:	0039849b          	addiw	s1,s3,3
    80000642:	b731                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 1);
    80000644:	f8843783          	ld	a5,-120(s0)
    80000648:	00878713          	addi	a4,a5,8
    8000064c:	f8e43423          	sd	a4,-120(s0)
    80000650:	4605                	li	a2,1
    80000652:	45a9                	li	a1,10
    80000654:	6388                	ld	a0,0(a5)
    80000656:	ddbff0ef          	jal	80000430 <printint>
      i += 2;
    8000065a:	0039849b          	addiw	s1,s3,3
    8000065e:	bdc5                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 10, 0);
    80000660:	f8843783          	ld	a5,-120(s0)
    80000664:	00878713          	addi	a4,a5,8
    80000668:	f8e43423          	sd	a4,-120(s0)
    8000066c:	4601                	li	a2,0
    8000066e:	45a9                	li	a1,10
    80000670:	4388                	lw	a0,0(a5)
    80000672:	dbfff0ef          	jal	80000430 <printint>
    80000676:	bde1                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80000678:	f8843783          	ld	a5,-120(s0)
    8000067c:	00878713          	addi	a4,a5,8
    80000680:	f8e43423          	sd	a4,-120(s0)
    80000684:	4601                	li	a2,0
    80000686:	45a9                	li	a1,10
    80000688:	6388                	ld	a0,0(a5)
    8000068a:	da7ff0ef          	jal	80000430 <printint>
      i += 1;
    8000068e:	0029849b          	addiw	s1,s3,2
    80000692:	bd75                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, uint64), 10, 0);
    80000694:	f8843783          	ld	a5,-120(s0)
    80000698:	00878713          	addi	a4,a5,8
    8000069c:	f8e43423          	sd	a4,-120(s0)
    800006a0:	4601                	li	a2,0
    800006a2:	45a9                	li	a1,10
    800006a4:	6388                	ld	a0,0(a5)
    800006a6:	d8bff0ef          	jal	80000430 <printint>
      i += 2;
    800006aa:	0039849b          	addiw	s1,s3,3
    800006ae:	b545                	j	8000054e <printf+0x8c>
      printint(va_arg(ap, int), 16, 0);
    800006b0:	f8843783          	ld	a5,-120(s0)
    800006b4:	00878713          	addi	a4,a5,8
    800006b8:	f8e43423          	sd	a4,-120(s0)
    800006bc:	4601                	li	a2,0
    800006be:	45c1                	li	a1,16
    800006c0:	4388                	lw	a0,0(a5)
    800006c2:	d6fff0ef          	jal	80000430 <printint>
    800006c6:	b561                	j	8000054e <printf+0x8c>
    800006c8:	e4de                	sd	s7,72(sp)
      printptr(va_arg(ap, uint64));
    800006ca:	f8843783          	ld	a5,-120(s0)
    800006ce:	00878713          	addi	a4,a5,8
    800006d2:	f8e43423          	sd	a4,-120(s0)
    800006d6:	0007b983          	ld	s3,0(a5)
  consputc('0');
    800006da:	03000513          	li	a0,48
    800006de:	b63ff0ef          	jal	80000240 <consputc>
  consputc('x');
    800006e2:	07800513          	li	a0,120
    800006e6:	b5bff0ef          	jal	80000240 <consputc>
    800006ea:	4941                	li	s2,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006ec:	00007b97          	auipc	s7,0x7
    800006f0:	084b8b93          	addi	s7,s7,132 # 80007770 <digits>
    800006f4:	03c9d793          	srli	a5,s3,0x3c
    800006f8:	97de                	add	a5,a5,s7
    800006fa:	0007c503          	lbu	a0,0(a5)
    800006fe:	b43ff0ef          	jal	80000240 <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    80000702:	0992                	slli	s3,s3,0x4
    80000704:	397d                	addiw	s2,s2,-1
    80000706:	fe0917e3          	bnez	s2,800006f4 <printf+0x232>
    8000070a:	6ba6                	ld	s7,72(sp)
    8000070c:	b589                	j	8000054e <printf+0x8c>
      if((s = va_arg(ap, char*)) == 0)
    8000070e:	f8843783          	ld	a5,-120(s0)
    80000712:	00878713          	addi	a4,a5,8
    80000716:	f8e43423          	sd	a4,-120(s0)
    8000071a:	0007b903          	ld	s2,0(a5)
    8000071e:	00090d63          	beqz	s2,80000738 <printf+0x276>
      for(; *s; s++)
    80000722:	00094503          	lbu	a0,0(s2)
    80000726:	e20504e3          	beqz	a0,8000054e <printf+0x8c>
        consputc(*s);
    8000072a:	b17ff0ef          	jal	80000240 <consputc>
      for(; *s; s++)
    8000072e:	0905                	addi	s2,s2,1
    80000730:	00094503          	lbu	a0,0(s2)
    80000734:	f97d                	bnez	a0,8000072a <printf+0x268>
    80000736:	bd21                	j	8000054e <printf+0x8c>
        s = "(null)";
    80000738:	00007917          	auipc	s2,0x7
    8000073c:	8d090913          	addi	s2,s2,-1840 # 80007008 <etext+0x8>
      for(; *s; s++)
    80000740:	02800513          	li	a0,40
    80000744:	b7dd                	j	8000072a <printf+0x268>
      consputc('%');
    80000746:	02500513          	li	a0,37
    8000074a:	af7ff0ef          	jal	80000240 <consputc>
    8000074e:	b501                	j	8000054e <printf+0x8c>
    }
#endif
  }
  va_end(ap);

  if(locking)
    80000750:	f7843783          	ld	a5,-136(s0)
    80000754:	e385                	bnez	a5,80000774 <printf+0x2b2>
    80000756:	74e6                	ld	s1,120(sp)
    80000758:	7946                	ld	s2,112(sp)
    8000075a:	79a6                	ld	s3,104(sp)
    8000075c:	6ae6                	ld	s5,88(sp)
    8000075e:	6b46                	ld	s6,80(sp)
    80000760:	6c06                	ld	s8,64(sp)
    80000762:	7ce2                	ld	s9,56(sp)
    80000764:	7d42                	ld	s10,48(sp)
    80000766:	7da2                	ld	s11,40(sp)
    release(&pr.lock);

  return 0;
}
    80000768:	4501                	li	a0,0
    8000076a:	60aa                	ld	ra,136(sp)
    8000076c:	640a                	ld	s0,128(sp)
    8000076e:	7a06                	ld	s4,96(sp)
    80000770:	6169                	addi	sp,sp,208
    80000772:	8082                	ret
    80000774:	74e6                	ld	s1,120(sp)
    80000776:	7946                	ld	s2,112(sp)
    80000778:	79a6                	ld	s3,104(sp)
    8000077a:	6ae6                	ld	s5,88(sp)
    8000077c:	6b46                	ld	s6,80(sp)
    8000077e:	6c06                	ld	s8,64(sp)
    80000780:	7ce2                	ld	s9,56(sp)
    80000782:	7d42                	ld	s10,48(sp)
    80000784:	7da2                	ld	s11,40(sp)
    release(&pr.lock);
    80000786:	00012517          	auipc	a0,0x12
    8000078a:	ba250513          	addi	a0,a0,-1118 # 80012328 <pr>
    8000078e:	4fe000ef          	jal	80000c8c <release>
    80000792:	bfd9                	j	80000768 <printf+0x2a6>

0000000080000794 <panic>:

void
panic(char *s)
{
    80000794:	1101                	addi	sp,sp,-32
    80000796:	ec06                	sd	ra,24(sp)
    80000798:	e822                	sd	s0,16(sp)
    8000079a:	e426                	sd	s1,8(sp)
    8000079c:	1000                	addi	s0,sp,32
    8000079e:	84aa                	mv	s1,a0
  pr.locking = 0;
    800007a0:	00012797          	auipc	a5,0x12
    800007a4:	ba07a023          	sw	zero,-1120(a5) # 80012340 <pr+0x18>
  printf("panic: ");
    800007a8:	00007517          	auipc	a0,0x7
    800007ac:	87050513          	addi	a0,a0,-1936 # 80007018 <etext+0x18>
    800007b0:	d13ff0ef          	jal	800004c2 <printf>
  printf("%s\n", s);
    800007b4:	85a6                	mv	a1,s1
    800007b6:	00007517          	auipc	a0,0x7
    800007ba:	86a50513          	addi	a0,a0,-1942 # 80007020 <etext+0x20>
    800007be:	d05ff0ef          	jal	800004c2 <printf>
  panicked = 1; // freeze uart output from other CPUs
    800007c2:	4785                	li	a5,1
    800007c4:	0000a717          	auipc	a4,0xa
    800007c8:	a6f72e23          	sw	a5,-1412(a4) # 8000a240 <panicked>
  for(;;)
    800007cc:	a001                	j	800007cc <panic+0x38>

00000000800007ce <printfinit>:
    ;
}

void
printfinit(void)
{
    800007ce:	1101                	addi	sp,sp,-32
    800007d0:	ec06                	sd	ra,24(sp)
    800007d2:	e822                	sd	s0,16(sp)
    800007d4:	e426                	sd	s1,8(sp)
    800007d6:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    800007d8:	00012497          	auipc	s1,0x12
    800007dc:	b5048493          	addi	s1,s1,-1200 # 80012328 <pr>
    800007e0:	00007597          	auipc	a1,0x7
    800007e4:	84858593          	addi	a1,a1,-1976 # 80007028 <etext+0x28>
    800007e8:	8526                	mv	a0,s1
    800007ea:	38a000ef          	jal	80000b74 <initlock>
  pr.locking = 1;
    800007ee:	4785                	li	a5,1
    800007f0:	cc9c                	sw	a5,24(s1)
}
    800007f2:	60e2                	ld	ra,24(sp)
    800007f4:	6442                	ld	s0,16(sp)
    800007f6:	64a2                	ld	s1,8(sp)
    800007f8:	6105                	addi	sp,sp,32
    800007fa:	8082                	ret

00000000800007fc <uartinit>:

void uartstart();

void
uartinit(void)
{
    800007fc:	1141                	addi	sp,sp,-16
    800007fe:	e406                	sd	ra,8(sp)
    80000800:	e022                	sd	s0,0(sp)
    80000802:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    80000804:	100007b7          	lui	a5,0x10000
    80000808:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    8000080c:	10000737          	lui	a4,0x10000
    80000810:	f8000693          	li	a3,-128
    80000814:	00d701a3          	sb	a3,3(a4) # 10000003 <_entry-0x6ffffffd>

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    80000818:	468d                	li	a3,3
    8000081a:	10000637          	lui	a2,0x10000
    8000081e:	00d60023          	sb	a3,0(a2) # 10000000 <_entry-0x70000000>

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    80000822:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    80000826:	00d701a3          	sb	a3,3(a4)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    8000082a:	10000737          	lui	a4,0x10000
    8000082e:	461d                	li	a2,7
    80000830:	00c70123          	sb	a2,2(a4) # 10000002 <_entry-0x6ffffffe>

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    80000834:	00d780a3          	sb	a3,1(a5)

  initlock(&uart_tx_lock, "uart");
    80000838:	00006597          	auipc	a1,0x6
    8000083c:	7f858593          	addi	a1,a1,2040 # 80007030 <etext+0x30>
    80000840:	00012517          	auipc	a0,0x12
    80000844:	b0850513          	addi	a0,a0,-1272 # 80012348 <uart_tx_lock>
    80000848:	32c000ef          	jal	80000b74 <initlock>
}
    8000084c:	60a2                	ld	ra,8(sp)
    8000084e:	6402                	ld	s0,0(sp)
    80000850:	0141                	addi	sp,sp,16
    80000852:	8082                	ret

0000000080000854 <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    80000854:	1101                	addi	sp,sp,-32
    80000856:	ec06                	sd	ra,24(sp)
    80000858:	e822                	sd	s0,16(sp)
    8000085a:	e426                	sd	s1,8(sp)
    8000085c:	1000                	addi	s0,sp,32
    8000085e:	84aa                	mv	s1,a0
  push_off();
    80000860:	354000ef          	jal	80000bb4 <push_off>

  if(panicked){
    80000864:	0000a797          	auipc	a5,0xa
    80000868:	9dc7a783          	lw	a5,-1572(a5) # 8000a240 <panicked>
    8000086c:	e795                	bnez	a5,80000898 <uartputc_sync+0x44>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    8000086e:	10000737          	lui	a4,0x10000
    80000872:	0715                	addi	a4,a4,5 # 10000005 <_entry-0x6ffffffb>
    80000874:	00074783          	lbu	a5,0(a4)
    80000878:	0207f793          	andi	a5,a5,32
    8000087c:	dfe5                	beqz	a5,80000874 <uartputc_sync+0x20>
    ;
  WriteReg(THR, c);
    8000087e:	0ff4f513          	zext.b	a0,s1
    80000882:	100007b7          	lui	a5,0x10000
    80000886:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    8000088a:	3ae000ef          	jal	80000c38 <pop_off>
}
    8000088e:	60e2                	ld	ra,24(sp)
    80000890:	6442                	ld	s0,16(sp)
    80000892:	64a2                	ld	s1,8(sp)
    80000894:	6105                	addi	sp,sp,32
    80000896:	8082                	ret
    for(;;)
    80000898:	a001                	j	80000898 <uartputc_sync+0x44>

000000008000089a <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    8000089a:	0000a797          	auipc	a5,0xa
    8000089e:	9ae7b783          	ld	a5,-1618(a5) # 8000a248 <uart_tx_r>
    800008a2:	0000a717          	auipc	a4,0xa
    800008a6:	9ae73703          	ld	a4,-1618(a4) # 8000a250 <uart_tx_w>
    800008aa:	08f70263          	beq	a4,a5,8000092e <uartstart+0x94>
{
    800008ae:	7139                	addi	sp,sp,-64
    800008b0:	fc06                	sd	ra,56(sp)
    800008b2:	f822                	sd	s0,48(sp)
    800008b4:	f426                	sd	s1,40(sp)
    800008b6:	f04a                	sd	s2,32(sp)
    800008b8:	ec4e                	sd	s3,24(sp)
    800008ba:	e852                	sd	s4,16(sp)
    800008bc:	e456                	sd	s5,8(sp)
    800008be:	e05a                	sd	s6,0(sp)
    800008c0:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      ReadReg(ISR);
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008c2:	10000937          	lui	s2,0x10000
    800008c6:	0915                	addi	s2,s2,5 # 10000005 <_entry-0x6ffffffb>
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008c8:	00012a97          	auipc	s5,0x12
    800008cc:	a80a8a93          	addi	s5,s5,-1408 # 80012348 <uart_tx_lock>
    uart_tx_r += 1;
    800008d0:	0000a497          	auipc	s1,0xa
    800008d4:	97848493          	addi	s1,s1,-1672 # 8000a248 <uart_tx_r>
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    
    WriteReg(THR, c);
    800008d8:	10000a37          	lui	s4,0x10000
    if(uart_tx_w == uart_tx_r){
    800008dc:	0000a997          	auipc	s3,0xa
    800008e0:	97498993          	addi	s3,s3,-1676 # 8000a250 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    800008e4:	00094703          	lbu	a4,0(s2)
    800008e8:	02077713          	andi	a4,a4,32
    800008ec:	c71d                	beqz	a4,8000091a <uartstart+0x80>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    800008ee:	01f7f713          	andi	a4,a5,31
    800008f2:	9756                	add	a4,a4,s5
    800008f4:	01874b03          	lbu	s6,24(a4)
    uart_tx_r += 1;
    800008f8:	0785                	addi	a5,a5,1
    800008fa:	e09c                	sd	a5,0(s1)
    wakeup(&uart_tx_r);
    800008fc:	8526                	mv	a0,s1
    800008fe:	67a010ef          	jal	80001f78 <wakeup>
    WriteReg(THR, c);
    80000902:	016a0023          	sb	s6,0(s4) # 10000000 <_entry-0x70000000>
    if(uart_tx_w == uart_tx_r){
    80000906:	609c                	ld	a5,0(s1)
    80000908:	0009b703          	ld	a4,0(s3)
    8000090c:	fcf71ce3          	bne	a4,a5,800008e4 <uartstart+0x4a>
      ReadReg(ISR);
    80000910:	100007b7          	lui	a5,0x10000
    80000914:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80000916:	0007c783          	lbu	a5,0(a5)
  }
}
    8000091a:	70e2                	ld	ra,56(sp)
    8000091c:	7442                	ld	s0,48(sp)
    8000091e:	74a2                	ld	s1,40(sp)
    80000920:	7902                	ld	s2,32(sp)
    80000922:	69e2                	ld	s3,24(sp)
    80000924:	6a42                	ld	s4,16(sp)
    80000926:	6aa2                	ld	s5,8(sp)
    80000928:	6b02                	ld	s6,0(sp)
    8000092a:	6121                	addi	sp,sp,64
    8000092c:	8082                	ret
      ReadReg(ISR);
    8000092e:	100007b7          	lui	a5,0x10000
    80000932:	0789                	addi	a5,a5,2 # 10000002 <_entry-0x6ffffffe>
    80000934:	0007c783          	lbu	a5,0(a5)
      return;
    80000938:	8082                	ret

000000008000093a <uartputc>:
{
    8000093a:	7179                	addi	sp,sp,-48
    8000093c:	f406                	sd	ra,40(sp)
    8000093e:	f022                	sd	s0,32(sp)
    80000940:	ec26                	sd	s1,24(sp)
    80000942:	e84a                	sd	s2,16(sp)
    80000944:	e44e                	sd	s3,8(sp)
    80000946:	e052                	sd	s4,0(sp)
    80000948:	1800                	addi	s0,sp,48
    8000094a:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    8000094c:	00012517          	auipc	a0,0x12
    80000950:	9fc50513          	addi	a0,a0,-1540 # 80012348 <uart_tx_lock>
    80000954:	2a0000ef          	jal	80000bf4 <acquire>
  if(panicked){
    80000958:	0000a797          	auipc	a5,0xa
    8000095c:	8e87a783          	lw	a5,-1816(a5) # 8000a240 <panicked>
    80000960:	efbd                	bnez	a5,800009de <uartputc+0xa4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000962:	0000a717          	auipc	a4,0xa
    80000966:	8ee73703          	ld	a4,-1810(a4) # 8000a250 <uart_tx_w>
    8000096a:	0000a797          	auipc	a5,0xa
    8000096e:	8de7b783          	ld	a5,-1826(a5) # 8000a248 <uart_tx_r>
    80000972:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    80000976:	00012997          	auipc	s3,0x12
    8000097a:	9d298993          	addi	s3,s3,-1582 # 80012348 <uart_tx_lock>
    8000097e:	0000a497          	auipc	s1,0xa
    80000982:	8ca48493          	addi	s1,s1,-1846 # 8000a248 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000986:	0000a917          	auipc	s2,0xa
    8000098a:	8ca90913          	addi	s2,s2,-1846 # 8000a250 <uart_tx_w>
    8000098e:	00e79d63          	bne	a5,a4,800009a8 <uartputc+0x6e>
    sleep(&uart_tx_r, &uart_tx_lock);
    80000992:	85ce                	mv	a1,s3
    80000994:	8526                	mv	a0,s1
    80000996:	596010ef          	jal	80001f2c <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000099a:	00093703          	ld	a4,0(s2)
    8000099e:	609c                	ld	a5,0(s1)
    800009a0:	02078793          	addi	a5,a5,32
    800009a4:	fee787e3          	beq	a5,a4,80000992 <uartputc+0x58>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    800009a8:	00012497          	auipc	s1,0x12
    800009ac:	9a048493          	addi	s1,s1,-1632 # 80012348 <uart_tx_lock>
    800009b0:	01f77793          	andi	a5,a4,31
    800009b4:	97a6                	add	a5,a5,s1
    800009b6:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    800009ba:	0705                	addi	a4,a4,1
    800009bc:	0000a797          	auipc	a5,0xa
    800009c0:	88e7ba23          	sd	a4,-1900(a5) # 8000a250 <uart_tx_w>
  uartstart();
    800009c4:	ed7ff0ef          	jal	8000089a <uartstart>
  release(&uart_tx_lock);
    800009c8:	8526                	mv	a0,s1
    800009ca:	2c2000ef          	jal	80000c8c <release>
}
    800009ce:	70a2                	ld	ra,40(sp)
    800009d0:	7402                	ld	s0,32(sp)
    800009d2:	64e2                	ld	s1,24(sp)
    800009d4:	6942                	ld	s2,16(sp)
    800009d6:	69a2                	ld	s3,8(sp)
    800009d8:	6a02                	ld	s4,0(sp)
    800009da:	6145                	addi	sp,sp,48
    800009dc:	8082                	ret
    for(;;)
    800009de:	a001                	j	800009de <uartputc+0xa4>

00000000800009e0 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    800009e0:	1141                	addi	sp,sp,-16
    800009e2:	e422                	sd	s0,8(sp)
    800009e4:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    800009e6:	100007b7          	lui	a5,0x10000
    800009ea:	0795                	addi	a5,a5,5 # 10000005 <_entry-0x6ffffffb>
    800009ec:	0007c783          	lbu	a5,0(a5)
    800009f0:	8b85                	andi	a5,a5,1
    800009f2:	cb81                	beqz	a5,80000a02 <uartgetc+0x22>
    // input data is ready.
    return ReadReg(RHR);
    800009f4:	100007b7          	lui	a5,0x10000
    800009f8:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    800009fc:	6422                	ld	s0,8(sp)
    800009fe:	0141                	addi	sp,sp,16
    80000a00:	8082                	ret
    return -1;
    80000a02:	557d                	li	a0,-1
    80000a04:	bfe5                	j	800009fc <uartgetc+0x1c>

0000000080000a06 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000a06:	1101                	addi	sp,sp,-32
    80000a08:	ec06                	sd	ra,24(sp)
    80000a0a:	e822                	sd	s0,16(sp)
    80000a0c:	e426                	sd	s1,8(sp)
    80000a0e:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    80000a10:	54fd                	li	s1,-1
    80000a12:	a019                	j	80000a18 <uartintr+0x12>
      break;
    consoleintr(c);
    80000a14:	85fff0ef          	jal	80000272 <consoleintr>
    int c = uartgetc();
    80000a18:	fc9ff0ef          	jal	800009e0 <uartgetc>
    if(c == -1)
    80000a1c:	fe951ce3          	bne	a0,s1,80000a14 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    80000a20:	00012497          	auipc	s1,0x12
    80000a24:	92848493          	addi	s1,s1,-1752 # 80012348 <uart_tx_lock>
    80000a28:	8526                	mv	a0,s1
    80000a2a:	1ca000ef          	jal	80000bf4 <acquire>
  uartstart();
    80000a2e:	e6dff0ef          	jal	8000089a <uartstart>
  release(&uart_tx_lock);
    80000a32:	8526                	mv	a0,s1
    80000a34:	258000ef          	jal	80000c8c <release>
}
    80000a38:	60e2                	ld	ra,24(sp)
    80000a3a:	6442                	ld	s0,16(sp)
    80000a3c:	64a2                	ld	s1,8(sp)
    80000a3e:	6105                	addi	sp,sp,32
    80000a40:	8082                	ret

0000000080000a42 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    80000a42:	1101                	addi	sp,sp,-32
    80000a44:	ec06                	sd	ra,24(sp)
    80000a46:	e822                	sd	s0,16(sp)
    80000a48:	e426                	sd	s1,8(sp)
    80000a4a:	e04a                	sd	s2,0(sp)
    80000a4c:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    80000a4e:	03451793          	slli	a5,a0,0x34
    80000a52:	e7a9                	bnez	a5,80000a9c <kfree+0x5a>
    80000a54:	84aa                	mv	s1,a0
    80000a56:	00023797          	auipc	a5,0x23
    80000a5a:	15a78793          	addi	a5,a5,346 # 80023bb0 <end>
    80000a5e:	02f56f63          	bltu	a0,a5,80000a9c <kfree+0x5a>
    80000a62:	47c5                	li	a5,17
    80000a64:	07ee                	slli	a5,a5,0x1b
    80000a66:	02f57b63          	bgeu	a0,a5,80000a9c <kfree+0x5a>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a6a:	6605                	lui	a2,0x1
    80000a6c:	4585                	li	a1,1
    80000a6e:	25a000ef          	jal	80000cc8 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a72:	00012917          	auipc	s2,0x12
    80000a76:	90e90913          	addi	s2,s2,-1778 # 80012380 <kmem>
    80000a7a:	854a                	mv	a0,s2
    80000a7c:	178000ef          	jal	80000bf4 <acquire>
  r->next = kmem.freelist;
    80000a80:	01893783          	ld	a5,24(s2)
    80000a84:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a86:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a8a:	854a                	mv	a0,s2
    80000a8c:	200000ef          	jal	80000c8c <release>
}
    80000a90:	60e2                	ld	ra,24(sp)
    80000a92:	6442                	ld	s0,16(sp)
    80000a94:	64a2                	ld	s1,8(sp)
    80000a96:	6902                	ld	s2,0(sp)
    80000a98:	6105                	addi	sp,sp,32
    80000a9a:	8082                	ret
    panic("kfree");
    80000a9c:	00006517          	auipc	a0,0x6
    80000aa0:	59c50513          	addi	a0,a0,1436 # 80007038 <etext+0x38>
    80000aa4:	cf1ff0ef          	jal	80000794 <panic>

0000000080000aa8 <freerange>:
{
    80000aa8:	7179                	addi	sp,sp,-48
    80000aaa:	f406                	sd	ra,40(sp)
    80000aac:	f022                	sd	s0,32(sp)
    80000aae:	ec26                	sd	s1,24(sp)
    80000ab0:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000ab2:	6785                	lui	a5,0x1
    80000ab4:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000ab8:	00e504b3          	add	s1,a0,a4
    80000abc:	777d                	lui	a4,0xfffff
    80000abe:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ac0:	94be                	add	s1,s1,a5
    80000ac2:	0295e263          	bltu	a1,s1,80000ae6 <freerange+0x3e>
    80000ac6:	e84a                	sd	s2,16(sp)
    80000ac8:	e44e                	sd	s3,8(sp)
    80000aca:	e052                	sd	s4,0(sp)
    80000acc:	892e                	mv	s2,a1
    kfree(p);
    80000ace:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ad0:	6985                	lui	s3,0x1
    kfree(p);
    80000ad2:	01448533          	add	a0,s1,s4
    80000ad6:	f6dff0ef          	jal	80000a42 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000ada:	94ce                	add	s1,s1,s3
    80000adc:	fe997be3          	bgeu	s2,s1,80000ad2 <freerange+0x2a>
    80000ae0:	6942                	ld	s2,16(sp)
    80000ae2:	69a2                	ld	s3,8(sp)
    80000ae4:	6a02                	ld	s4,0(sp)
}
    80000ae6:	70a2                	ld	ra,40(sp)
    80000ae8:	7402                	ld	s0,32(sp)
    80000aea:	64e2                	ld	s1,24(sp)
    80000aec:	6145                	addi	sp,sp,48
    80000aee:	8082                	ret

0000000080000af0 <kinit>:
{
    80000af0:	1141                	addi	sp,sp,-16
    80000af2:	e406                	sd	ra,8(sp)
    80000af4:	e022                	sd	s0,0(sp)
    80000af6:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000af8:	00006597          	auipc	a1,0x6
    80000afc:	54858593          	addi	a1,a1,1352 # 80007040 <etext+0x40>
    80000b00:	00012517          	auipc	a0,0x12
    80000b04:	88050513          	addi	a0,a0,-1920 # 80012380 <kmem>
    80000b08:	06c000ef          	jal	80000b74 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000b0c:	45c5                	li	a1,17
    80000b0e:	05ee                	slli	a1,a1,0x1b
    80000b10:	00023517          	auipc	a0,0x23
    80000b14:	0a050513          	addi	a0,a0,160 # 80023bb0 <end>
    80000b18:	f91ff0ef          	jal	80000aa8 <freerange>
}
    80000b1c:	60a2                	ld	ra,8(sp)
    80000b1e:	6402                	ld	s0,0(sp)
    80000b20:	0141                	addi	sp,sp,16
    80000b22:	8082                	ret

0000000080000b24 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000b24:	1101                	addi	sp,sp,-32
    80000b26:	ec06                	sd	ra,24(sp)
    80000b28:	e822                	sd	s0,16(sp)
    80000b2a:	e426                	sd	s1,8(sp)
    80000b2c:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000b2e:	00012497          	auipc	s1,0x12
    80000b32:	85248493          	addi	s1,s1,-1966 # 80012380 <kmem>
    80000b36:	8526                	mv	a0,s1
    80000b38:	0bc000ef          	jal	80000bf4 <acquire>
  r = kmem.freelist;
    80000b3c:	6c84                	ld	s1,24(s1)
  if(r)
    80000b3e:	c485                	beqz	s1,80000b66 <kalloc+0x42>
    kmem.freelist = r->next;
    80000b40:	609c                	ld	a5,0(s1)
    80000b42:	00012517          	auipc	a0,0x12
    80000b46:	83e50513          	addi	a0,a0,-1986 # 80012380 <kmem>
    80000b4a:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b4c:	140000ef          	jal	80000c8c <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b50:	6605                	lui	a2,0x1
    80000b52:	4595                	li	a1,5
    80000b54:	8526                	mv	a0,s1
    80000b56:	172000ef          	jal	80000cc8 <memset>
  return (void*)r;
}
    80000b5a:	8526                	mv	a0,s1
    80000b5c:	60e2                	ld	ra,24(sp)
    80000b5e:	6442                	ld	s0,16(sp)
    80000b60:	64a2                	ld	s1,8(sp)
    80000b62:	6105                	addi	sp,sp,32
    80000b64:	8082                	ret
  release(&kmem.lock);
    80000b66:	00012517          	auipc	a0,0x12
    80000b6a:	81a50513          	addi	a0,a0,-2022 # 80012380 <kmem>
    80000b6e:	11e000ef          	jal	80000c8c <release>
  if(r)
    80000b72:	b7e5                	j	80000b5a <kalloc+0x36>

0000000080000b74 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b74:	1141                	addi	sp,sp,-16
    80000b76:	e422                	sd	s0,8(sp)
    80000b78:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b7a:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b7c:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b80:	00053823          	sd	zero,16(a0)
}
    80000b84:	6422                	ld	s0,8(sp)
    80000b86:	0141                	addi	sp,sp,16
    80000b88:	8082                	ret

0000000080000b8a <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b8a:	411c                	lw	a5,0(a0)
    80000b8c:	e399                	bnez	a5,80000b92 <holding+0x8>
    80000b8e:	4501                	li	a0,0
  return r;
}
    80000b90:	8082                	ret
{
    80000b92:	1101                	addi	sp,sp,-32
    80000b94:	ec06                	sd	ra,24(sp)
    80000b96:	e822                	sd	s0,16(sp)
    80000b98:	e426                	sd	s1,8(sp)
    80000b9a:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b9c:	6904                	ld	s1,16(a0)
    80000b9e:	527000ef          	jal	800018c4 <mycpu>
    80000ba2:	40a48533          	sub	a0,s1,a0
    80000ba6:	00153513          	seqz	a0,a0
}
    80000baa:	60e2                	ld	ra,24(sp)
    80000bac:	6442                	ld	s0,16(sp)
    80000bae:	64a2                	ld	s1,8(sp)
    80000bb0:	6105                	addi	sp,sp,32
    80000bb2:	8082                	ret

0000000080000bb4 <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000bb4:	1101                	addi	sp,sp,-32
    80000bb6:	ec06                	sd	ra,24(sp)
    80000bb8:	e822                	sd	s0,16(sp)
    80000bba:	e426                	sd	s1,8(sp)
    80000bbc:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000bbe:	100024f3          	csrr	s1,sstatus
    80000bc2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000bc6:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000bc8:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000bcc:	4f9000ef          	jal	800018c4 <mycpu>
    80000bd0:	5d3c                	lw	a5,120(a0)
    80000bd2:	cb99                	beqz	a5,80000be8 <push_off+0x34>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bd4:	4f1000ef          	jal	800018c4 <mycpu>
    80000bd8:	5d3c                	lw	a5,120(a0)
    80000bda:	2785                	addiw	a5,a5,1
    80000bdc:	dd3c                	sw	a5,120(a0)
}
    80000bde:	60e2                	ld	ra,24(sp)
    80000be0:	6442                	ld	s0,16(sp)
    80000be2:	64a2                	ld	s1,8(sp)
    80000be4:	6105                	addi	sp,sp,32
    80000be6:	8082                	ret
    mycpu()->intena = old;
    80000be8:	4dd000ef          	jal	800018c4 <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bec:	8085                	srli	s1,s1,0x1
    80000bee:	8885                	andi	s1,s1,1
    80000bf0:	dd64                	sw	s1,124(a0)
    80000bf2:	b7cd                	j	80000bd4 <push_off+0x20>

0000000080000bf4 <acquire>:
{
    80000bf4:	1101                	addi	sp,sp,-32
    80000bf6:	ec06                	sd	ra,24(sp)
    80000bf8:	e822                	sd	s0,16(sp)
    80000bfa:	e426                	sd	s1,8(sp)
    80000bfc:	1000                	addi	s0,sp,32
    80000bfe:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000c00:	fb5ff0ef          	jal	80000bb4 <push_off>
  if(holding(lk))
    80000c04:	8526                	mv	a0,s1
    80000c06:	f85ff0ef          	jal	80000b8a <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c0a:	4705                	li	a4,1
  if(holding(lk))
    80000c0c:	e105                	bnez	a0,80000c2c <acquire+0x38>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000c0e:	87ba                	mv	a5,a4
    80000c10:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000c14:	2781                	sext.w	a5,a5
    80000c16:	ffe5                	bnez	a5,80000c0e <acquire+0x1a>
  __sync_synchronize();
    80000c18:	0330000f          	fence	rw,rw
  lk->cpu = mycpu();
    80000c1c:	4a9000ef          	jal	800018c4 <mycpu>
    80000c20:	e888                	sd	a0,16(s1)
}
    80000c22:	60e2                	ld	ra,24(sp)
    80000c24:	6442                	ld	s0,16(sp)
    80000c26:	64a2                	ld	s1,8(sp)
    80000c28:	6105                	addi	sp,sp,32
    80000c2a:	8082                	ret
    panic("acquire");
    80000c2c:	00006517          	auipc	a0,0x6
    80000c30:	41c50513          	addi	a0,a0,1052 # 80007048 <etext+0x48>
    80000c34:	b61ff0ef          	jal	80000794 <panic>

0000000080000c38 <pop_off>:

void
pop_off(void)
{
    80000c38:	1141                	addi	sp,sp,-16
    80000c3a:	e406                	sd	ra,8(sp)
    80000c3c:	e022                	sd	s0,0(sp)
    80000c3e:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c40:	485000ef          	jal	800018c4 <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c44:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c48:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c4a:	e78d                	bnez	a5,80000c74 <pop_off+0x3c>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c4c:	5d3c                	lw	a5,120(a0)
    80000c4e:	02f05963          	blez	a5,80000c80 <pop_off+0x48>
    panic("pop_off");
  c->noff -= 1;
    80000c52:	37fd                	addiw	a5,a5,-1
    80000c54:	0007871b          	sext.w	a4,a5
    80000c58:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c5a:	eb09                	bnez	a4,80000c6c <pop_off+0x34>
    80000c5c:	5d7c                	lw	a5,124(a0)
    80000c5e:	c799                	beqz	a5,80000c6c <pop_off+0x34>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c60:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c64:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c68:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c6c:	60a2                	ld	ra,8(sp)
    80000c6e:	6402                	ld	s0,0(sp)
    80000c70:	0141                	addi	sp,sp,16
    80000c72:	8082                	ret
    panic("pop_off - interruptible");
    80000c74:	00006517          	auipc	a0,0x6
    80000c78:	3dc50513          	addi	a0,a0,988 # 80007050 <etext+0x50>
    80000c7c:	b19ff0ef          	jal	80000794 <panic>
    panic("pop_off");
    80000c80:	00006517          	auipc	a0,0x6
    80000c84:	3e850513          	addi	a0,a0,1000 # 80007068 <etext+0x68>
    80000c88:	b0dff0ef          	jal	80000794 <panic>

0000000080000c8c <release>:
{
    80000c8c:	1101                	addi	sp,sp,-32
    80000c8e:	ec06                	sd	ra,24(sp)
    80000c90:	e822                	sd	s0,16(sp)
    80000c92:	e426                	sd	s1,8(sp)
    80000c94:	1000                	addi	s0,sp,32
    80000c96:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c98:	ef3ff0ef          	jal	80000b8a <holding>
    80000c9c:	c105                	beqz	a0,80000cbc <release+0x30>
  lk->cpu = 0;
    80000c9e:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca2:	0330000f          	fence	rw,rw
  __sync_lock_release(&lk->locked);
    80000ca6:	0310000f          	fence	rw,w
    80000caa:	0004a023          	sw	zero,0(s1)
  pop_off();
    80000cae:	f8bff0ef          	jal	80000c38 <pop_off>
}
    80000cb2:	60e2                	ld	ra,24(sp)
    80000cb4:	6442                	ld	s0,16(sp)
    80000cb6:	64a2                	ld	s1,8(sp)
    80000cb8:	6105                	addi	sp,sp,32
    80000cba:	8082                	ret
    panic("release");
    80000cbc:	00006517          	auipc	a0,0x6
    80000cc0:	3b450513          	addi	a0,a0,948 # 80007070 <etext+0x70>
    80000cc4:	ad1ff0ef          	jal	80000794 <panic>

0000000080000cc8 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cc8:	1141                	addi	sp,sp,-16
    80000cca:	e422                	sd	s0,8(sp)
    80000ccc:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cce:	ca19                	beqz	a2,80000ce4 <memset+0x1c>
    80000cd0:	87aa                	mv	a5,a0
    80000cd2:	1602                	slli	a2,a2,0x20
    80000cd4:	9201                	srli	a2,a2,0x20
    80000cd6:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000cda:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000cde:	0785                	addi	a5,a5,1
    80000ce0:	fee79de3          	bne	a5,a4,80000cda <memset+0x12>
  }
  return dst;
}
    80000ce4:	6422                	ld	s0,8(sp)
    80000ce6:	0141                	addi	sp,sp,16
    80000ce8:	8082                	ret

0000000080000cea <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cea:	1141                	addi	sp,sp,-16
    80000cec:	e422                	sd	s0,8(sp)
    80000cee:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cf0:	ca05                	beqz	a2,80000d20 <memcmp+0x36>
    80000cf2:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000cf6:	1682                	slli	a3,a3,0x20
    80000cf8:	9281                	srli	a3,a3,0x20
    80000cfa:	0685                	addi	a3,a3,1
    80000cfc:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000cfe:	00054783          	lbu	a5,0(a0)
    80000d02:	0005c703          	lbu	a4,0(a1)
    80000d06:	00e79863          	bne	a5,a4,80000d16 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d0a:	0505                	addi	a0,a0,1
    80000d0c:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d0e:	fed518e3          	bne	a0,a3,80000cfe <memcmp+0x14>
  }

  return 0;
    80000d12:	4501                	li	a0,0
    80000d14:	a019                	j	80000d1a <memcmp+0x30>
      return *s1 - *s2;
    80000d16:	40e7853b          	subw	a0,a5,a4
}
    80000d1a:	6422                	ld	s0,8(sp)
    80000d1c:	0141                	addi	sp,sp,16
    80000d1e:	8082                	ret
  return 0;
    80000d20:	4501                	li	a0,0
    80000d22:	bfe5                	j	80000d1a <memcmp+0x30>

0000000080000d24 <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d24:	1141                	addi	sp,sp,-16
    80000d26:	e422                	sd	s0,8(sp)
    80000d28:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d2a:	c205                	beqz	a2,80000d4a <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d2c:	02a5e263          	bltu	a1,a0,80000d50 <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d30:	1602                	slli	a2,a2,0x20
    80000d32:	9201                	srli	a2,a2,0x20
    80000d34:	00c587b3          	add	a5,a1,a2
{
    80000d38:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d3a:	0585                	addi	a1,a1,1
    80000d3c:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdb451>
    80000d3e:	fff5c683          	lbu	a3,-1(a1)
    80000d42:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d46:	feb79ae3          	bne	a5,a1,80000d3a <memmove+0x16>

  return dst;
}
    80000d4a:	6422                	ld	s0,8(sp)
    80000d4c:	0141                	addi	sp,sp,16
    80000d4e:	8082                	ret
  if(s < d && s + n > d){
    80000d50:	02061693          	slli	a3,a2,0x20
    80000d54:	9281                	srli	a3,a3,0x20
    80000d56:	00d58733          	add	a4,a1,a3
    80000d5a:	fce57be3          	bgeu	a0,a4,80000d30 <memmove+0xc>
    d += n;
    80000d5e:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d60:	fff6079b          	addiw	a5,a2,-1
    80000d64:	1782                	slli	a5,a5,0x20
    80000d66:	9381                	srli	a5,a5,0x20
    80000d68:	fff7c793          	not	a5,a5
    80000d6c:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d6e:	177d                	addi	a4,a4,-1
    80000d70:	16fd                	addi	a3,a3,-1
    80000d72:	00074603          	lbu	a2,0(a4)
    80000d76:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d7a:	fef71ae3          	bne	a4,a5,80000d6e <memmove+0x4a>
    80000d7e:	b7f1                	j	80000d4a <memmove+0x26>

0000000080000d80 <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d80:	1141                	addi	sp,sp,-16
    80000d82:	e406                	sd	ra,8(sp)
    80000d84:	e022                	sd	s0,0(sp)
    80000d86:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d88:	f9dff0ef          	jal	80000d24 <memmove>
}
    80000d8c:	60a2                	ld	ra,8(sp)
    80000d8e:	6402                	ld	s0,0(sp)
    80000d90:	0141                	addi	sp,sp,16
    80000d92:	8082                	ret

0000000080000d94 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000d94:	1141                	addi	sp,sp,-16
    80000d96:	e422                	sd	s0,8(sp)
    80000d98:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000d9a:	ce11                	beqz	a2,80000db6 <strncmp+0x22>
    80000d9c:	00054783          	lbu	a5,0(a0)
    80000da0:	cf89                	beqz	a5,80000dba <strncmp+0x26>
    80000da2:	0005c703          	lbu	a4,0(a1)
    80000da6:	00f71a63          	bne	a4,a5,80000dba <strncmp+0x26>
    n--, p++, q++;
    80000daa:	367d                	addiw	a2,a2,-1
    80000dac:	0505                	addi	a0,a0,1
    80000dae:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000db0:	f675                	bnez	a2,80000d9c <strncmp+0x8>
  if(n == 0)
    return 0;
    80000db2:	4501                	li	a0,0
    80000db4:	a801                	j	80000dc4 <strncmp+0x30>
    80000db6:	4501                	li	a0,0
    80000db8:	a031                	j	80000dc4 <strncmp+0x30>
  return (uchar)*p - (uchar)*q;
    80000dba:	00054503          	lbu	a0,0(a0)
    80000dbe:	0005c783          	lbu	a5,0(a1)
    80000dc2:	9d1d                	subw	a0,a0,a5
}
    80000dc4:	6422                	ld	s0,8(sp)
    80000dc6:	0141                	addi	sp,sp,16
    80000dc8:	8082                	ret

0000000080000dca <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dca:	1141                	addi	sp,sp,-16
    80000dcc:	e422                	sd	s0,8(sp)
    80000dce:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000dd0:	87aa                	mv	a5,a0
    80000dd2:	86b2                	mv	a3,a2
    80000dd4:	367d                	addiw	a2,a2,-1
    80000dd6:	02d05563          	blez	a3,80000e00 <strncpy+0x36>
    80000dda:	0785                	addi	a5,a5,1
    80000ddc:	0005c703          	lbu	a4,0(a1)
    80000de0:	fee78fa3          	sb	a4,-1(a5)
    80000de4:	0585                	addi	a1,a1,1
    80000de6:	f775                	bnez	a4,80000dd2 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000de8:	873e                	mv	a4,a5
    80000dea:	9fb5                	addw	a5,a5,a3
    80000dec:	37fd                	addiw	a5,a5,-1
    80000dee:	00c05963          	blez	a2,80000e00 <strncpy+0x36>
    *s++ = 0;
    80000df2:	0705                	addi	a4,a4,1
    80000df4:	fe070fa3          	sb	zero,-1(a4)
  while(n-- > 0)
    80000df8:	40e786bb          	subw	a3,a5,a4
    80000dfc:	fed04be3          	bgtz	a3,80000df2 <strncpy+0x28>
  return os;
}
    80000e00:	6422                	ld	s0,8(sp)
    80000e02:	0141                	addi	sp,sp,16
    80000e04:	8082                	ret

0000000080000e06 <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e06:	1141                	addi	sp,sp,-16
    80000e08:	e422                	sd	s0,8(sp)
    80000e0a:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e0c:	02c05363          	blez	a2,80000e32 <safestrcpy+0x2c>
    80000e10:	fff6069b          	addiw	a3,a2,-1
    80000e14:	1682                	slli	a3,a3,0x20
    80000e16:	9281                	srli	a3,a3,0x20
    80000e18:	96ae                	add	a3,a3,a1
    80000e1a:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e1c:	00d58963          	beq	a1,a3,80000e2e <safestrcpy+0x28>
    80000e20:	0585                	addi	a1,a1,1
    80000e22:	0785                	addi	a5,a5,1
    80000e24:	fff5c703          	lbu	a4,-1(a1)
    80000e28:	fee78fa3          	sb	a4,-1(a5)
    80000e2c:	fb65                	bnez	a4,80000e1c <safestrcpy+0x16>
    ;
  *s = 0;
    80000e2e:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e32:	6422                	ld	s0,8(sp)
    80000e34:	0141                	addi	sp,sp,16
    80000e36:	8082                	ret

0000000080000e38 <strlen>:

int
strlen(const char *s)
{
    80000e38:	1141                	addi	sp,sp,-16
    80000e3a:	e422                	sd	s0,8(sp)
    80000e3c:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e3e:	00054783          	lbu	a5,0(a0)
    80000e42:	cf91                	beqz	a5,80000e5e <strlen+0x26>
    80000e44:	0505                	addi	a0,a0,1
    80000e46:	87aa                	mv	a5,a0
    80000e48:	86be                	mv	a3,a5
    80000e4a:	0785                	addi	a5,a5,1
    80000e4c:	fff7c703          	lbu	a4,-1(a5)
    80000e50:	ff65                	bnez	a4,80000e48 <strlen+0x10>
    80000e52:	40a6853b          	subw	a0,a3,a0
    80000e56:	2505                	addiw	a0,a0,1
    ;
  return n;
}
    80000e58:	6422                	ld	s0,8(sp)
    80000e5a:	0141                	addi	sp,sp,16
    80000e5c:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e5e:	4501                	li	a0,0
    80000e60:	bfe5                	j	80000e58 <strlen+0x20>

0000000080000e62 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e62:	1141                	addi	sp,sp,-16
    80000e64:	e406                	sd	ra,8(sp)
    80000e66:	e022                	sd	s0,0(sp)
    80000e68:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e6a:	24b000ef          	jal	800018b4 <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e6e:	00009717          	auipc	a4,0x9
    80000e72:	3ea70713          	addi	a4,a4,1002 # 8000a258 <started>
  if(cpuid() == 0){
    80000e76:	c51d                	beqz	a0,80000ea4 <main+0x42>
    while(started == 0)
    80000e78:	431c                	lw	a5,0(a4)
    80000e7a:	2781                	sext.w	a5,a5
    80000e7c:	dff5                	beqz	a5,80000e78 <main+0x16>
      ;
    __sync_synchronize();
    80000e7e:	0330000f          	fence	rw,rw
    printf("hart %d starting\n", cpuid());
    80000e82:	233000ef          	jal	800018b4 <cpuid>
    80000e86:	85aa                	mv	a1,a0
    80000e88:	00006517          	auipc	a0,0x6
    80000e8c:	21050513          	addi	a0,a0,528 # 80007098 <etext+0x98>
    80000e90:	e32ff0ef          	jal	800004c2 <printf>
    kvminithart();    // turn on paging
    80000e94:	080000ef          	jal	80000f14 <kvminithart>
    trapinithart();   // install kernel trap vector
    80000e98:	5b6010ef          	jal	8000244e <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000e9c:	48c040ef          	jal	80005328 <plicinithart>
  }

  scheduler();        
    80000ea0:	69d000ef          	jal	80001d3c <scheduler>
    consoleinit();
    80000ea4:	d48ff0ef          	jal	800003ec <consoleinit>
    printfinit();
    80000ea8:	927ff0ef          	jal	800007ce <printfinit>
    printf("\n");
    80000eac:	00006517          	auipc	a0,0x6
    80000eb0:	1cc50513          	addi	a0,a0,460 # 80007078 <etext+0x78>
    80000eb4:	e0eff0ef          	jal	800004c2 <printf>
    printf("xv6 kernel is booting\n");
    80000eb8:	00006517          	auipc	a0,0x6
    80000ebc:	1c850513          	addi	a0,a0,456 # 80007080 <etext+0x80>
    80000ec0:	e02ff0ef          	jal	800004c2 <printf>
    printf("\n");
    80000ec4:	00006517          	auipc	a0,0x6
    80000ec8:	1b450513          	addi	a0,a0,436 # 80007078 <etext+0x78>
    80000ecc:	df6ff0ef          	jal	800004c2 <printf>
    kinit();         // physical page allocator
    80000ed0:	c21ff0ef          	jal	80000af0 <kinit>
    kvminit();       // create kernel page table
    80000ed4:	2ca000ef          	jal	8000119e <kvminit>
    kvminithart();   // turn on paging
    80000ed8:	03c000ef          	jal	80000f14 <kvminithart>
    procinit();      // process table
    80000edc:	123000ef          	jal	800017fe <procinit>
    trapinit();      // trap vectors
    80000ee0:	54a010ef          	jal	8000242a <trapinit>
    trapinithart();  // install kernel trap vector
    80000ee4:	56a010ef          	jal	8000244e <trapinithart>
    plicinit();      // set up interrupt controller
    80000ee8:	426040ef          	jal	8000530e <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000eec:	43c040ef          	jal	80005328 <plicinithart>
    binit();         // buffer cache
    80000ef0:	3e7010ef          	jal	80002ad6 <binit>
    iinit();         // inode table
    80000ef4:	1d8020ef          	jal	800030cc <iinit>
    fileinit();      // file table
    80000ef8:	785020ef          	jal	80003e7c <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000efc:	51c040ef          	jal	80005418 <virtio_disk_init>
    userinit();      // first user process
    80000f00:	459000ef          	jal	80001b58 <userinit>
    __sync_synchronize();
    80000f04:	0330000f          	fence	rw,rw
    started = 1;
    80000f08:	4785                	li	a5,1
    80000f0a:	00009717          	auipc	a4,0x9
    80000f0e:	34f72723          	sw	a5,846(a4) # 8000a258 <started>
    80000f12:	b779                	j	80000ea0 <main+0x3e>

0000000080000f14 <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f14:	1141                	addi	sp,sp,-16
    80000f16:	e422                	sd	s0,8(sp)
    80000f18:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f1a:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f1e:	00009797          	auipc	a5,0x9
    80000f22:	3427b783          	ld	a5,834(a5) # 8000a260 <kernel_pagetable>
    80000f26:	83b1                	srli	a5,a5,0xc
    80000f28:	577d                	li	a4,-1
    80000f2a:	177e                	slli	a4,a4,0x3f
    80000f2c:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000f2e:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000f32:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000f36:	6422                	ld	s0,8(sp)
    80000f38:	0141                	addi	sp,sp,16
    80000f3a:	8082                	ret

0000000080000f3c <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000f3c:	7139                	addi	sp,sp,-64
    80000f3e:	fc06                	sd	ra,56(sp)
    80000f40:	f822                	sd	s0,48(sp)
    80000f42:	f426                	sd	s1,40(sp)
    80000f44:	f04a                	sd	s2,32(sp)
    80000f46:	ec4e                	sd	s3,24(sp)
    80000f48:	e852                	sd	s4,16(sp)
    80000f4a:	e456                	sd	s5,8(sp)
    80000f4c:	e05a                	sd	s6,0(sp)
    80000f4e:	0080                	addi	s0,sp,64
    80000f50:	84aa                	mv	s1,a0
    80000f52:	89ae                	mv	s3,a1
    80000f54:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000f56:	57fd                	li	a5,-1
    80000f58:	83e9                	srli	a5,a5,0x1a
    80000f5a:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000f5c:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000f5e:	02b7fc63          	bgeu	a5,a1,80000f96 <walk+0x5a>
    panic("walk");
    80000f62:	00006517          	auipc	a0,0x6
    80000f66:	14e50513          	addi	a0,a0,334 # 800070b0 <etext+0xb0>
    80000f6a:	82bff0ef          	jal	80000794 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000f6e:	060a8263          	beqz	s5,80000fd2 <walk+0x96>
    80000f72:	bb3ff0ef          	jal	80000b24 <kalloc>
    80000f76:	84aa                	mv	s1,a0
    80000f78:	c139                	beqz	a0,80000fbe <walk+0x82>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000f7a:	6605                	lui	a2,0x1
    80000f7c:	4581                	li	a1,0
    80000f7e:	d4bff0ef          	jal	80000cc8 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80000f82:	00c4d793          	srli	a5,s1,0xc
    80000f86:	07aa                	slli	a5,a5,0xa
    80000f88:	0017e793          	ori	a5,a5,1
    80000f8c:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80000f90:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdb447>
    80000f92:	036a0063          	beq	s4,s6,80000fb2 <walk+0x76>
    pte_t *pte = &pagetable[PX(level, va)];
    80000f96:	0149d933          	srl	s2,s3,s4
    80000f9a:	1ff97913          	andi	s2,s2,511
    80000f9e:	090e                	slli	s2,s2,0x3
    80000fa0:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80000fa2:	00093483          	ld	s1,0(s2)
    80000fa6:	0014f793          	andi	a5,s1,1
    80000faa:	d3f1                	beqz	a5,80000f6e <walk+0x32>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80000fac:	80a9                	srli	s1,s1,0xa
    80000fae:	04b2                	slli	s1,s1,0xc
    80000fb0:	b7c5                	j	80000f90 <walk+0x54>
    }
  }
  return &pagetable[PX(0, va)];
    80000fb2:	00c9d513          	srli	a0,s3,0xc
    80000fb6:	1ff57513          	andi	a0,a0,511
    80000fba:	050e                	slli	a0,a0,0x3
    80000fbc:	9526                	add	a0,a0,s1
}
    80000fbe:	70e2                	ld	ra,56(sp)
    80000fc0:	7442                	ld	s0,48(sp)
    80000fc2:	74a2                	ld	s1,40(sp)
    80000fc4:	7902                	ld	s2,32(sp)
    80000fc6:	69e2                	ld	s3,24(sp)
    80000fc8:	6a42                	ld	s4,16(sp)
    80000fca:	6aa2                	ld	s5,8(sp)
    80000fcc:	6b02                	ld	s6,0(sp)
    80000fce:	6121                	addi	sp,sp,64
    80000fd0:	8082                	ret
        return 0;
    80000fd2:	4501                	li	a0,0
    80000fd4:	b7ed                	j	80000fbe <walk+0x82>

0000000080000fd6 <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    80000fd6:	57fd                	li	a5,-1
    80000fd8:	83e9                	srli	a5,a5,0x1a
    80000fda:	00b7f463          	bgeu	a5,a1,80000fe2 <walkaddr+0xc>
    return 0;
    80000fde:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80000fe0:	8082                	ret
{
    80000fe2:	1141                	addi	sp,sp,-16
    80000fe4:	e406                	sd	ra,8(sp)
    80000fe6:	e022                	sd	s0,0(sp)
    80000fe8:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80000fea:	4601                	li	a2,0
    80000fec:	f51ff0ef          	jal	80000f3c <walk>
  if(pte == 0)
    80000ff0:	c105                	beqz	a0,80001010 <walkaddr+0x3a>
  if((*pte & PTE_V) == 0)
    80000ff2:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    80000ff4:	0117f693          	andi	a3,a5,17
    80000ff8:	4745                	li	a4,17
    return 0;
    80000ffa:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80000ffc:	00e68663          	beq	a3,a4,80001008 <walkaddr+0x32>
}
    80001000:	60a2                	ld	ra,8(sp)
    80001002:	6402                	ld	s0,0(sp)
    80001004:	0141                	addi	sp,sp,16
    80001006:	8082                	ret
  pa = PTE2PA(*pte);
    80001008:	83a9                	srli	a5,a5,0xa
    8000100a:	00c79513          	slli	a0,a5,0xc
  return pa;
    8000100e:	bfcd                	j	80001000 <walkaddr+0x2a>
    return 0;
    80001010:	4501                	li	a0,0
    80001012:	b7fd                	j	80001000 <walkaddr+0x2a>

0000000080001014 <mappages>:
// va and size MUST be page-aligned.
// Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    80001014:	715d                	addi	sp,sp,-80
    80001016:	e486                	sd	ra,72(sp)
    80001018:	e0a2                	sd	s0,64(sp)
    8000101a:	fc26                	sd	s1,56(sp)
    8000101c:	f84a                	sd	s2,48(sp)
    8000101e:	f44e                	sd	s3,40(sp)
    80001020:	f052                	sd	s4,32(sp)
    80001022:	ec56                	sd	s5,24(sp)
    80001024:	e85a                	sd	s6,16(sp)
    80001026:	e45e                	sd	s7,8(sp)
    80001028:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000102a:	03459793          	slli	a5,a1,0x34
    8000102e:	e7a9                	bnez	a5,80001078 <mappages+0x64>
    80001030:	8aaa                	mv	s5,a0
    80001032:	8b3a                	mv	s6,a4
    panic("mappages: va not aligned");

  if((size % PGSIZE) != 0)
    80001034:	03461793          	slli	a5,a2,0x34
    80001038:	e7b1                	bnez	a5,80001084 <mappages+0x70>
    panic("mappages: size not aligned");

  if(size == 0)
    8000103a:	ca39                	beqz	a2,80001090 <mappages+0x7c>
    panic("mappages: size");
  
  a = va;
  last = va + size - PGSIZE;
    8000103c:	77fd                	lui	a5,0xfffff
    8000103e:	963e                	add	a2,a2,a5
    80001040:	00b609b3          	add	s3,a2,a1
  a = va;
    80001044:	892e                	mv	s2,a1
    80001046:	40b68a33          	sub	s4,a3,a1
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    8000104a:	6b85                	lui	s7,0x1
    8000104c:	014904b3          	add	s1,s2,s4
    if((pte = walk(pagetable, a, 1)) == 0)
    80001050:	4605                	li	a2,1
    80001052:	85ca                	mv	a1,s2
    80001054:	8556                	mv	a0,s5
    80001056:	ee7ff0ef          	jal	80000f3c <walk>
    8000105a:	c539                	beqz	a0,800010a8 <mappages+0x94>
    if(*pte & PTE_V)
    8000105c:	611c                	ld	a5,0(a0)
    8000105e:	8b85                	andi	a5,a5,1
    80001060:	ef95                	bnez	a5,8000109c <mappages+0x88>
    *pte = PA2PTE(pa) | perm | PTE_V;
    80001062:	80b1                	srli	s1,s1,0xc
    80001064:	04aa                	slli	s1,s1,0xa
    80001066:	0164e4b3          	or	s1,s1,s6
    8000106a:	0014e493          	ori	s1,s1,1
    8000106e:	e104                	sd	s1,0(a0)
    if(a == last)
    80001070:	05390863          	beq	s2,s3,800010c0 <mappages+0xac>
    a += PGSIZE;
    80001074:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001076:	bfd9                	j	8000104c <mappages+0x38>
    panic("mappages: va not aligned");
    80001078:	00006517          	auipc	a0,0x6
    8000107c:	04050513          	addi	a0,a0,64 # 800070b8 <etext+0xb8>
    80001080:	f14ff0ef          	jal	80000794 <panic>
    panic("mappages: size not aligned");
    80001084:	00006517          	auipc	a0,0x6
    80001088:	05450513          	addi	a0,a0,84 # 800070d8 <etext+0xd8>
    8000108c:	f08ff0ef          	jal	80000794 <panic>
    panic("mappages: size");
    80001090:	00006517          	auipc	a0,0x6
    80001094:	06850513          	addi	a0,a0,104 # 800070f8 <etext+0xf8>
    80001098:	efcff0ef          	jal	80000794 <panic>
      panic("mappages: remap");
    8000109c:	00006517          	auipc	a0,0x6
    800010a0:	06c50513          	addi	a0,a0,108 # 80007108 <etext+0x108>
    800010a4:	ef0ff0ef          	jal	80000794 <panic>
      return -1;
    800010a8:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    800010aa:	60a6                	ld	ra,72(sp)
    800010ac:	6406                	ld	s0,64(sp)
    800010ae:	74e2                	ld	s1,56(sp)
    800010b0:	7942                	ld	s2,48(sp)
    800010b2:	79a2                	ld	s3,40(sp)
    800010b4:	7a02                	ld	s4,32(sp)
    800010b6:	6ae2                	ld	s5,24(sp)
    800010b8:	6b42                	ld	s6,16(sp)
    800010ba:	6ba2                	ld	s7,8(sp)
    800010bc:	6161                	addi	sp,sp,80
    800010be:	8082                	ret
  return 0;
    800010c0:	4501                	li	a0,0
    800010c2:	b7e5                	j	800010aa <mappages+0x96>

00000000800010c4 <kvmmap>:
{
    800010c4:	1141                	addi	sp,sp,-16
    800010c6:	e406                	sd	ra,8(sp)
    800010c8:	e022                	sd	s0,0(sp)
    800010ca:	0800                	addi	s0,sp,16
    800010cc:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    800010ce:	86b2                	mv	a3,a2
    800010d0:	863e                	mv	a2,a5
    800010d2:	f43ff0ef          	jal	80001014 <mappages>
    800010d6:	e509                	bnez	a0,800010e0 <kvmmap+0x1c>
}
    800010d8:	60a2                	ld	ra,8(sp)
    800010da:	6402                	ld	s0,0(sp)
    800010dc:	0141                	addi	sp,sp,16
    800010de:	8082                	ret
    panic("kvmmap");
    800010e0:	00006517          	auipc	a0,0x6
    800010e4:	03850513          	addi	a0,a0,56 # 80007118 <etext+0x118>
    800010e8:	eacff0ef          	jal	80000794 <panic>

00000000800010ec <kvmmake>:
{
    800010ec:	1101                	addi	sp,sp,-32
    800010ee:	ec06                	sd	ra,24(sp)
    800010f0:	e822                	sd	s0,16(sp)
    800010f2:	e426                	sd	s1,8(sp)
    800010f4:	e04a                	sd	s2,0(sp)
    800010f6:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    800010f8:	a2dff0ef          	jal	80000b24 <kalloc>
    800010fc:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    800010fe:	6605                	lui	a2,0x1
    80001100:	4581                	li	a1,0
    80001102:	bc7ff0ef          	jal	80000cc8 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001106:	4719                	li	a4,6
    80001108:	6685                	lui	a3,0x1
    8000110a:	10000637          	lui	a2,0x10000
    8000110e:	100005b7          	lui	a1,0x10000
    80001112:	8526                	mv	a0,s1
    80001114:	fb1ff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    80001118:	4719                	li	a4,6
    8000111a:	6685                	lui	a3,0x1
    8000111c:	10001637          	lui	a2,0x10001
    80001120:	100015b7          	lui	a1,0x10001
    80001124:	8526                	mv	a0,s1
    80001126:	f9fff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x4000000, PTE_R | PTE_W);
    8000112a:	4719                	li	a4,6
    8000112c:	040006b7          	lui	a3,0x4000
    80001130:	0c000637          	lui	a2,0xc000
    80001134:	0c0005b7          	lui	a1,0xc000
    80001138:	8526                	mv	a0,s1
    8000113a:	f8bff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    8000113e:	00006917          	auipc	s2,0x6
    80001142:	ec290913          	addi	s2,s2,-318 # 80007000 <etext>
    80001146:	4729                	li	a4,10
    80001148:	80006697          	auipc	a3,0x80006
    8000114c:	eb868693          	addi	a3,a3,-328 # 7000 <_entry-0x7fff9000>
    80001150:	4605                	li	a2,1
    80001152:	067e                	slli	a2,a2,0x1f
    80001154:	85b2                	mv	a1,a2
    80001156:	8526                	mv	a0,s1
    80001158:	f6dff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    8000115c:	46c5                	li	a3,17
    8000115e:	06ee                	slli	a3,a3,0x1b
    80001160:	4719                	li	a4,6
    80001162:	412686b3          	sub	a3,a3,s2
    80001166:	864a                	mv	a2,s2
    80001168:	85ca                	mv	a1,s2
    8000116a:	8526                	mv	a0,s1
    8000116c:	f59ff0ef          	jal	800010c4 <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    80001170:	4729                	li	a4,10
    80001172:	6685                	lui	a3,0x1
    80001174:	00005617          	auipc	a2,0x5
    80001178:	e8c60613          	addi	a2,a2,-372 # 80006000 <_trampoline>
    8000117c:	040005b7          	lui	a1,0x4000
    80001180:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001182:	05b2                	slli	a1,a1,0xc
    80001184:	8526                	mv	a0,s1
    80001186:	f3fff0ef          	jal	800010c4 <kvmmap>
  proc_mapstacks(kpgtbl);
    8000118a:	8526                	mv	a0,s1
    8000118c:	5da000ef          	jal	80001766 <proc_mapstacks>
}
    80001190:	8526                	mv	a0,s1
    80001192:	60e2                	ld	ra,24(sp)
    80001194:	6442                	ld	s0,16(sp)
    80001196:	64a2                	ld	s1,8(sp)
    80001198:	6902                	ld	s2,0(sp)
    8000119a:	6105                	addi	sp,sp,32
    8000119c:	8082                	ret

000000008000119e <kvminit>:
{
    8000119e:	1141                	addi	sp,sp,-16
    800011a0:	e406                	sd	ra,8(sp)
    800011a2:	e022                	sd	s0,0(sp)
    800011a4:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    800011a6:	f47ff0ef          	jal	800010ec <kvmmake>
    800011aa:	00009797          	auipc	a5,0x9
    800011ae:	0aa7bb23          	sd	a0,182(a5) # 8000a260 <kernel_pagetable>
}
    800011b2:	60a2                	ld	ra,8(sp)
    800011b4:	6402                	ld	s0,0(sp)
    800011b6:	0141                	addi	sp,sp,16
    800011b8:	8082                	ret

00000000800011ba <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    800011ba:	715d                	addi	sp,sp,-80
    800011bc:	e486                	sd	ra,72(sp)
    800011be:	e0a2                	sd	s0,64(sp)
    800011c0:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    800011c2:	03459793          	slli	a5,a1,0x34
    800011c6:	e39d                	bnez	a5,800011ec <uvmunmap+0x32>
    800011c8:	f84a                	sd	s2,48(sp)
    800011ca:	f44e                	sd	s3,40(sp)
    800011cc:	f052                	sd	s4,32(sp)
    800011ce:	ec56                	sd	s5,24(sp)
    800011d0:	e85a                	sd	s6,16(sp)
    800011d2:	e45e                	sd	s7,8(sp)
    800011d4:	8a2a                	mv	s4,a0
    800011d6:	892e                	mv	s2,a1
    800011d8:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011da:	0632                	slli	a2,a2,0xc
    800011dc:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    800011e0:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800011e2:	6b05                	lui	s6,0x1
    800011e4:	0735ff63          	bgeu	a1,s3,80001262 <uvmunmap+0xa8>
    800011e8:	fc26                	sd	s1,56(sp)
    800011ea:	a0a9                	j	80001234 <uvmunmap+0x7a>
    800011ec:	fc26                	sd	s1,56(sp)
    800011ee:	f84a                	sd	s2,48(sp)
    800011f0:	f44e                	sd	s3,40(sp)
    800011f2:	f052                	sd	s4,32(sp)
    800011f4:	ec56                	sd	s5,24(sp)
    800011f6:	e85a                	sd	s6,16(sp)
    800011f8:	e45e                	sd	s7,8(sp)
    panic("uvmunmap: not aligned");
    800011fa:	00006517          	auipc	a0,0x6
    800011fe:	f2650513          	addi	a0,a0,-218 # 80007120 <etext+0x120>
    80001202:	d92ff0ef          	jal	80000794 <panic>
      panic("uvmunmap: walk");
    80001206:	00006517          	auipc	a0,0x6
    8000120a:	f3250513          	addi	a0,a0,-206 # 80007138 <etext+0x138>
    8000120e:	d86ff0ef          	jal	80000794 <panic>
      panic("uvmunmap: not mapped");
    80001212:	00006517          	auipc	a0,0x6
    80001216:	f3650513          	addi	a0,a0,-202 # 80007148 <etext+0x148>
    8000121a:	d7aff0ef          	jal	80000794 <panic>
      panic("uvmunmap: not a leaf");
    8000121e:	00006517          	auipc	a0,0x6
    80001222:	f4250513          	addi	a0,a0,-190 # 80007160 <etext+0x160>
    80001226:	d6eff0ef          	jal	80000794 <panic>
    if(do_free){
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
    8000122a:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000122e:	995a                	add	s2,s2,s6
    80001230:	03397863          	bgeu	s2,s3,80001260 <uvmunmap+0xa6>
    if((pte = walk(pagetable, a, 0)) == 0)
    80001234:	4601                	li	a2,0
    80001236:	85ca                	mv	a1,s2
    80001238:	8552                	mv	a0,s4
    8000123a:	d03ff0ef          	jal	80000f3c <walk>
    8000123e:	84aa                	mv	s1,a0
    80001240:	d179                	beqz	a0,80001206 <uvmunmap+0x4c>
    if((*pte & PTE_V) == 0)
    80001242:	6108                	ld	a0,0(a0)
    80001244:	00157793          	andi	a5,a0,1
    80001248:	d7e9                	beqz	a5,80001212 <uvmunmap+0x58>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000124a:	3ff57793          	andi	a5,a0,1023
    8000124e:	fd7788e3          	beq	a5,s7,8000121e <uvmunmap+0x64>
    if(do_free){
    80001252:	fc0a8ce3          	beqz	s5,8000122a <uvmunmap+0x70>
      uint64 pa = PTE2PA(*pte);
    80001256:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    80001258:	0532                	slli	a0,a0,0xc
    8000125a:	fe8ff0ef          	jal	80000a42 <kfree>
    8000125e:	b7f1                	j	8000122a <uvmunmap+0x70>
    80001260:	74e2                	ld	s1,56(sp)
    80001262:	7942                	ld	s2,48(sp)
    80001264:	79a2                	ld	s3,40(sp)
    80001266:	7a02                	ld	s4,32(sp)
    80001268:	6ae2                	ld	s5,24(sp)
    8000126a:	6b42                	ld	s6,16(sp)
    8000126c:	6ba2                	ld	s7,8(sp)
  }
}
    8000126e:	60a6                	ld	ra,72(sp)
    80001270:	6406                	ld	s0,64(sp)
    80001272:	6161                	addi	sp,sp,80
    80001274:	8082                	ret

0000000080001276 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001276:	1101                	addi	sp,sp,-32
    80001278:	ec06                	sd	ra,24(sp)
    8000127a:	e822                	sd	s0,16(sp)
    8000127c:	e426                	sd	s1,8(sp)
    8000127e:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001280:	8a5ff0ef          	jal	80000b24 <kalloc>
    80001284:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001286:	c509                	beqz	a0,80001290 <uvmcreate+0x1a>
    return 0;
  memset(pagetable, 0, PGSIZE);
    80001288:	6605                	lui	a2,0x1
    8000128a:	4581                	li	a1,0
    8000128c:	a3dff0ef          	jal	80000cc8 <memset>
  return pagetable;
}
    80001290:	8526                	mv	a0,s1
    80001292:	60e2                	ld	ra,24(sp)
    80001294:	6442                	ld	s0,16(sp)
    80001296:	64a2                	ld	s1,8(sp)
    80001298:	6105                	addi	sp,sp,32
    8000129a:	8082                	ret

000000008000129c <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    8000129c:	7179                	addi	sp,sp,-48
    8000129e:	f406                	sd	ra,40(sp)
    800012a0:	f022                	sd	s0,32(sp)
    800012a2:	ec26                	sd	s1,24(sp)
    800012a4:	e84a                	sd	s2,16(sp)
    800012a6:	e44e                	sd	s3,8(sp)
    800012a8:	e052                	sd	s4,0(sp)
    800012aa:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    800012ac:	6785                	lui	a5,0x1
    800012ae:	04f67063          	bgeu	a2,a5,800012ee <uvmfirst+0x52>
    800012b2:	8a2a                	mv	s4,a0
    800012b4:	89ae                	mv	s3,a1
    800012b6:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    800012b8:	86dff0ef          	jal	80000b24 <kalloc>
    800012bc:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    800012be:	6605                	lui	a2,0x1
    800012c0:	4581                	li	a1,0
    800012c2:	a07ff0ef          	jal	80000cc8 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    800012c6:	4779                	li	a4,30
    800012c8:	86ca                	mv	a3,s2
    800012ca:	6605                	lui	a2,0x1
    800012cc:	4581                	li	a1,0
    800012ce:	8552                	mv	a0,s4
    800012d0:	d45ff0ef          	jal	80001014 <mappages>
  memmove(mem, src, sz);
    800012d4:	8626                	mv	a2,s1
    800012d6:	85ce                	mv	a1,s3
    800012d8:	854a                	mv	a0,s2
    800012da:	a4bff0ef          	jal	80000d24 <memmove>
}
    800012de:	70a2                	ld	ra,40(sp)
    800012e0:	7402                	ld	s0,32(sp)
    800012e2:	64e2                	ld	s1,24(sp)
    800012e4:	6942                	ld	s2,16(sp)
    800012e6:	69a2                	ld	s3,8(sp)
    800012e8:	6a02                	ld	s4,0(sp)
    800012ea:	6145                	addi	sp,sp,48
    800012ec:	8082                	ret
    panic("uvmfirst: more than a page");
    800012ee:	00006517          	auipc	a0,0x6
    800012f2:	e8a50513          	addi	a0,a0,-374 # 80007178 <etext+0x178>
    800012f6:	c9eff0ef          	jal	80000794 <panic>

00000000800012fa <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800012fa:	1101                	addi	sp,sp,-32
    800012fc:	ec06                	sd	ra,24(sp)
    800012fe:	e822                	sd	s0,16(sp)
    80001300:	e426                	sd	s1,8(sp)
    80001302:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    80001304:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    80001306:	00b67d63          	bgeu	a2,a1,80001320 <uvmdealloc+0x26>
    8000130a:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    8000130c:	6785                	lui	a5,0x1
    8000130e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001310:	00f60733          	add	a4,a2,a5
    80001314:	76fd                	lui	a3,0xfffff
    80001316:	8f75                	and	a4,a4,a3
    80001318:	97ae                	add	a5,a5,a1
    8000131a:	8ff5                	and	a5,a5,a3
    8000131c:	00f76863          	bltu	a4,a5,8000132c <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    80001320:	8526                	mv	a0,s1
    80001322:	60e2                	ld	ra,24(sp)
    80001324:	6442                	ld	s0,16(sp)
    80001326:	64a2                	ld	s1,8(sp)
    80001328:	6105                	addi	sp,sp,32
    8000132a:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    8000132c:	8f99                	sub	a5,a5,a4
    8000132e:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    80001330:	4685                	li	a3,1
    80001332:	0007861b          	sext.w	a2,a5
    80001336:	85ba                	mv	a1,a4
    80001338:	e83ff0ef          	jal	800011ba <uvmunmap>
    8000133c:	b7d5                	j	80001320 <uvmdealloc+0x26>

000000008000133e <uvmalloc>:
  if(newsz < oldsz)
    8000133e:	08b66f63          	bltu	a2,a1,800013dc <uvmalloc+0x9e>
{
    80001342:	7139                	addi	sp,sp,-64
    80001344:	fc06                	sd	ra,56(sp)
    80001346:	f822                	sd	s0,48(sp)
    80001348:	ec4e                	sd	s3,24(sp)
    8000134a:	e852                	sd	s4,16(sp)
    8000134c:	e456                	sd	s5,8(sp)
    8000134e:	0080                	addi	s0,sp,64
    80001350:	8aaa                	mv	s5,a0
    80001352:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    80001354:	6785                	lui	a5,0x1
    80001356:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001358:	95be                	add	a1,a1,a5
    8000135a:	77fd                	lui	a5,0xfffff
    8000135c:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001360:	08c9f063          	bgeu	s3,a2,800013e0 <uvmalloc+0xa2>
    80001364:	f426                	sd	s1,40(sp)
    80001366:	f04a                	sd	s2,32(sp)
    80001368:	e05a                	sd	s6,0(sp)
    8000136a:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000136c:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001370:	fb4ff0ef          	jal	80000b24 <kalloc>
    80001374:	84aa                	mv	s1,a0
    if(mem == 0){
    80001376:	c515                	beqz	a0,800013a2 <uvmalloc+0x64>
    memset(mem, 0, PGSIZE);
    80001378:	6605                	lui	a2,0x1
    8000137a:	4581                	li	a1,0
    8000137c:	94dff0ef          	jal	80000cc8 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    80001380:	875a                	mv	a4,s6
    80001382:	86a6                	mv	a3,s1
    80001384:	6605                	lui	a2,0x1
    80001386:	85ca                	mv	a1,s2
    80001388:	8556                	mv	a0,s5
    8000138a:	c8bff0ef          	jal	80001014 <mappages>
    8000138e:	e915                	bnez	a0,800013c2 <uvmalloc+0x84>
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001390:	6785                	lui	a5,0x1
    80001392:	993e                	add	s2,s2,a5
    80001394:	fd496ee3          	bltu	s2,s4,80001370 <uvmalloc+0x32>
  return newsz;
    80001398:	8552                	mv	a0,s4
    8000139a:	74a2                	ld	s1,40(sp)
    8000139c:	7902                	ld	s2,32(sp)
    8000139e:	6b02                	ld	s6,0(sp)
    800013a0:	a811                	j	800013b4 <uvmalloc+0x76>
      uvmdealloc(pagetable, a, oldsz);
    800013a2:	864e                	mv	a2,s3
    800013a4:	85ca                	mv	a1,s2
    800013a6:	8556                	mv	a0,s5
    800013a8:	f53ff0ef          	jal	800012fa <uvmdealloc>
      return 0;
    800013ac:	4501                	li	a0,0
    800013ae:	74a2                	ld	s1,40(sp)
    800013b0:	7902                	ld	s2,32(sp)
    800013b2:	6b02                	ld	s6,0(sp)
}
    800013b4:	70e2                	ld	ra,56(sp)
    800013b6:	7442                	ld	s0,48(sp)
    800013b8:	69e2                	ld	s3,24(sp)
    800013ba:	6a42                	ld	s4,16(sp)
    800013bc:	6aa2                	ld	s5,8(sp)
    800013be:	6121                	addi	sp,sp,64
    800013c0:	8082                	ret
      kfree(mem);
    800013c2:	8526                	mv	a0,s1
    800013c4:	e7eff0ef          	jal	80000a42 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800013c8:	864e                	mv	a2,s3
    800013ca:	85ca                	mv	a1,s2
    800013cc:	8556                	mv	a0,s5
    800013ce:	f2dff0ef          	jal	800012fa <uvmdealloc>
      return 0;
    800013d2:	4501                	li	a0,0
    800013d4:	74a2                	ld	s1,40(sp)
    800013d6:	7902                	ld	s2,32(sp)
    800013d8:	6b02                	ld	s6,0(sp)
    800013da:	bfe9                	j	800013b4 <uvmalloc+0x76>
    return oldsz;
    800013dc:	852e                	mv	a0,a1
}
    800013de:	8082                	ret
  return newsz;
    800013e0:	8532                	mv	a0,a2
    800013e2:	bfc9                	j	800013b4 <uvmalloc+0x76>

00000000800013e4 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800013e4:	7179                	addi	sp,sp,-48
    800013e6:	f406                	sd	ra,40(sp)
    800013e8:	f022                	sd	s0,32(sp)
    800013ea:	ec26                	sd	s1,24(sp)
    800013ec:	e84a                	sd	s2,16(sp)
    800013ee:	e44e                	sd	s3,8(sp)
    800013f0:	e052                	sd	s4,0(sp)
    800013f2:	1800                	addi	s0,sp,48
    800013f4:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800013f6:	84aa                	mv	s1,a0
    800013f8:	6905                	lui	s2,0x1
    800013fa:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800013fc:	4985                	li	s3,1
    800013fe:	a819                	j	80001414 <freewalk+0x30>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    80001400:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    80001402:	00c79513          	slli	a0,a5,0xc
    80001406:	fdfff0ef          	jal	800013e4 <freewalk>
      pagetable[i] = 0;
    8000140a:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    8000140e:	04a1                	addi	s1,s1,8
    80001410:	01248f63          	beq	s1,s2,8000142e <freewalk+0x4a>
    pte_t pte = pagetable[i];
    80001414:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    80001416:	00f7f713          	andi	a4,a5,15
    8000141a:	ff3703e3          	beq	a4,s3,80001400 <freewalk+0x1c>
    } else if(pte & PTE_V){
    8000141e:	8b85                	andi	a5,a5,1
    80001420:	d7fd                	beqz	a5,8000140e <freewalk+0x2a>
      panic("freewalk: leaf");
    80001422:	00006517          	auipc	a0,0x6
    80001426:	d7650513          	addi	a0,a0,-650 # 80007198 <etext+0x198>
    8000142a:	b6aff0ef          	jal	80000794 <panic>
    }
  }
  kfree((void*)pagetable);
    8000142e:	8552                	mv	a0,s4
    80001430:	e12ff0ef          	jal	80000a42 <kfree>
}
    80001434:	70a2                	ld	ra,40(sp)
    80001436:	7402                	ld	s0,32(sp)
    80001438:	64e2                	ld	s1,24(sp)
    8000143a:	6942                	ld	s2,16(sp)
    8000143c:	69a2                	ld	s3,8(sp)
    8000143e:	6a02                	ld	s4,0(sp)
    80001440:	6145                	addi	sp,sp,48
    80001442:	8082                	ret

0000000080001444 <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    80001444:	1101                	addi	sp,sp,-32
    80001446:	ec06                	sd	ra,24(sp)
    80001448:	e822                	sd	s0,16(sp)
    8000144a:	e426                	sd	s1,8(sp)
    8000144c:	1000                	addi	s0,sp,32
    8000144e:	84aa                	mv	s1,a0
  if(sz > 0)
    80001450:	e989                	bnez	a1,80001462 <uvmfree+0x1e>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    80001452:	8526                	mv	a0,s1
    80001454:	f91ff0ef          	jal	800013e4 <freewalk>
}
    80001458:	60e2                	ld	ra,24(sp)
    8000145a:	6442                	ld	s0,16(sp)
    8000145c:	64a2                	ld	s1,8(sp)
    8000145e:	6105                	addi	sp,sp,32
    80001460:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001462:	6785                	lui	a5,0x1
    80001464:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001466:	95be                	add	a1,a1,a5
    80001468:	4685                	li	a3,1
    8000146a:	00c5d613          	srli	a2,a1,0xc
    8000146e:	4581                	li	a1,0
    80001470:	d4bff0ef          	jal	800011ba <uvmunmap>
    80001474:	bff9                	j	80001452 <uvmfree+0xe>

0000000080001476 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001476:	c65d                	beqz	a2,80001524 <uvmcopy+0xae>
{
    80001478:	715d                	addi	sp,sp,-80
    8000147a:	e486                	sd	ra,72(sp)
    8000147c:	e0a2                	sd	s0,64(sp)
    8000147e:	fc26                	sd	s1,56(sp)
    80001480:	f84a                	sd	s2,48(sp)
    80001482:	f44e                	sd	s3,40(sp)
    80001484:	f052                	sd	s4,32(sp)
    80001486:	ec56                	sd	s5,24(sp)
    80001488:	e85a                	sd	s6,16(sp)
    8000148a:	e45e                	sd	s7,8(sp)
    8000148c:	0880                	addi	s0,sp,80
    8000148e:	8b2a                	mv	s6,a0
    80001490:	8aae                	mv	s5,a1
    80001492:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001494:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001496:	4601                	li	a2,0
    80001498:	85ce                	mv	a1,s3
    8000149a:	855a                	mv	a0,s6
    8000149c:	aa1ff0ef          	jal	80000f3c <walk>
    800014a0:	c121                	beqz	a0,800014e0 <uvmcopy+0x6a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    800014a2:	6118                	ld	a4,0(a0)
    800014a4:	00177793          	andi	a5,a4,1
    800014a8:	c3b1                	beqz	a5,800014ec <uvmcopy+0x76>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800014aa:	00a75593          	srli	a1,a4,0xa
    800014ae:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800014b2:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800014b6:	e6eff0ef          	jal	80000b24 <kalloc>
    800014ba:	892a                	mv	s2,a0
    800014bc:	c129                	beqz	a0,800014fe <uvmcopy+0x88>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800014be:	6605                	lui	a2,0x1
    800014c0:	85de                	mv	a1,s7
    800014c2:	863ff0ef          	jal	80000d24 <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800014c6:	8726                	mv	a4,s1
    800014c8:	86ca                	mv	a3,s2
    800014ca:	6605                	lui	a2,0x1
    800014cc:	85ce                	mv	a1,s3
    800014ce:	8556                	mv	a0,s5
    800014d0:	b45ff0ef          	jal	80001014 <mappages>
    800014d4:	e115                	bnez	a0,800014f8 <uvmcopy+0x82>
  for(i = 0; i < sz; i += PGSIZE){
    800014d6:	6785                	lui	a5,0x1
    800014d8:	99be                	add	s3,s3,a5
    800014da:	fb49eee3          	bltu	s3,s4,80001496 <uvmcopy+0x20>
    800014de:	a805                	j	8000150e <uvmcopy+0x98>
      panic("uvmcopy: pte should exist");
    800014e0:	00006517          	auipc	a0,0x6
    800014e4:	cc850513          	addi	a0,a0,-824 # 800071a8 <etext+0x1a8>
    800014e8:	aacff0ef          	jal	80000794 <panic>
      panic("uvmcopy: page not present");
    800014ec:	00006517          	auipc	a0,0x6
    800014f0:	cdc50513          	addi	a0,a0,-804 # 800071c8 <etext+0x1c8>
    800014f4:	aa0ff0ef          	jal	80000794 <panic>
      kfree(mem);
    800014f8:	854a                	mv	a0,s2
    800014fa:	d48ff0ef          	jal	80000a42 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    800014fe:	4685                	li	a3,1
    80001500:	00c9d613          	srli	a2,s3,0xc
    80001504:	4581                	li	a1,0
    80001506:	8556                	mv	a0,s5
    80001508:	cb3ff0ef          	jal	800011ba <uvmunmap>
  return -1;
    8000150c:	557d                	li	a0,-1
}
    8000150e:	60a6                	ld	ra,72(sp)
    80001510:	6406                	ld	s0,64(sp)
    80001512:	74e2                	ld	s1,56(sp)
    80001514:	7942                	ld	s2,48(sp)
    80001516:	79a2                	ld	s3,40(sp)
    80001518:	7a02                	ld	s4,32(sp)
    8000151a:	6ae2                	ld	s5,24(sp)
    8000151c:	6b42                	ld	s6,16(sp)
    8000151e:	6ba2                	ld	s7,8(sp)
    80001520:	6161                	addi	sp,sp,80
    80001522:	8082                	ret
  return 0;
    80001524:	4501                	li	a0,0
}
    80001526:	8082                	ret

0000000080001528 <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    80001528:	1141                	addi	sp,sp,-16
    8000152a:	e406                	sd	ra,8(sp)
    8000152c:	e022                	sd	s0,0(sp)
    8000152e:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001530:	4601                	li	a2,0
    80001532:	a0bff0ef          	jal	80000f3c <walk>
  if(pte == 0)
    80001536:	c901                	beqz	a0,80001546 <uvmclear+0x1e>
    panic("uvmclear");
  *pte &= ~PTE_U;
    80001538:	611c                	ld	a5,0(a0)
    8000153a:	9bbd                	andi	a5,a5,-17
    8000153c:	e11c                	sd	a5,0(a0)
}
    8000153e:	60a2                	ld	ra,8(sp)
    80001540:	6402                	ld	s0,0(sp)
    80001542:	0141                	addi	sp,sp,16
    80001544:	8082                	ret
    panic("uvmclear");
    80001546:	00006517          	auipc	a0,0x6
    8000154a:	ca250513          	addi	a0,a0,-862 # 800071e8 <etext+0x1e8>
    8000154e:	a46ff0ef          	jal	80000794 <panic>

0000000080001552 <copyout>:
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;
  pte_t *pte;

  while(len > 0){
    80001552:	cad1                	beqz	a3,800015e6 <copyout+0x94>
{
    80001554:	711d                	addi	sp,sp,-96
    80001556:	ec86                	sd	ra,88(sp)
    80001558:	e8a2                	sd	s0,80(sp)
    8000155a:	e4a6                	sd	s1,72(sp)
    8000155c:	fc4e                	sd	s3,56(sp)
    8000155e:	f456                	sd	s5,40(sp)
    80001560:	f05a                	sd	s6,32(sp)
    80001562:	ec5e                	sd	s7,24(sp)
    80001564:	1080                	addi	s0,sp,96
    80001566:	8baa                	mv	s7,a0
    80001568:	8aae                	mv	s5,a1
    8000156a:	8b32                	mv	s6,a2
    8000156c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000156e:	74fd                	lui	s1,0xfffff
    80001570:	8ced                	and	s1,s1,a1
    if(va0 >= MAXVA)
    80001572:	57fd                	li	a5,-1
    80001574:	83e9                	srli	a5,a5,0x1a
    80001576:	0697ea63          	bltu	a5,s1,800015ea <copyout+0x98>
    8000157a:	e0ca                	sd	s2,64(sp)
    8000157c:	f852                	sd	s4,48(sp)
    8000157e:	e862                	sd	s8,16(sp)
    80001580:	e466                	sd	s9,8(sp)
    80001582:	e06a                	sd	s10,0(sp)
      return -1;
    pte = walk(pagetable, va0, 0);
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    80001584:	4cd5                	li	s9,21
    80001586:	6d05                	lui	s10,0x1
    if(va0 >= MAXVA)
    80001588:	8c3e                	mv	s8,a5
    8000158a:	a025                	j	800015b2 <copyout+0x60>
       (*pte & PTE_W) == 0)
      return -1;
    pa0 = PTE2PA(*pte);
    8000158c:	83a9                	srli	a5,a5,0xa
    8000158e:	07b2                	slli	a5,a5,0xc
    n = PGSIZE - (dstva - va0);
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001590:	409a8533          	sub	a0,s5,s1
    80001594:	0009061b          	sext.w	a2,s2
    80001598:	85da                	mv	a1,s6
    8000159a:	953e                	add	a0,a0,a5
    8000159c:	f88ff0ef          	jal	80000d24 <memmove>

    len -= n;
    800015a0:	412989b3          	sub	s3,s3,s2
    src += n;
    800015a4:	9b4a                	add	s6,s6,s2
  while(len > 0){
    800015a6:	02098963          	beqz	s3,800015d8 <copyout+0x86>
    if(va0 >= MAXVA)
    800015aa:	054c6263          	bltu	s8,s4,800015ee <copyout+0x9c>
    800015ae:	84d2                	mv	s1,s4
    800015b0:	8ad2                	mv	s5,s4
    pte = walk(pagetable, va0, 0);
    800015b2:	4601                	li	a2,0
    800015b4:	85a6                	mv	a1,s1
    800015b6:	855e                	mv	a0,s7
    800015b8:	985ff0ef          	jal	80000f3c <walk>
    if(pte == 0 || (*pte & PTE_V) == 0 || (*pte & PTE_U) == 0 ||
    800015bc:	c121                	beqz	a0,800015fc <copyout+0xaa>
    800015be:	611c                	ld	a5,0(a0)
    800015c0:	0157f713          	andi	a4,a5,21
    800015c4:	05971b63          	bne	a4,s9,8000161a <copyout+0xc8>
    n = PGSIZE - (dstva - va0);
    800015c8:	01a48a33          	add	s4,s1,s10
    800015cc:	415a0933          	sub	s2,s4,s5
    if(n > len)
    800015d0:	fb29fee3          	bgeu	s3,s2,8000158c <copyout+0x3a>
    800015d4:	894e                	mv	s2,s3
    800015d6:	bf5d                	j	8000158c <copyout+0x3a>
    dstva = va0 + PGSIZE;
  }
  return 0;
    800015d8:	4501                	li	a0,0
    800015da:	6906                	ld	s2,64(sp)
    800015dc:	7a42                	ld	s4,48(sp)
    800015de:	6c42                	ld	s8,16(sp)
    800015e0:	6ca2                	ld	s9,8(sp)
    800015e2:	6d02                	ld	s10,0(sp)
    800015e4:	a015                	j	80001608 <copyout+0xb6>
    800015e6:	4501                	li	a0,0
}
    800015e8:	8082                	ret
      return -1;
    800015ea:	557d                	li	a0,-1
    800015ec:	a831                	j	80001608 <copyout+0xb6>
    800015ee:	557d                	li	a0,-1
    800015f0:	6906                	ld	s2,64(sp)
    800015f2:	7a42                	ld	s4,48(sp)
    800015f4:	6c42                	ld	s8,16(sp)
    800015f6:	6ca2                	ld	s9,8(sp)
    800015f8:	6d02                	ld	s10,0(sp)
    800015fa:	a039                	j	80001608 <copyout+0xb6>
      return -1;
    800015fc:	557d                	li	a0,-1
    800015fe:	6906                	ld	s2,64(sp)
    80001600:	7a42                	ld	s4,48(sp)
    80001602:	6c42                	ld	s8,16(sp)
    80001604:	6ca2                	ld	s9,8(sp)
    80001606:	6d02                	ld	s10,0(sp)
}
    80001608:	60e6                	ld	ra,88(sp)
    8000160a:	6446                	ld	s0,80(sp)
    8000160c:	64a6                	ld	s1,72(sp)
    8000160e:	79e2                	ld	s3,56(sp)
    80001610:	7aa2                	ld	s5,40(sp)
    80001612:	7b02                	ld	s6,32(sp)
    80001614:	6be2                	ld	s7,24(sp)
    80001616:	6125                	addi	sp,sp,96
    80001618:	8082                	ret
      return -1;
    8000161a:	557d                	li	a0,-1
    8000161c:	6906                	ld	s2,64(sp)
    8000161e:	7a42                	ld	s4,48(sp)
    80001620:	6c42                	ld	s8,16(sp)
    80001622:	6ca2                	ld	s9,8(sp)
    80001624:	6d02                	ld	s10,0(sp)
    80001626:	b7cd                	j	80001608 <copyout+0xb6>

0000000080001628 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    80001628:	c6a5                	beqz	a3,80001690 <copyin+0x68>
{
    8000162a:	715d                	addi	sp,sp,-80
    8000162c:	e486                	sd	ra,72(sp)
    8000162e:	e0a2                	sd	s0,64(sp)
    80001630:	fc26                	sd	s1,56(sp)
    80001632:	f84a                	sd	s2,48(sp)
    80001634:	f44e                	sd	s3,40(sp)
    80001636:	f052                	sd	s4,32(sp)
    80001638:	ec56                	sd	s5,24(sp)
    8000163a:	e85a                	sd	s6,16(sp)
    8000163c:	e45e                	sd	s7,8(sp)
    8000163e:	e062                	sd	s8,0(sp)
    80001640:	0880                	addi	s0,sp,80
    80001642:	8b2a                	mv	s6,a0
    80001644:	8a2e                	mv	s4,a1
    80001646:	8c32                	mv	s8,a2
    80001648:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000164a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000164c:	6a85                	lui	s5,0x1
    8000164e:	a00d                	j	80001670 <copyin+0x48>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001650:	018505b3          	add	a1,a0,s8
    80001654:	0004861b          	sext.w	a2,s1
    80001658:	412585b3          	sub	a1,a1,s2
    8000165c:	8552                	mv	a0,s4
    8000165e:	ec6ff0ef          	jal	80000d24 <memmove>

    len -= n;
    80001662:	409989b3          	sub	s3,s3,s1
    dst += n;
    80001666:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    80001668:	01590c33          	add	s8,s2,s5
  while(len > 0){
    8000166c:	02098063          	beqz	s3,8000168c <copyin+0x64>
    va0 = PGROUNDDOWN(srcva);
    80001670:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001674:	85ca                	mv	a1,s2
    80001676:	855a                	mv	a0,s6
    80001678:	95fff0ef          	jal	80000fd6 <walkaddr>
    if(pa0 == 0)
    8000167c:	cd01                	beqz	a0,80001694 <copyin+0x6c>
    n = PGSIZE - (srcva - va0);
    8000167e:	418904b3          	sub	s1,s2,s8
    80001682:	94d6                	add	s1,s1,s5
    if(n > len)
    80001684:	fc99f6e3          	bgeu	s3,s1,80001650 <copyin+0x28>
    80001688:	84ce                	mv	s1,s3
    8000168a:	b7d9                	j	80001650 <copyin+0x28>
  }
  return 0;
    8000168c:	4501                	li	a0,0
    8000168e:	a021                	j	80001696 <copyin+0x6e>
    80001690:	4501                	li	a0,0
}
    80001692:	8082                	ret
      return -1;
    80001694:	557d                	li	a0,-1
}
    80001696:	60a6                	ld	ra,72(sp)
    80001698:	6406                	ld	s0,64(sp)
    8000169a:	74e2                	ld	s1,56(sp)
    8000169c:	7942                	ld	s2,48(sp)
    8000169e:	79a2                	ld	s3,40(sp)
    800016a0:	7a02                	ld	s4,32(sp)
    800016a2:	6ae2                	ld	s5,24(sp)
    800016a4:	6b42                	ld	s6,16(sp)
    800016a6:	6ba2                	ld	s7,8(sp)
    800016a8:	6c02                	ld	s8,0(sp)
    800016aa:	6161                	addi	sp,sp,80
    800016ac:	8082                	ret

00000000800016ae <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    800016ae:	c6dd                	beqz	a3,8000175c <copyinstr+0xae>
{
    800016b0:	715d                	addi	sp,sp,-80
    800016b2:	e486                	sd	ra,72(sp)
    800016b4:	e0a2                	sd	s0,64(sp)
    800016b6:	fc26                	sd	s1,56(sp)
    800016b8:	f84a                	sd	s2,48(sp)
    800016ba:	f44e                	sd	s3,40(sp)
    800016bc:	f052                	sd	s4,32(sp)
    800016be:	ec56                	sd	s5,24(sp)
    800016c0:	e85a                	sd	s6,16(sp)
    800016c2:	e45e                	sd	s7,8(sp)
    800016c4:	0880                	addi	s0,sp,80
    800016c6:	8a2a                	mv	s4,a0
    800016c8:	8b2e                	mv	s6,a1
    800016ca:	8bb2                	mv	s7,a2
    800016cc:	8936                	mv	s2,a3
    va0 = PGROUNDDOWN(srcva);
    800016ce:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800016d0:	6985                	lui	s3,0x1
    800016d2:	a825                	j	8000170a <copyinstr+0x5c>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800016d4:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800016d8:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800016da:	37fd                	addiw	a5,a5,-1
    800016dc:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800016e0:	60a6                	ld	ra,72(sp)
    800016e2:	6406                	ld	s0,64(sp)
    800016e4:	74e2                	ld	s1,56(sp)
    800016e6:	7942                	ld	s2,48(sp)
    800016e8:	79a2                	ld	s3,40(sp)
    800016ea:	7a02                	ld	s4,32(sp)
    800016ec:	6ae2                	ld	s5,24(sp)
    800016ee:	6b42                	ld	s6,16(sp)
    800016f0:	6ba2                	ld	s7,8(sp)
    800016f2:	6161                	addi	sp,sp,80
    800016f4:	8082                	ret
    800016f6:	fff90713          	addi	a4,s2,-1 # fff <_entry-0x7ffff001>
    800016fa:	9742                	add	a4,a4,a6
      --max;
    800016fc:	40b70933          	sub	s2,a4,a1
    srcva = va0 + PGSIZE;
    80001700:	01348bb3          	add	s7,s1,s3
  while(got_null == 0 && max > 0){
    80001704:	04e58463          	beq	a1,a4,8000174c <copyinstr+0x9e>
{
    80001708:	8b3e                	mv	s6,a5
    va0 = PGROUNDDOWN(srcva);
    8000170a:	015bf4b3          	and	s1,s7,s5
    pa0 = walkaddr(pagetable, va0);
    8000170e:	85a6                	mv	a1,s1
    80001710:	8552                	mv	a0,s4
    80001712:	8c5ff0ef          	jal	80000fd6 <walkaddr>
    if(pa0 == 0)
    80001716:	cd0d                	beqz	a0,80001750 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    80001718:	417486b3          	sub	a3,s1,s7
    8000171c:	96ce                	add	a3,a3,s3
    if(n > max)
    8000171e:	00d97363          	bgeu	s2,a3,80001724 <copyinstr+0x76>
    80001722:	86ca                	mv	a3,s2
    char *p = (char *) (pa0 + (srcva - va0));
    80001724:	955e                	add	a0,a0,s7
    80001726:	8d05                	sub	a0,a0,s1
    while(n > 0){
    80001728:	c695                	beqz	a3,80001754 <copyinstr+0xa6>
    8000172a:	87da                	mv	a5,s6
    8000172c:	885a                	mv	a6,s6
      if(*p == '\0'){
    8000172e:	41650633          	sub	a2,a0,s6
    while(n > 0){
    80001732:	96da                	add	a3,a3,s6
    80001734:	85be                	mv	a1,a5
      if(*p == '\0'){
    80001736:	00f60733          	add	a4,a2,a5
    8000173a:	00074703          	lbu	a4,0(a4)
    8000173e:	db59                	beqz	a4,800016d4 <copyinstr+0x26>
        *dst = *p;
    80001740:	00e78023          	sb	a4,0(a5)
      dst++;
    80001744:	0785                	addi	a5,a5,1
    while(n > 0){
    80001746:	fed797e3          	bne	a5,a3,80001734 <copyinstr+0x86>
    8000174a:	b775                	j	800016f6 <copyinstr+0x48>
    8000174c:	4781                	li	a5,0
    8000174e:	b771                	j	800016da <copyinstr+0x2c>
      return -1;
    80001750:	557d                	li	a0,-1
    80001752:	b779                	j	800016e0 <copyinstr+0x32>
    srcva = va0 + PGSIZE;
    80001754:	6b85                	lui	s7,0x1
    80001756:	9ba6                	add	s7,s7,s1
    80001758:	87da                	mv	a5,s6
    8000175a:	b77d                	j	80001708 <copyinstr+0x5a>
  int got_null = 0;
    8000175c:	4781                	li	a5,0
  if(got_null){
    8000175e:	37fd                	addiw	a5,a5,-1
    80001760:	0007851b          	sext.w	a0,a5
}
    80001764:	8082                	ret

0000000080001766 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001766:	7139                	addi	sp,sp,-64
    80001768:	fc06                	sd	ra,56(sp)
    8000176a:	f822                	sd	s0,48(sp)
    8000176c:	f426                	sd	s1,40(sp)
    8000176e:	f04a                	sd	s2,32(sp)
    80001770:	ec4e                	sd	s3,24(sp)
    80001772:	e852                	sd	s4,16(sp)
    80001774:	e456                	sd	s5,8(sp)
    80001776:	e05a                	sd	s6,0(sp)
    80001778:	0080                	addi	s0,sp,64
    8000177a:	8a2a                	mv	s4,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000177c:	00011497          	auipc	s1,0x11
    80001780:	05448493          	addi	s1,s1,84 # 800127d0 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001784:	8b26                	mv	s6,s1
    80001786:	faaab937          	lui	s2,0xfaaab
    8000178a:	aab90913          	addi	s2,s2,-1365 # fffffffffaaaaaab <end+0xffffffff7aa86efb>
    8000178e:	0932                	slli	s2,s2,0xc
    80001790:	aab90913          	addi	s2,s2,-1365
    80001794:	0932                	slli	s2,s2,0xc
    80001796:	aab90913          	addi	s2,s2,-1365
    8000179a:	0932                	slli	s2,s2,0xc
    8000179c:	aab90913          	addi	s2,s2,-1365
    800017a0:	040009b7          	lui	s3,0x4000
    800017a4:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    800017a6:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    800017a8:	00017a97          	auipc	s5,0x17
    800017ac:	028a8a93          	addi	s5,s5,40 # 800187d0 <tickslock>
    char *pa = kalloc();
    800017b0:	b74ff0ef          	jal	80000b24 <kalloc>
    800017b4:	862a                	mv	a2,a0
    if(pa == 0)
    800017b6:	cd15                	beqz	a0,800017f2 <proc_mapstacks+0x8c>
    uint64 va = KSTACK((int) (p - proc));
    800017b8:	416485b3          	sub	a1,s1,s6
    800017bc:	859d                	srai	a1,a1,0x7
    800017be:	032585b3          	mul	a1,a1,s2
    800017c2:	2585                	addiw	a1,a1,1
    800017c4:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    800017c8:	4719                	li	a4,6
    800017ca:	6685                	lui	a3,0x1
    800017cc:	40b985b3          	sub	a1,s3,a1
    800017d0:	8552                	mv	a0,s4
    800017d2:	8f3ff0ef          	jal	800010c4 <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800017d6:	18048493          	addi	s1,s1,384
    800017da:	fd549be3          	bne	s1,s5,800017b0 <proc_mapstacks+0x4a>
  }
}
    800017de:	70e2                	ld	ra,56(sp)
    800017e0:	7442                	ld	s0,48(sp)
    800017e2:	74a2                	ld	s1,40(sp)
    800017e4:	7902                	ld	s2,32(sp)
    800017e6:	69e2                	ld	s3,24(sp)
    800017e8:	6a42                	ld	s4,16(sp)
    800017ea:	6aa2                	ld	s5,8(sp)
    800017ec:	6b02                	ld	s6,0(sp)
    800017ee:	6121                	addi	sp,sp,64
    800017f0:	8082                	ret
      panic("kalloc");
    800017f2:	00006517          	auipc	a0,0x6
    800017f6:	a0650513          	addi	a0,a0,-1530 # 800071f8 <etext+0x1f8>
    800017fa:	f9bfe0ef          	jal	80000794 <panic>

00000000800017fe <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800017fe:	7139                	addi	sp,sp,-64
    80001800:	fc06                	sd	ra,56(sp)
    80001802:	f822                	sd	s0,48(sp)
    80001804:	f426                	sd	s1,40(sp)
    80001806:	f04a                	sd	s2,32(sp)
    80001808:	ec4e                	sd	s3,24(sp)
    8000180a:	e852                	sd	s4,16(sp)
    8000180c:	e456                	sd	s5,8(sp)
    8000180e:	e05a                	sd	s6,0(sp)
    80001810:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    80001812:	00006597          	auipc	a1,0x6
    80001816:	9ee58593          	addi	a1,a1,-1554 # 80007200 <etext+0x200>
    8000181a:	00011517          	auipc	a0,0x11
    8000181e:	b8650513          	addi	a0,a0,-1146 # 800123a0 <pid_lock>
    80001822:	b52ff0ef          	jal	80000b74 <initlock>
  initlock(&wait_lock, "wait_lock");
    80001826:	00006597          	auipc	a1,0x6
    8000182a:	9e258593          	addi	a1,a1,-1566 # 80007208 <etext+0x208>
    8000182e:	00011517          	auipc	a0,0x11
    80001832:	b8a50513          	addi	a0,a0,-1142 # 800123b8 <wait_lock>
    80001836:	b3eff0ef          	jal	80000b74 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000183a:	00011497          	auipc	s1,0x11
    8000183e:	f9648493          	addi	s1,s1,-106 # 800127d0 <proc>
      initlock(&p->lock, "proc");
    80001842:	00006b17          	auipc	s6,0x6
    80001846:	9d6b0b13          	addi	s6,s6,-1578 # 80007218 <etext+0x218>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    8000184a:	8aa6                	mv	s5,s1
    8000184c:	faaab937          	lui	s2,0xfaaab
    80001850:	aab90913          	addi	s2,s2,-1365 # fffffffffaaaaaab <end+0xffffffff7aa86efb>
    80001854:	0932                	slli	s2,s2,0xc
    80001856:	aab90913          	addi	s2,s2,-1365
    8000185a:	0932                	slli	s2,s2,0xc
    8000185c:	aab90913          	addi	s2,s2,-1365
    80001860:	0932                	slli	s2,s2,0xc
    80001862:	aab90913          	addi	s2,s2,-1365
    80001866:	040009b7          	lui	s3,0x4000
    8000186a:	19fd                	addi	s3,s3,-1 # 3ffffff <_entry-0x7c000001>
    8000186c:	09b2                	slli	s3,s3,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    8000186e:	00017a17          	auipc	s4,0x17
    80001872:	f62a0a13          	addi	s4,s4,-158 # 800187d0 <tickslock>
      initlock(&p->lock, "proc");
    80001876:	85da                	mv	a1,s6
    80001878:	8526                	mv	a0,s1
    8000187a:	afaff0ef          	jal	80000b74 <initlock>
      p->state = UNUSED;
    8000187e:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    80001882:	415487b3          	sub	a5,s1,s5
    80001886:	879d                	srai	a5,a5,0x7
    80001888:	032787b3          	mul	a5,a5,s2
    8000188c:	2785                	addiw	a5,a5,1
    8000188e:	00d7979b          	slliw	a5,a5,0xd
    80001892:	40f987b3          	sub	a5,s3,a5
    80001896:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001898:	18048493          	addi	s1,s1,384
    8000189c:	fd449de3          	bne	s1,s4,80001876 <procinit+0x78>
  }
}
    800018a0:	70e2                	ld	ra,56(sp)
    800018a2:	7442                	ld	s0,48(sp)
    800018a4:	74a2                	ld	s1,40(sp)
    800018a6:	7902                	ld	s2,32(sp)
    800018a8:	69e2                	ld	s3,24(sp)
    800018aa:	6a42                	ld	s4,16(sp)
    800018ac:	6aa2                	ld	s5,8(sp)
    800018ae:	6b02                	ld	s6,0(sp)
    800018b0:	6121                	addi	sp,sp,64
    800018b2:	8082                	ret

00000000800018b4 <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    800018b4:	1141                	addi	sp,sp,-16
    800018b6:	e422                	sd	s0,8(sp)
    800018b8:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    800018ba:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    800018bc:	2501                	sext.w	a0,a0
    800018be:	6422                	ld	s0,8(sp)
    800018c0:	0141                	addi	sp,sp,16
    800018c2:	8082                	ret

00000000800018c4 <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    800018c4:	1141                	addi	sp,sp,-16
    800018c6:	e422                	sd	s0,8(sp)
    800018c8:	0800                	addi	s0,sp,16
    800018ca:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    800018cc:	2781                	sext.w	a5,a5
    800018ce:	079e                	slli	a5,a5,0x7
  return c;
}
    800018d0:	00011517          	auipc	a0,0x11
    800018d4:	b0050513          	addi	a0,a0,-1280 # 800123d0 <cpus>
    800018d8:	953e                	add	a0,a0,a5
    800018da:	6422                	ld	s0,8(sp)
    800018dc:	0141                	addi	sp,sp,16
    800018de:	8082                	ret

00000000800018e0 <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    800018e0:	1101                	addi	sp,sp,-32
    800018e2:	ec06                	sd	ra,24(sp)
    800018e4:	e822                	sd	s0,16(sp)
    800018e6:	e426                	sd	s1,8(sp)
    800018e8:	1000                	addi	s0,sp,32
  push_off();
    800018ea:	acaff0ef          	jal	80000bb4 <push_off>
    800018ee:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    800018f0:	2781                	sext.w	a5,a5
    800018f2:	079e                	slli	a5,a5,0x7
    800018f4:	00011717          	auipc	a4,0x11
    800018f8:	aac70713          	addi	a4,a4,-1364 # 800123a0 <pid_lock>
    800018fc:	97ba                	add	a5,a5,a4
    800018fe:	7b84                	ld	s1,48(a5)
  pop_off();
    80001900:	b38ff0ef          	jal	80000c38 <pop_off>
  return p;
}
    80001904:	8526                	mv	a0,s1
    80001906:	60e2                	ld	ra,24(sp)
    80001908:	6442                	ld	s0,16(sp)
    8000190a:	64a2                	ld	s1,8(sp)
    8000190c:	6105                	addi	sp,sp,32
    8000190e:	8082                	ret

0000000080001910 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001910:	1141                	addi	sp,sp,-16
    80001912:	e406                	sd	ra,8(sp)
    80001914:	e022                	sd	s0,0(sp)
    80001916:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001918:	fc9ff0ef          	jal	800018e0 <myproc>
    8000191c:	b70ff0ef          	jal	80000c8c <release>

  if (first) {
    80001920:	00009797          	auipc	a5,0x9
    80001924:	8b07a783          	lw	a5,-1872(a5) # 8000a1d0 <first.1>
    80001928:	e799                	bnez	a5,80001936 <forkret+0x26>
    first = 0;
    // ensure other cores see first=0.
    __sync_synchronize();
  }

  usertrapret();
    8000192a:	33d000ef          	jal	80002466 <usertrapret>
}
    8000192e:	60a2                	ld	ra,8(sp)
    80001930:	6402                	ld	s0,0(sp)
    80001932:	0141                	addi	sp,sp,16
    80001934:	8082                	ret
    fsinit(ROOTDEV);
    80001936:	4505                	li	a0,1
    80001938:	728010ef          	jal	80003060 <fsinit>
    first = 0;
    8000193c:	00009797          	auipc	a5,0x9
    80001940:	8807aa23          	sw	zero,-1900(a5) # 8000a1d0 <first.1>
    __sync_synchronize();
    80001944:	0330000f          	fence	rw,rw
    80001948:	b7cd                	j	8000192a <forkret+0x1a>

000000008000194a <allocpid>:
{
    8000194a:	1101                	addi	sp,sp,-32
    8000194c:	ec06                	sd	ra,24(sp)
    8000194e:	e822                	sd	s0,16(sp)
    80001950:	e426                	sd	s1,8(sp)
    80001952:	e04a                	sd	s2,0(sp)
    80001954:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001956:	00011917          	auipc	s2,0x11
    8000195a:	a4a90913          	addi	s2,s2,-1462 # 800123a0 <pid_lock>
    8000195e:	854a                	mv	a0,s2
    80001960:	a94ff0ef          	jal	80000bf4 <acquire>
  pid = nextpid;
    80001964:	00009797          	auipc	a5,0x9
    80001968:	87078793          	addi	a5,a5,-1936 # 8000a1d4 <nextpid>
    8000196c:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    8000196e:	0014871b          	addiw	a4,s1,1
    80001972:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001974:	854a                	mv	a0,s2
    80001976:	b16ff0ef          	jal	80000c8c <release>
}
    8000197a:	8526                	mv	a0,s1
    8000197c:	60e2                	ld	ra,24(sp)
    8000197e:	6442                	ld	s0,16(sp)
    80001980:	64a2                	ld	s1,8(sp)
    80001982:	6902                	ld	s2,0(sp)
    80001984:	6105                	addi	sp,sp,32
    80001986:	8082                	ret

0000000080001988 <proc_pagetable>:
{
    80001988:	1101                	addi	sp,sp,-32
    8000198a:	ec06                	sd	ra,24(sp)
    8000198c:	e822                	sd	s0,16(sp)
    8000198e:	e426                	sd	s1,8(sp)
    80001990:	e04a                	sd	s2,0(sp)
    80001992:	1000                	addi	s0,sp,32
    80001994:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001996:	8e1ff0ef          	jal	80001276 <uvmcreate>
    8000199a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000199c:	cd05                	beqz	a0,800019d4 <proc_pagetable+0x4c>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    8000199e:	4729                	li	a4,10
    800019a0:	00004697          	auipc	a3,0x4
    800019a4:	66068693          	addi	a3,a3,1632 # 80006000 <_trampoline>
    800019a8:	6605                	lui	a2,0x1
    800019aa:	040005b7          	lui	a1,0x4000
    800019ae:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019b0:	05b2                	slli	a1,a1,0xc
    800019b2:	e62ff0ef          	jal	80001014 <mappages>
    800019b6:	02054663          	bltz	a0,800019e2 <proc_pagetable+0x5a>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    800019ba:	4719                	li	a4,6
    800019bc:	05893683          	ld	a3,88(s2)
    800019c0:	6605                	lui	a2,0x1
    800019c2:	020005b7          	lui	a1,0x2000
    800019c6:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    800019c8:	05b6                	slli	a1,a1,0xd
    800019ca:	8526                	mv	a0,s1
    800019cc:	e48ff0ef          	jal	80001014 <mappages>
    800019d0:	00054f63          	bltz	a0,800019ee <proc_pagetable+0x66>
}
    800019d4:	8526                	mv	a0,s1
    800019d6:	60e2                	ld	ra,24(sp)
    800019d8:	6442                	ld	s0,16(sp)
    800019da:	64a2                	ld	s1,8(sp)
    800019dc:	6902                	ld	s2,0(sp)
    800019de:	6105                	addi	sp,sp,32
    800019e0:	8082                	ret
    uvmfree(pagetable, 0);
    800019e2:	4581                	li	a1,0
    800019e4:	8526                	mv	a0,s1
    800019e6:	a5fff0ef          	jal	80001444 <uvmfree>
    return 0;
    800019ea:	4481                	li	s1,0
    800019ec:	b7e5                	j	800019d4 <proc_pagetable+0x4c>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    800019ee:	4681                	li	a3,0
    800019f0:	4605                	li	a2,1
    800019f2:	040005b7          	lui	a1,0x4000
    800019f6:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    800019f8:	05b2                	slli	a1,a1,0xc
    800019fa:	8526                	mv	a0,s1
    800019fc:	fbeff0ef          	jal	800011ba <uvmunmap>
    uvmfree(pagetable, 0);
    80001a00:	4581                	li	a1,0
    80001a02:	8526                	mv	a0,s1
    80001a04:	a41ff0ef          	jal	80001444 <uvmfree>
    return 0;
    80001a08:	4481                	li	s1,0
    80001a0a:	b7e9                	j	800019d4 <proc_pagetable+0x4c>

0000000080001a0c <proc_freepagetable>:
{
    80001a0c:	1101                	addi	sp,sp,-32
    80001a0e:	ec06                	sd	ra,24(sp)
    80001a10:	e822                	sd	s0,16(sp)
    80001a12:	e426                	sd	s1,8(sp)
    80001a14:	e04a                	sd	s2,0(sp)
    80001a16:	1000                	addi	s0,sp,32
    80001a18:	84aa                	mv	s1,a0
    80001a1a:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001a1c:	4681                	li	a3,0
    80001a1e:	4605                	li	a2,1
    80001a20:	040005b7          	lui	a1,0x4000
    80001a24:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001a26:	05b2                	slli	a1,a1,0xc
    80001a28:	f92ff0ef          	jal	800011ba <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001a2c:	4681                	li	a3,0
    80001a2e:	4605                	li	a2,1
    80001a30:	020005b7          	lui	a1,0x2000
    80001a34:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001a36:	05b6                	slli	a1,a1,0xd
    80001a38:	8526                	mv	a0,s1
    80001a3a:	f80ff0ef          	jal	800011ba <uvmunmap>
  uvmfree(pagetable, sz);
    80001a3e:	85ca                	mv	a1,s2
    80001a40:	8526                	mv	a0,s1
    80001a42:	a03ff0ef          	jal	80001444 <uvmfree>
}
    80001a46:	60e2                	ld	ra,24(sp)
    80001a48:	6442                	ld	s0,16(sp)
    80001a4a:	64a2                	ld	s1,8(sp)
    80001a4c:	6902                	ld	s2,0(sp)
    80001a4e:	6105                	addi	sp,sp,32
    80001a50:	8082                	ret

0000000080001a52 <freeproc>:
{
    80001a52:	1101                	addi	sp,sp,-32
    80001a54:	ec06                	sd	ra,24(sp)
    80001a56:	e822                	sd	s0,16(sp)
    80001a58:	e426                	sd	s1,8(sp)
    80001a5a:	1000                	addi	s0,sp,32
    80001a5c:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001a5e:	6d28                	ld	a0,88(a0)
    80001a60:	c119                	beqz	a0,80001a66 <freeproc+0x14>
    kfree((void*)p->trapframe);
    80001a62:	fe1fe0ef          	jal	80000a42 <kfree>
  p->trapframe = 0;
    80001a66:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001a6a:	68a8                	ld	a0,80(s1)
    80001a6c:	c501                	beqz	a0,80001a74 <freeproc+0x22>
    proc_freepagetable(p->pagetable, p->sz);
    80001a6e:	64ac                	ld	a1,72(s1)
    80001a70:	f9dff0ef          	jal	80001a0c <proc_freepagetable>
  p->pagetable = 0;
    80001a74:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001a78:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001a7c:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001a80:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001a84:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001a88:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001a8c:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001a90:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001a94:	0004ac23          	sw	zero,24(s1)
}
    80001a98:	60e2                	ld	ra,24(sp)
    80001a9a:	6442                	ld	s0,16(sp)
    80001a9c:	64a2                	ld	s1,8(sp)
    80001a9e:	6105                	addi	sp,sp,32
    80001aa0:	8082                	ret

0000000080001aa2 <allocproc>:
{
    80001aa2:	1101                	addi	sp,sp,-32
    80001aa4:	ec06                	sd	ra,24(sp)
    80001aa6:	e822                	sd	s0,16(sp)
    80001aa8:	e426                	sd	s1,8(sp)
    80001aaa:	e04a                	sd	s2,0(sp)
    80001aac:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001aae:	00011497          	auipc	s1,0x11
    80001ab2:	d2248493          	addi	s1,s1,-734 # 800127d0 <proc>
    80001ab6:	00017917          	auipc	s2,0x17
    80001aba:	d1a90913          	addi	s2,s2,-742 # 800187d0 <tickslock>
    acquire(&p->lock);
    80001abe:	8526                	mv	a0,s1
    80001ac0:	934ff0ef          	jal	80000bf4 <acquire>
    if(p->state == UNUSED) {
    80001ac4:	4c9c                	lw	a5,24(s1)
    80001ac6:	cb91                	beqz	a5,80001ada <allocproc+0x38>
      release(&p->lock);
    80001ac8:	8526                	mv	a0,s1
    80001aca:	9c2ff0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001ace:	18048493          	addi	s1,s1,384
    80001ad2:	ff2496e3          	bne	s1,s2,80001abe <allocproc+0x1c>
  return 0;
    80001ad6:	4481                	li	s1,0
    80001ad8:	a889                	j	80001b2a <allocproc+0x88>
  p->pid = allocpid();
    80001ada:	e71ff0ef          	jal	8000194a <allocpid>
    80001ade:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001ae0:	4785                	li	a5,1
    80001ae2:	cc9c                	sw	a5,24(s1)
  p->tickets = DEFAULT_TICKETS;
    80001ae4:	06400793          	li	a5,100
    80001ae8:	16f4a423          	sw	a5,360(s1)
    p->stride = STRIDE_CONSTANT / p->tickets;
    80001aec:	16f4b823          	sd	a5,368(s1)
  p->pass = 0;
    80001af0:	1604bc23          	sd	zero,376(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001af4:	830ff0ef          	jal	80000b24 <kalloc>
    80001af8:	892a                	mv	s2,a0
    80001afa:	eca8                	sd	a0,88(s1)
    80001afc:	cd15                	beqz	a0,80001b38 <allocproc+0x96>
  p->pagetable = proc_pagetable(p);
    80001afe:	8526                	mv	a0,s1
    80001b00:	e89ff0ef          	jal	80001988 <proc_pagetable>
    80001b04:	892a                	mv	s2,a0
    80001b06:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001b08:	c121                	beqz	a0,80001b48 <allocproc+0xa6>
  memset(&p->context, 0, sizeof(p->context));
    80001b0a:	07000613          	li	a2,112
    80001b0e:	4581                	li	a1,0
    80001b10:	06048513          	addi	a0,s1,96
    80001b14:	9b4ff0ef          	jal	80000cc8 <memset>
  p->context.ra = (uint64)forkret;
    80001b18:	00000797          	auipc	a5,0x0
    80001b1c:	df878793          	addi	a5,a5,-520 # 80001910 <forkret>
    80001b20:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001b22:	60bc                	ld	a5,64(s1)
    80001b24:	6705                	lui	a4,0x1
    80001b26:	97ba                	add	a5,a5,a4
    80001b28:	f4bc                	sd	a5,104(s1)
}
    80001b2a:	8526                	mv	a0,s1
    80001b2c:	60e2                	ld	ra,24(sp)
    80001b2e:	6442                	ld	s0,16(sp)
    80001b30:	64a2                	ld	s1,8(sp)
    80001b32:	6902                	ld	s2,0(sp)
    80001b34:	6105                	addi	sp,sp,32
    80001b36:	8082                	ret
    freeproc(p);
    80001b38:	8526                	mv	a0,s1
    80001b3a:	f19ff0ef          	jal	80001a52 <freeproc>
    release(&p->lock);
    80001b3e:	8526                	mv	a0,s1
    80001b40:	94cff0ef          	jal	80000c8c <release>
    return 0;
    80001b44:	84ca                	mv	s1,s2
    80001b46:	b7d5                	j	80001b2a <allocproc+0x88>
    freeproc(p);
    80001b48:	8526                	mv	a0,s1
    80001b4a:	f09ff0ef          	jal	80001a52 <freeproc>
    release(&p->lock);
    80001b4e:	8526                	mv	a0,s1
    80001b50:	93cff0ef          	jal	80000c8c <release>
    return 0;
    80001b54:	84ca                	mv	s1,s2
    80001b56:	bfd1                	j	80001b2a <allocproc+0x88>

0000000080001b58 <userinit>:
{
    80001b58:	1101                	addi	sp,sp,-32
    80001b5a:	ec06                	sd	ra,24(sp)
    80001b5c:	e822                	sd	s0,16(sp)
    80001b5e:	e426                	sd	s1,8(sp)
    80001b60:	1000                	addi	s0,sp,32
  p = allocproc();
    80001b62:	f41ff0ef          	jal	80001aa2 <allocproc>
    80001b66:	84aa                	mv	s1,a0
  initproc = p;
    80001b68:	00008797          	auipc	a5,0x8
    80001b6c:	70a7b023          	sd	a0,1792(a5) # 8000a268 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001b70:	03400613          	li	a2,52
    80001b74:	00008597          	auipc	a1,0x8
    80001b78:	66c58593          	addi	a1,a1,1644 # 8000a1e0 <initcode>
    80001b7c:	6928                	ld	a0,80(a0)
    80001b7e:	f1eff0ef          	jal	8000129c <uvmfirst>
  p->sz = PGSIZE;
    80001b82:	6785                	lui	a5,0x1
    80001b84:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001b86:	6cb8                	ld	a4,88(s1)
    80001b88:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001b8c:	6cb8                	ld	a4,88(s1)
    80001b8e:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001b90:	4641                	li	a2,16
    80001b92:	00005597          	auipc	a1,0x5
    80001b96:	68e58593          	addi	a1,a1,1678 # 80007220 <etext+0x220>
    80001b9a:	15848513          	addi	a0,s1,344
    80001b9e:	a68ff0ef          	jal	80000e06 <safestrcpy>
  p->cwd = namei("/");
    80001ba2:	00005517          	auipc	a0,0x5
    80001ba6:	68e50513          	addi	a0,a0,1678 # 80007230 <etext+0x230>
    80001baa:	5c5010ef          	jal	8000396e <namei>
    80001bae:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001bb2:	478d                	li	a5,3
    80001bb4:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001bb6:	8526                	mv	a0,s1
    80001bb8:	8d4ff0ef          	jal	80000c8c <release>
}
    80001bbc:	60e2                	ld	ra,24(sp)
    80001bbe:	6442                	ld	s0,16(sp)
    80001bc0:	64a2                	ld	s1,8(sp)
    80001bc2:	6105                	addi	sp,sp,32
    80001bc4:	8082                	ret

0000000080001bc6 <growproc>:
{
    80001bc6:	1101                	addi	sp,sp,-32
    80001bc8:	ec06                	sd	ra,24(sp)
    80001bca:	e822                	sd	s0,16(sp)
    80001bcc:	e426                	sd	s1,8(sp)
    80001bce:	e04a                	sd	s2,0(sp)
    80001bd0:	1000                	addi	s0,sp,32
    80001bd2:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001bd4:	d0dff0ef          	jal	800018e0 <myproc>
    80001bd8:	84aa                	mv	s1,a0
  sz = p->sz;
    80001bda:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001bdc:	01204c63          	bgtz	s2,80001bf4 <growproc+0x2e>
  } else if(n < 0){
    80001be0:	02094463          	bltz	s2,80001c08 <growproc+0x42>
  p->sz = sz;
    80001be4:	e4ac                	sd	a1,72(s1)
  return 0;
    80001be6:	4501                	li	a0,0
}
    80001be8:	60e2                	ld	ra,24(sp)
    80001bea:	6442                	ld	s0,16(sp)
    80001bec:	64a2                	ld	s1,8(sp)
    80001bee:	6902                	ld	s2,0(sp)
    80001bf0:	6105                	addi	sp,sp,32
    80001bf2:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001bf4:	4691                	li	a3,4
    80001bf6:	00b90633          	add	a2,s2,a1
    80001bfa:	6928                	ld	a0,80(a0)
    80001bfc:	f42ff0ef          	jal	8000133e <uvmalloc>
    80001c00:	85aa                	mv	a1,a0
    80001c02:	f16d                	bnez	a0,80001be4 <growproc+0x1e>
      return -1;
    80001c04:	557d                	li	a0,-1
    80001c06:	b7cd                	j	80001be8 <growproc+0x22>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001c08:	00b90633          	add	a2,s2,a1
    80001c0c:	6928                	ld	a0,80(a0)
    80001c0e:	eecff0ef          	jal	800012fa <uvmdealloc>
    80001c12:	85aa                	mv	a1,a0
    80001c14:	bfc1                	j	80001be4 <growproc+0x1e>

0000000080001c16 <fork>:
{
    80001c16:	7139                	addi	sp,sp,-64
    80001c18:	fc06                	sd	ra,56(sp)
    80001c1a:	f822                	sd	s0,48(sp)
    80001c1c:	f04a                	sd	s2,32(sp)
    80001c1e:	e456                	sd	s5,8(sp)
    80001c20:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001c22:	cbfff0ef          	jal	800018e0 <myproc>
    80001c26:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001c28:	e7bff0ef          	jal	80001aa2 <allocproc>
    80001c2c:	10050663          	beqz	a0,80001d38 <fork+0x122>
    80001c30:	ec4e                	sd	s3,24(sp)
    80001c32:	89aa                	mv	s3,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001c34:	048ab603          	ld	a2,72(s5)
    80001c38:	692c                	ld	a1,80(a0)
    80001c3a:	050ab503          	ld	a0,80(s5)
    80001c3e:	839ff0ef          	jal	80001476 <uvmcopy>
    80001c42:	06054663          	bltz	a0,80001cae <fork+0x98>
    80001c46:	f426                	sd	s1,40(sp)
    80001c48:	e852                	sd	s4,16(sp)
  np->sz = p->sz;
    80001c4a:	048ab783          	ld	a5,72(s5)
    80001c4e:	04f9b423          	sd	a5,72(s3)
  np->tickets = p->tickets;
    80001c52:	168aa783          	lw	a5,360(s5)
    80001c56:	16f9a423          	sw	a5,360(s3)
  np->stride = p->stride;
    80001c5a:	170ab783          	ld	a5,368(s5)
    80001c5e:	16f9b823          	sd	a5,368(s3)
  np->pass = p->pass;
    80001c62:	178ab783          	ld	a5,376(s5)
    80001c66:	16f9bc23          	sd	a5,376(s3)
  *(np->trapframe) = *(p->trapframe);
    80001c6a:	058ab683          	ld	a3,88(s5)
    80001c6e:	87b6                	mv	a5,a3
    80001c70:	0589b703          	ld	a4,88(s3)
    80001c74:	12068693          	addi	a3,a3,288
    80001c78:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001c7c:	6788                	ld	a0,8(a5)
    80001c7e:	6b8c                	ld	a1,16(a5)
    80001c80:	6f90                	ld	a2,24(a5)
    80001c82:	01073023          	sd	a6,0(a4)
    80001c86:	e708                	sd	a0,8(a4)
    80001c88:	eb0c                	sd	a1,16(a4)
    80001c8a:	ef10                	sd	a2,24(a4)
    80001c8c:	02078793          	addi	a5,a5,32
    80001c90:	02070713          	addi	a4,a4,32
    80001c94:	fed792e3          	bne	a5,a3,80001c78 <fork+0x62>
  np->trapframe->a0 = 0;
    80001c98:	0589b783          	ld	a5,88(s3)
    80001c9c:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001ca0:	0d0a8493          	addi	s1,s5,208
    80001ca4:	0d098913          	addi	s2,s3,208
    80001ca8:	150a8a13          	addi	s4,s5,336
    80001cac:	a831                	j	80001cc8 <fork+0xb2>
    freeproc(np);
    80001cae:	854e                	mv	a0,s3
    80001cb0:	da3ff0ef          	jal	80001a52 <freeproc>
    release(&np->lock);
    80001cb4:	854e                	mv	a0,s3
    80001cb6:	fd7fe0ef          	jal	80000c8c <release>
    return -1;
    80001cba:	597d                	li	s2,-1
    80001cbc:	69e2                	ld	s3,24(sp)
    80001cbe:	a0b5                	j	80001d2a <fork+0x114>
  for(i = 0; i < NOFILE; i++)
    80001cc0:	04a1                	addi	s1,s1,8
    80001cc2:	0921                	addi	s2,s2,8
    80001cc4:	01448963          	beq	s1,s4,80001cd6 <fork+0xc0>
    if(p->ofile[i])
    80001cc8:	6088                	ld	a0,0(s1)
    80001cca:	d97d                	beqz	a0,80001cc0 <fork+0xaa>
      np->ofile[i] = filedup(p->ofile[i]);
    80001ccc:	232020ef          	jal	80003efe <filedup>
    80001cd0:	00a93023          	sd	a0,0(s2)
    80001cd4:	b7f5                	j	80001cc0 <fork+0xaa>
  np->cwd = idup(p->cwd);
    80001cd6:	150ab503          	ld	a0,336(s5)
    80001cda:	584010ef          	jal	8000325e <idup>
    80001cde:	14a9b823          	sd	a0,336(s3)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001ce2:	4641                	li	a2,16
    80001ce4:	158a8593          	addi	a1,s5,344
    80001ce8:	15898513          	addi	a0,s3,344
    80001cec:	91aff0ef          	jal	80000e06 <safestrcpy>
  pid = np->pid;
    80001cf0:	0309a903          	lw	s2,48(s3)
  release(&np->lock);
    80001cf4:	854e                	mv	a0,s3
    80001cf6:	f97fe0ef          	jal	80000c8c <release>
  acquire(&wait_lock);
    80001cfa:	00010497          	auipc	s1,0x10
    80001cfe:	6be48493          	addi	s1,s1,1726 # 800123b8 <wait_lock>
    80001d02:	8526                	mv	a0,s1
    80001d04:	ef1fe0ef          	jal	80000bf4 <acquire>
  np->parent = p;
    80001d08:	0359bc23          	sd	s5,56(s3)
  release(&wait_lock);
    80001d0c:	8526                	mv	a0,s1
    80001d0e:	f7ffe0ef          	jal	80000c8c <release>
  acquire(&np->lock);
    80001d12:	854e                	mv	a0,s3
    80001d14:	ee1fe0ef          	jal	80000bf4 <acquire>
  np->state = RUNNABLE;
    80001d18:	478d                	li	a5,3
    80001d1a:	00f9ac23          	sw	a5,24(s3)
  release(&np->lock);
    80001d1e:	854e                	mv	a0,s3
    80001d20:	f6dfe0ef          	jal	80000c8c <release>
  return pid;
    80001d24:	74a2                	ld	s1,40(sp)
    80001d26:	69e2                	ld	s3,24(sp)
    80001d28:	6a42                	ld	s4,16(sp)
}
    80001d2a:	854a                	mv	a0,s2
    80001d2c:	70e2                	ld	ra,56(sp)
    80001d2e:	7442                	ld	s0,48(sp)
    80001d30:	7902                	ld	s2,32(sp)
    80001d32:	6aa2                	ld	s5,8(sp)
    80001d34:	6121                	addi	sp,sp,64
    80001d36:	8082                	ret
    return -1;
    80001d38:	597d                	li	s2,-1
    80001d3a:	bfc5                	j	80001d2a <fork+0x114>

0000000080001d3c <scheduler>:
{
    80001d3c:	7159                	addi	sp,sp,-112
    80001d3e:	f486                	sd	ra,104(sp)
    80001d40:	f0a2                	sd	s0,96(sp)
    80001d42:	eca6                	sd	s1,88(sp)
    80001d44:	e8ca                	sd	s2,80(sp)
    80001d46:	e4ce                	sd	s3,72(sp)
    80001d48:	e0d2                	sd	s4,64(sp)
    80001d4a:	fc56                	sd	s5,56(sp)
    80001d4c:	f85a                	sd	s6,48(sp)
    80001d4e:	f45e                	sd	s7,40(sp)
    80001d50:	f062                	sd	s8,32(sp)
    80001d52:	ec66                	sd	s9,24(sp)
    80001d54:	e86a                	sd	s10,16(sp)
    80001d56:	e46e                	sd	s11,8(sp)
    80001d58:	1880                	addi	s0,sp,112
    80001d5a:	8792                	mv	a5,tp
  int id = r_tp();
    80001d5c:	2781                	sext.w	a5,a5
  c->proc = 0;
    80001d5e:	00779d13          	slli	s10,a5,0x7
    80001d62:	00010717          	auipc	a4,0x10
    80001d66:	63e70713          	addi	a4,a4,1598 # 800123a0 <pid_lock>
    80001d6a:	976a                	add	a4,a4,s10
    80001d6c:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &proc_to_run->context);
    80001d70:	00010717          	auipc	a4,0x10
    80001d74:	66870713          	addi	a4,a4,1640 # 800123d8 <cpus+0x8>
    80001d78:	9d3a                	add	s10,s10,a4
    int highest_pid = -1;
    80001d7a:	5bfd                	li	s7,-1
    struct proc *proc_to_run = 0;
    80001d7c:	4c01                	li	s8,0
      if(p->state == RUNNABLE) {
    80001d7e:	490d                	li	s2,3
    for(p = proc; p < &proc[NPROC]; p++) {
    80001d80:	00017997          	auipc	s3,0x17
    80001d84:	a5098993          	addi	s3,s3,-1456 # 800187d0 <tickslock>
        proc_to_run->state = RUNNING;
    80001d88:	4d91                	li	s11,4
        c->proc = proc_to_run;
    80001d8a:	079e                	slli	a5,a5,0x7
    80001d8c:	00010c97          	auipc	s9,0x10
    80001d90:	614c8c93          	addi	s9,s9,1556 # 800123a0 <pid_lock>
    80001d94:	9cbe                	add	s9,s9,a5
    80001d96:	a8b1                	j	80001df2 <scheduler+0xb6>
          min_pass = p->pass;
    80001d98:	1784ba83          	ld	s5,376(s1)
          highest_pid = p->pid;
    80001d9c:	0304ab03          	lw	s6,48(s1)
          proc_to_run = p;
    80001da0:	8a26                	mv	s4,s1
      release(&p->lock);
    80001da2:	8526                	mv	a0,s1
    80001da4:	ee9fe0ef          	jal	80000c8c <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    80001da8:	18048493          	addi	s1,s1,384
    80001dac:	03348663          	beq	s1,s3,80001dd8 <scheduler+0x9c>
      acquire(&p->lock);
    80001db0:	8526                	mv	a0,s1
    80001db2:	e43fe0ef          	jal	80000bf4 <acquire>
      if(p->state == RUNNABLE) {
    80001db6:	4c9c                	lw	a5,24(s1)
    80001db8:	ff2795e3          	bne	a5,s2,80001da2 <scheduler+0x66>
        if (proc_to_run == 0 || p->pass < min_pass) {
    80001dbc:	fc0a0ee3          	beqz	s4,80001d98 <scheduler+0x5c>
    80001dc0:	1784b783          	ld	a5,376(s1)
    80001dc4:	fd57eae3          	bltu	a5,s5,80001d98 <scheduler+0x5c>
        } else if (p->pass == min_pass) {
    80001dc8:	fd579de3          	bne	a5,s5,80001da2 <scheduler+0x66>
          if (p->pid > highest_pid) {
    80001dcc:	589c                	lw	a5,48(s1)
    80001dce:	fcfb5ae3          	bge	s6,a5,80001da2 <scheduler+0x66>
            highest_pid = p->pid;
    80001dd2:	8b3e                	mv	s6,a5
            proc_to_run = p;
    80001dd4:	8a26                	mv	s4,s1
    80001dd6:	b7f1                	j	80001da2 <scheduler+0x66>
    if(proc_to_run) {
    80001dd8:	040a0e63          	beqz	s4,80001e34 <scheduler+0xf8>
      acquire(&proc_to_run->lock);
    80001ddc:	84d2                	mv	s1,s4
    80001dde:	8552                	mv	a0,s4
    80001de0:	e15fe0ef          	jal	80000bf4 <acquire>
      if (proc_to_run->state == RUNNABLE) {
    80001de4:	018a2783          	lw	a5,24(s4)
    80001de8:	03278363          	beq	a5,s2,80001e0e <scheduler+0xd2>
      release(&proc_to_run->lock);
    80001dec:	8526                	mv	a0,s1
    80001dee:	e9ffe0ef          	jal	80000c8c <release>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001df2:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001df6:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001dfa:	10079073          	csrw	sstatus,a5
    int highest_pid = -1;
    80001dfe:	8b5e                	mv	s6,s7
    uint64 min_pass = (uint64)-1;
    80001e00:	8ade                	mv	s5,s7
    struct proc *proc_to_run = 0;
    80001e02:	8a62                	mv	s4,s8
    for(p = proc; p < &proc[NPROC]; p++) {
    80001e04:	00011497          	auipc	s1,0x11
    80001e08:	9cc48493          	addi	s1,s1,-1588 # 800127d0 <proc>
    80001e0c:	b755                	j	80001db0 <scheduler+0x74>
        proc_to_run->pass += proc_to_run->stride;
    80001e0e:	178a3783          	ld	a5,376(s4)
    80001e12:	170a3703          	ld	a4,368(s4)
    80001e16:	97ba                	add	a5,a5,a4
    80001e18:	16fa3c23          	sd	a5,376(s4)
        proc_to_run->state = RUNNING;
    80001e1c:	01ba2c23          	sw	s11,24(s4)
        c->proc = proc_to_run;
    80001e20:	034cb823          	sd	s4,48(s9)
        swtch(&c->context, &proc_to_run->context);
    80001e24:	060a0593          	addi	a1,s4,96
    80001e28:	856a                	mv	a0,s10
    80001e2a:	596000ef          	jal	800023c0 <swtch>
        c->proc = 0;
    80001e2e:	020cb823          	sd	zero,48(s9)
    80001e32:	bf6d                	j	80001dec <scheduler+0xb0>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e34:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80001e38:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80001e3c:	10079073          	csrw	sstatus,a5
      asm volatile("wfi");
    80001e40:	10500073          	wfi
    80001e44:	b77d                	j	80001df2 <scheduler+0xb6>

0000000080001e46 <sched>:
{
    80001e46:	7179                	addi	sp,sp,-48
    80001e48:	f406                	sd	ra,40(sp)
    80001e4a:	f022                	sd	s0,32(sp)
    80001e4c:	ec26                	sd	s1,24(sp)
    80001e4e:	e84a                	sd	s2,16(sp)
    80001e50:	e44e                	sd	s3,8(sp)
    80001e52:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    80001e54:	a8dff0ef          	jal	800018e0 <myproc>
    80001e58:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    80001e5a:	d31fe0ef          	jal	80000b8a <holding>
    80001e5e:	c92d                	beqz	a0,80001ed0 <sched+0x8a>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e60:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    80001e62:	2781                	sext.w	a5,a5
    80001e64:	079e                	slli	a5,a5,0x7
    80001e66:	00010717          	auipc	a4,0x10
    80001e6a:	53a70713          	addi	a4,a4,1338 # 800123a0 <pid_lock>
    80001e6e:	97ba                	add	a5,a5,a4
    80001e70:	0a87a703          	lw	a4,168(a5)
    80001e74:	4785                	li	a5,1
    80001e76:	06f71363          	bne	a4,a5,80001edc <sched+0x96>
  if(p->state == RUNNING)
    80001e7a:	4c98                	lw	a4,24(s1)
    80001e7c:	4791                	li	a5,4
    80001e7e:	06f70563          	beq	a4,a5,80001ee8 <sched+0xa2>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80001e82:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80001e86:	8b89                	andi	a5,a5,2
  if(intr_get())
    80001e88:	e7b5                	bnez	a5,80001ef4 <sched+0xae>
  asm volatile("mv %0, tp" : "=r" (x) );
    80001e8a:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    80001e8c:	00010917          	auipc	s2,0x10
    80001e90:	51490913          	addi	s2,s2,1300 # 800123a0 <pid_lock>
    80001e94:	2781                	sext.w	a5,a5
    80001e96:	079e                	slli	a5,a5,0x7
    80001e98:	97ca                	add	a5,a5,s2
    80001e9a:	0ac7a983          	lw	s3,172(a5)
    80001e9e:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    80001ea0:	2781                	sext.w	a5,a5
    80001ea2:	079e                	slli	a5,a5,0x7
    80001ea4:	00010597          	auipc	a1,0x10
    80001ea8:	53458593          	addi	a1,a1,1332 # 800123d8 <cpus+0x8>
    80001eac:	95be                	add	a1,a1,a5
    80001eae:	06048513          	addi	a0,s1,96
    80001eb2:	50e000ef          	jal	800023c0 <swtch>
    80001eb6:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    80001eb8:	2781                	sext.w	a5,a5
    80001eba:	079e                	slli	a5,a5,0x7
    80001ebc:	993e                	add	s2,s2,a5
    80001ebe:	0b392623          	sw	s3,172(s2)
}
    80001ec2:	70a2                	ld	ra,40(sp)
    80001ec4:	7402                	ld	s0,32(sp)
    80001ec6:	64e2                	ld	s1,24(sp)
    80001ec8:	6942                	ld	s2,16(sp)
    80001eca:	69a2                	ld	s3,8(sp)
    80001ecc:	6145                	addi	sp,sp,48
    80001ece:	8082                	ret
    panic("sched p->lock");
    80001ed0:	00005517          	auipc	a0,0x5
    80001ed4:	36850513          	addi	a0,a0,872 # 80007238 <etext+0x238>
    80001ed8:	8bdfe0ef          	jal	80000794 <panic>
    panic("sched locks");
    80001edc:	00005517          	auipc	a0,0x5
    80001ee0:	36c50513          	addi	a0,a0,876 # 80007248 <etext+0x248>
    80001ee4:	8b1fe0ef          	jal	80000794 <panic>
    panic("sched running");
    80001ee8:	00005517          	auipc	a0,0x5
    80001eec:	37050513          	addi	a0,a0,880 # 80007258 <etext+0x258>
    80001ef0:	8a5fe0ef          	jal	80000794 <panic>
    panic("sched interruptible");
    80001ef4:	00005517          	auipc	a0,0x5
    80001ef8:	37450513          	addi	a0,a0,884 # 80007268 <etext+0x268>
    80001efc:	899fe0ef          	jal	80000794 <panic>

0000000080001f00 <yield>:
{
    80001f00:	1101                	addi	sp,sp,-32
    80001f02:	ec06                	sd	ra,24(sp)
    80001f04:	e822                	sd	s0,16(sp)
    80001f06:	e426                	sd	s1,8(sp)
    80001f08:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80001f0a:	9d7ff0ef          	jal	800018e0 <myproc>
    80001f0e:	84aa                	mv	s1,a0
  acquire(&p->lock);
    80001f10:	ce5fe0ef          	jal	80000bf4 <acquire>
  p->state = RUNNABLE;
    80001f14:	478d                	li	a5,3
    80001f16:	cc9c                	sw	a5,24(s1)
  sched();
    80001f18:	f2fff0ef          	jal	80001e46 <sched>
  release(&p->lock);
    80001f1c:	8526                	mv	a0,s1
    80001f1e:	d6ffe0ef          	jal	80000c8c <release>
}
    80001f22:	60e2                	ld	ra,24(sp)
    80001f24:	6442                	ld	s0,16(sp)
    80001f26:	64a2                	ld	s1,8(sp)
    80001f28:	6105                	addi	sp,sp,32
    80001f2a:	8082                	ret

0000000080001f2c <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    80001f2c:	7179                	addi	sp,sp,-48
    80001f2e:	f406                	sd	ra,40(sp)
    80001f30:	f022                	sd	s0,32(sp)
    80001f32:	ec26                	sd	s1,24(sp)
    80001f34:	e84a                	sd	s2,16(sp)
    80001f36:	e44e                	sd	s3,8(sp)
    80001f38:	1800                	addi	s0,sp,48
    80001f3a:	89aa                	mv	s3,a0
    80001f3c:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80001f3e:	9a3ff0ef          	jal	800018e0 <myproc>
    80001f42:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    80001f44:	cb1fe0ef          	jal	80000bf4 <acquire>
  release(lk);
    80001f48:	854a                	mv	a0,s2
    80001f4a:	d43fe0ef          	jal	80000c8c <release>

  // Go to sleep.
  p->chan = chan;
    80001f4e:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    80001f52:	4789                	li	a5,2
    80001f54:	cc9c                	sw	a5,24(s1)

  sched();
    80001f56:	ef1ff0ef          	jal	80001e46 <sched>

  // Tidy up.
  p->chan = 0;
    80001f5a:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    80001f5e:	8526                	mv	a0,s1
    80001f60:	d2dfe0ef          	jal	80000c8c <release>
  acquire(lk);
    80001f64:	854a                	mv	a0,s2
    80001f66:	c8ffe0ef          	jal	80000bf4 <acquire>
}
    80001f6a:	70a2                	ld	ra,40(sp)
    80001f6c:	7402                	ld	s0,32(sp)
    80001f6e:	64e2                	ld	s1,24(sp)
    80001f70:	6942                	ld	s2,16(sp)
    80001f72:	69a2                	ld	s3,8(sp)
    80001f74:	6145                	addi	sp,sp,48
    80001f76:	8082                	ret

0000000080001f78 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80001f78:	7139                	addi	sp,sp,-64
    80001f7a:	fc06                	sd	ra,56(sp)
    80001f7c:	f822                	sd	s0,48(sp)
    80001f7e:	f426                	sd	s1,40(sp)
    80001f80:	f04a                	sd	s2,32(sp)
    80001f82:	ec4e                	sd	s3,24(sp)
    80001f84:	e852                	sd	s4,16(sp)
    80001f86:	e456                	sd	s5,8(sp)
    80001f88:	0080                	addi	s0,sp,64
    80001f8a:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    80001f8c:	00011497          	auipc	s1,0x11
    80001f90:	84448493          	addi	s1,s1,-1980 # 800127d0 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80001f94:	4989                	li	s3,2
        p->state = RUNNABLE;
    80001f96:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80001f98:	00017917          	auipc	s2,0x17
    80001f9c:	83890913          	addi	s2,s2,-1992 # 800187d0 <tickslock>
    80001fa0:	a801                	j	80001fb0 <wakeup+0x38>
      }
      release(&p->lock);
    80001fa2:	8526                	mv	a0,s1
    80001fa4:	ce9fe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001fa8:	18048493          	addi	s1,s1,384
    80001fac:	03248263          	beq	s1,s2,80001fd0 <wakeup+0x58>
    if(p != myproc()){
    80001fb0:	931ff0ef          	jal	800018e0 <myproc>
    80001fb4:	fea48ae3          	beq	s1,a0,80001fa8 <wakeup+0x30>
      acquire(&p->lock);
    80001fb8:	8526                	mv	a0,s1
    80001fba:	c3bfe0ef          	jal	80000bf4 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80001fbe:	4c9c                	lw	a5,24(s1)
    80001fc0:	ff3791e3          	bne	a5,s3,80001fa2 <wakeup+0x2a>
    80001fc4:	709c                	ld	a5,32(s1)
    80001fc6:	fd479ee3          	bne	a5,s4,80001fa2 <wakeup+0x2a>
        p->state = RUNNABLE;
    80001fca:	0154ac23          	sw	s5,24(s1)
    80001fce:	bfd1                	j	80001fa2 <wakeup+0x2a>
    }
  }
}
    80001fd0:	70e2                	ld	ra,56(sp)
    80001fd2:	7442                	ld	s0,48(sp)
    80001fd4:	74a2                	ld	s1,40(sp)
    80001fd6:	7902                	ld	s2,32(sp)
    80001fd8:	69e2                	ld	s3,24(sp)
    80001fda:	6a42                	ld	s4,16(sp)
    80001fdc:	6aa2                	ld	s5,8(sp)
    80001fde:	6121                	addi	sp,sp,64
    80001fe0:	8082                	ret

0000000080001fe2 <reparent>:
{
    80001fe2:	7179                	addi	sp,sp,-48
    80001fe4:	f406                	sd	ra,40(sp)
    80001fe6:	f022                	sd	s0,32(sp)
    80001fe8:	ec26                	sd	s1,24(sp)
    80001fea:	e84a                	sd	s2,16(sp)
    80001fec:	e44e                	sd	s3,8(sp)
    80001fee:	e052                	sd	s4,0(sp)
    80001ff0:	1800                	addi	s0,sp,48
    80001ff2:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001ff4:	00010497          	auipc	s1,0x10
    80001ff8:	7dc48493          	addi	s1,s1,2012 # 800127d0 <proc>
      pp->parent = initproc;
    80001ffc:	00008a17          	auipc	s4,0x8
    80002000:	26ca0a13          	addi	s4,s4,620 # 8000a268 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80002004:	00016997          	auipc	s3,0x16
    80002008:	7cc98993          	addi	s3,s3,1996 # 800187d0 <tickslock>
    8000200c:	a029                	j	80002016 <reparent+0x34>
    8000200e:	18048493          	addi	s1,s1,384
    80002012:	01348b63          	beq	s1,s3,80002028 <reparent+0x46>
    if(pp->parent == p){
    80002016:	7c9c                	ld	a5,56(s1)
    80002018:	ff279be3          	bne	a5,s2,8000200e <reparent+0x2c>
      pp->parent = initproc;
    8000201c:	000a3503          	ld	a0,0(s4)
    80002020:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    80002022:	f57ff0ef          	jal	80001f78 <wakeup>
    80002026:	b7e5                	j	8000200e <reparent+0x2c>
}
    80002028:	70a2                	ld	ra,40(sp)
    8000202a:	7402                	ld	s0,32(sp)
    8000202c:	64e2                	ld	s1,24(sp)
    8000202e:	6942                	ld	s2,16(sp)
    80002030:	69a2                	ld	s3,8(sp)
    80002032:	6a02                	ld	s4,0(sp)
    80002034:	6145                	addi	sp,sp,48
    80002036:	8082                	ret

0000000080002038 <exit>:
{
    80002038:	7179                	addi	sp,sp,-48
    8000203a:	f406                	sd	ra,40(sp)
    8000203c:	f022                	sd	s0,32(sp)
    8000203e:	ec26                	sd	s1,24(sp)
    80002040:	e84a                	sd	s2,16(sp)
    80002042:	e44e                	sd	s3,8(sp)
    80002044:	e052                	sd	s4,0(sp)
    80002046:	1800                	addi	s0,sp,48
    80002048:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    8000204a:	897ff0ef          	jal	800018e0 <myproc>
    8000204e:	89aa                	mv	s3,a0
  if(p == initproc)
    80002050:	00008797          	auipc	a5,0x8
    80002054:	2187b783          	ld	a5,536(a5) # 8000a268 <initproc>
    80002058:	0d050493          	addi	s1,a0,208
    8000205c:	15050913          	addi	s2,a0,336
    80002060:	00a79f63          	bne	a5,a0,8000207e <exit+0x46>
    panic("init exiting");
    80002064:	00005517          	auipc	a0,0x5
    80002068:	21c50513          	addi	a0,a0,540 # 80007280 <etext+0x280>
    8000206c:	f28fe0ef          	jal	80000794 <panic>
      fileclose(f);
    80002070:	6d5010ef          	jal	80003f44 <fileclose>
      p->ofile[fd] = 0;
    80002074:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002078:	04a1                	addi	s1,s1,8
    8000207a:	01248563          	beq	s1,s2,80002084 <exit+0x4c>
    if(p->ofile[fd]){
    8000207e:	6088                	ld	a0,0(s1)
    80002080:	f965                	bnez	a0,80002070 <exit+0x38>
    80002082:	bfdd                	j	80002078 <exit+0x40>
  begin_op();
    80002084:	2a7010ef          	jal	80003b2a <begin_op>
  iput(p->cwd);
    80002088:	1509b503          	ld	a0,336(s3)
    8000208c:	38a010ef          	jal	80003416 <iput>
  end_op();
    80002090:	305010ef          	jal	80003b94 <end_op>
  p->cwd = 0;
    80002094:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    80002098:	00010497          	auipc	s1,0x10
    8000209c:	32048493          	addi	s1,s1,800 # 800123b8 <wait_lock>
    800020a0:	8526                	mv	a0,s1
    800020a2:	b53fe0ef          	jal	80000bf4 <acquire>
  reparent(p);
    800020a6:	854e                	mv	a0,s3
    800020a8:	f3bff0ef          	jal	80001fe2 <reparent>
  wakeup(p->parent);
    800020ac:	0389b503          	ld	a0,56(s3)
    800020b0:	ec9ff0ef          	jal	80001f78 <wakeup>
  acquire(&p->lock);
    800020b4:	854e                	mv	a0,s3
    800020b6:	b3ffe0ef          	jal	80000bf4 <acquire>
  p->xstate = status;
    800020ba:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    800020be:	4795                	li	a5,5
    800020c0:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    800020c4:	8526                	mv	a0,s1
    800020c6:	bc7fe0ef          	jal	80000c8c <release>
  sched();
    800020ca:	d7dff0ef          	jal	80001e46 <sched>
  panic("zombie exit");
    800020ce:	00005517          	auipc	a0,0x5
    800020d2:	1c250513          	addi	a0,a0,450 # 80007290 <etext+0x290>
    800020d6:	ebefe0ef          	jal	80000794 <panic>

00000000800020da <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800020da:	7179                	addi	sp,sp,-48
    800020dc:	f406                	sd	ra,40(sp)
    800020de:	f022                	sd	s0,32(sp)
    800020e0:	ec26                	sd	s1,24(sp)
    800020e2:	e84a                	sd	s2,16(sp)
    800020e4:	e44e                	sd	s3,8(sp)
    800020e6:	1800                	addi	s0,sp,48
    800020e8:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800020ea:	00010497          	auipc	s1,0x10
    800020ee:	6e648493          	addi	s1,s1,1766 # 800127d0 <proc>
    800020f2:	00016997          	auipc	s3,0x16
    800020f6:	6de98993          	addi	s3,s3,1758 # 800187d0 <tickslock>
    acquire(&p->lock);
    800020fa:	8526                	mv	a0,s1
    800020fc:	af9fe0ef          	jal	80000bf4 <acquire>
    if(p->pid == pid){
    80002100:	589c                	lw	a5,48(s1)
    80002102:	01278b63          	beq	a5,s2,80002118 <kill+0x3e>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    80002106:	8526                	mv	a0,s1
    80002108:	b85fe0ef          	jal	80000c8c <release>
  for(p = proc; p < &proc[NPROC]; p++){
    8000210c:	18048493          	addi	s1,s1,384
    80002110:	ff3495e3          	bne	s1,s3,800020fa <kill+0x20>
  }
  return -1;
    80002114:	557d                	li	a0,-1
    80002116:	a819                	j	8000212c <kill+0x52>
      p->killed = 1;
    80002118:	4785                	li	a5,1
    8000211a:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    8000211c:	4c98                	lw	a4,24(s1)
    8000211e:	4789                	li	a5,2
    80002120:	00f70d63          	beq	a4,a5,8000213a <kill+0x60>
      release(&p->lock);
    80002124:	8526                	mv	a0,s1
    80002126:	b67fe0ef          	jal	80000c8c <release>
      return 0;
    8000212a:	4501                	li	a0,0
}
    8000212c:	70a2                	ld	ra,40(sp)
    8000212e:	7402                	ld	s0,32(sp)
    80002130:	64e2                	ld	s1,24(sp)
    80002132:	6942                	ld	s2,16(sp)
    80002134:	69a2                	ld	s3,8(sp)
    80002136:	6145                	addi	sp,sp,48
    80002138:	8082                	ret
        p->state = RUNNABLE;
    8000213a:	478d                	li	a5,3
    8000213c:	cc9c                	sw	a5,24(s1)
    8000213e:	b7dd                	j	80002124 <kill+0x4a>

0000000080002140 <setkilled>:

void
setkilled(struct proc *p)
{
    80002140:	1101                	addi	sp,sp,-32
    80002142:	ec06                	sd	ra,24(sp)
    80002144:	e822                	sd	s0,16(sp)
    80002146:	e426                	sd	s1,8(sp)
    80002148:	1000                	addi	s0,sp,32
    8000214a:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000214c:	aa9fe0ef          	jal	80000bf4 <acquire>
  p->killed = 1;
    80002150:	4785                	li	a5,1
    80002152:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002154:	8526                	mv	a0,s1
    80002156:	b37fe0ef          	jal	80000c8c <release>
}
    8000215a:	60e2                	ld	ra,24(sp)
    8000215c:	6442                	ld	s0,16(sp)
    8000215e:	64a2                	ld	s1,8(sp)
    80002160:	6105                	addi	sp,sp,32
    80002162:	8082                	ret

0000000080002164 <killed>:

int
killed(struct proc *p)
{
    80002164:	1101                	addi	sp,sp,-32
    80002166:	ec06                	sd	ra,24(sp)
    80002168:	e822                	sd	s0,16(sp)
    8000216a:	e426                	sd	s1,8(sp)
    8000216c:	e04a                	sd	s2,0(sp)
    8000216e:	1000                	addi	s0,sp,32
    80002170:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002172:	a83fe0ef          	jal	80000bf4 <acquire>
  k = p->killed;
    80002176:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    8000217a:	8526                	mv	a0,s1
    8000217c:	b11fe0ef          	jal	80000c8c <release>
  return k;
}
    80002180:	854a                	mv	a0,s2
    80002182:	60e2                	ld	ra,24(sp)
    80002184:	6442                	ld	s0,16(sp)
    80002186:	64a2                	ld	s1,8(sp)
    80002188:	6902                	ld	s2,0(sp)
    8000218a:	6105                	addi	sp,sp,32
    8000218c:	8082                	ret

000000008000218e <wait>:
{
    8000218e:	715d                	addi	sp,sp,-80
    80002190:	e486                	sd	ra,72(sp)
    80002192:	e0a2                	sd	s0,64(sp)
    80002194:	fc26                	sd	s1,56(sp)
    80002196:	f84a                	sd	s2,48(sp)
    80002198:	f44e                	sd	s3,40(sp)
    8000219a:	f052                	sd	s4,32(sp)
    8000219c:	ec56                	sd	s5,24(sp)
    8000219e:	e85a                	sd	s6,16(sp)
    800021a0:	e45e                	sd	s7,8(sp)
    800021a2:	e062                	sd	s8,0(sp)
    800021a4:	0880                	addi	s0,sp,80
    800021a6:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    800021a8:	f38ff0ef          	jal	800018e0 <myproc>
    800021ac:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800021ae:	00010517          	auipc	a0,0x10
    800021b2:	20a50513          	addi	a0,a0,522 # 800123b8 <wait_lock>
    800021b6:	a3ffe0ef          	jal	80000bf4 <acquire>
    havekids = 0;
    800021ba:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800021bc:	4a15                	li	s4,5
        havekids = 1;
    800021be:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800021c0:	00016997          	auipc	s3,0x16
    800021c4:	61098993          	addi	s3,s3,1552 # 800187d0 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800021c8:	00010c17          	auipc	s8,0x10
    800021cc:	1f0c0c13          	addi	s8,s8,496 # 800123b8 <wait_lock>
    800021d0:	a871                	j	8000226c <wait+0xde>
          pid = pp->pid;
    800021d2:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800021d6:	000b0c63          	beqz	s6,800021ee <wait+0x60>
    800021da:	4691                	li	a3,4
    800021dc:	02c48613          	addi	a2,s1,44
    800021e0:	85da                	mv	a1,s6
    800021e2:	05093503          	ld	a0,80(s2)
    800021e6:	b6cff0ef          	jal	80001552 <copyout>
    800021ea:	02054b63          	bltz	a0,80002220 <wait+0x92>
          freeproc(pp);
    800021ee:	8526                	mv	a0,s1
    800021f0:	863ff0ef          	jal	80001a52 <freeproc>
          release(&pp->lock);
    800021f4:	8526                	mv	a0,s1
    800021f6:	a97fe0ef          	jal	80000c8c <release>
          release(&wait_lock);
    800021fa:	00010517          	auipc	a0,0x10
    800021fe:	1be50513          	addi	a0,a0,446 # 800123b8 <wait_lock>
    80002202:	a8bfe0ef          	jal	80000c8c <release>
}
    80002206:	854e                	mv	a0,s3
    80002208:	60a6                	ld	ra,72(sp)
    8000220a:	6406                	ld	s0,64(sp)
    8000220c:	74e2                	ld	s1,56(sp)
    8000220e:	7942                	ld	s2,48(sp)
    80002210:	79a2                	ld	s3,40(sp)
    80002212:	7a02                	ld	s4,32(sp)
    80002214:	6ae2                	ld	s5,24(sp)
    80002216:	6b42                	ld	s6,16(sp)
    80002218:	6ba2                	ld	s7,8(sp)
    8000221a:	6c02                	ld	s8,0(sp)
    8000221c:	6161                	addi	sp,sp,80
    8000221e:	8082                	ret
            release(&pp->lock);
    80002220:	8526                	mv	a0,s1
    80002222:	a6bfe0ef          	jal	80000c8c <release>
            release(&wait_lock);
    80002226:	00010517          	auipc	a0,0x10
    8000222a:	19250513          	addi	a0,a0,402 # 800123b8 <wait_lock>
    8000222e:	a5ffe0ef          	jal	80000c8c <release>
            return -1;
    80002232:	59fd                	li	s3,-1
    80002234:	bfc9                	j	80002206 <wait+0x78>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002236:	18048493          	addi	s1,s1,384
    8000223a:	03348063          	beq	s1,s3,8000225a <wait+0xcc>
      if(pp->parent == p){
    8000223e:	7c9c                	ld	a5,56(s1)
    80002240:	ff279be3          	bne	a5,s2,80002236 <wait+0xa8>
        acquire(&pp->lock);
    80002244:	8526                	mv	a0,s1
    80002246:	9affe0ef          	jal	80000bf4 <acquire>
        if(pp->state == ZOMBIE){
    8000224a:	4c9c                	lw	a5,24(s1)
    8000224c:	f94783e3          	beq	a5,s4,800021d2 <wait+0x44>
        release(&pp->lock);
    80002250:	8526                	mv	a0,s1
    80002252:	a3bfe0ef          	jal	80000c8c <release>
        havekids = 1;
    80002256:	8756                	mv	a4,s5
    80002258:	bff9                	j	80002236 <wait+0xa8>
    if(!havekids || killed(p)){
    8000225a:	cf19                	beqz	a4,80002278 <wait+0xea>
    8000225c:	854a                	mv	a0,s2
    8000225e:	f07ff0ef          	jal	80002164 <killed>
    80002262:	e919                	bnez	a0,80002278 <wait+0xea>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    80002264:	85e2                	mv	a1,s8
    80002266:	854a                	mv	a0,s2
    80002268:	cc5ff0ef          	jal	80001f2c <sleep>
    havekids = 0;
    8000226c:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    8000226e:	00010497          	auipc	s1,0x10
    80002272:	56248493          	addi	s1,s1,1378 # 800127d0 <proc>
    80002276:	b7e1                	j	8000223e <wait+0xb0>
      release(&wait_lock);
    80002278:	00010517          	auipc	a0,0x10
    8000227c:	14050513          	addi	a0,a0,320 # 800123b8 <wait_lock>
    80002280:	a0dfe0ef          	jal	80000c8c <release>
      return -1;
    80002284:	59fd                	li	s3,-1
    80002286:	b741                	j	80002206 <wait+0x78>

0000000080002288 <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    80002288:	7179                	addi	sp,sp,-48
    8000228a:	f406                	sd	ra,40(sp)
    8000228c:	f022                	sd	s0,32(sp)
    8000228e:	ec26                	sd	s1,24(sp)
    80002290:	e84a                	sd	s2,16(sp)
    80002292:	e44e                	sd	s3,8(sp)
    80002294:	e052                	sd	s4,0(sp)
    80002296:	1800                	addi	s0,sp,48
    80002298:	84aa                	mv	s1,a0
    8000229a:	892e                	mv	s2,a1
    8000229c:	89b2                	mv	s3,a2
    8000229e:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800022a0:	e40ff0ef          	jal	800018e0 <myproc>
  if(user_dst){
    800022a4:	cc99                	beqz	s1,800022c2 <either_copyout+0x3a>
    return copyout(p->pagetable, dst, src, len);
    800022a6:	86d2                	mv	a3,s4
    800022a8:	864e                	mv	a2,s3
    800022aa:	85ca                	mv	a1,s2
    800022ac:	6928                	ld	a0,80(a0)
    800022ae:	aa4ff0ef          	jal	80001552 <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800022b2:	70a2                	ld	ra,40(sp)
    800022b4:	7402                	ld	s0,32(sp)
    800022b6:	64e2                	ld	s1,24(sp)
    800022b8:	6942                	ld	s2,16(sp)
    800022ba:	69a2                	ld	s3,8(sp)
    800022bc:	6a02                	ld	s4,0(sp)
    800022be:	6145                	addi	sp,sp,48
    800022c0:	8082                	ret
    memmove((char *)dst, src, len);
    800022c2:	000a061b          	sext.w	a2,s4
    800022c6:	85ce                	mv	a1,s3
    800022c8:	854a                	mv	a0,s2
    800022ca:	a5bfe0ef          	jal	80000d24 <memmove>
    return 0;
    800022ce:	8526                	mv	a0,s1
    800022d0:	b7cd                	j	800022b2 <either_copyout+0x2a>

00000000800022d2 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    800022d2:	7179                	addi	sp,sp,-48
    800022d4:	f406                	sd	ra,40(sp)
    800022d6:	f022                	sd	s0,32(sp)
    800022d8:	ec26                	sd	s1,24(sp)
    800022da:	e84a                	sd	s2,16(sp)
    800022dc:	e44e                	sd	s3,8(sp)
    800022de:	e052                	sd	s4,0(sp)
    800022e0:	1800                	addi	s0,sp,48
    800022e2:	892a                	mv	s2,a0
    800022e4:	84ae                	mv	s1,a1
    800022e6:	89b2                	mv	s3,a2
    800022e8:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800022ea:	df6ff0ef          	jal	800018e0 <myproc>
  if(user_src){
    800022ee:	cc99                	beqz	s1,8000230c <either_copyin+0x3a>
    return copyin(p->pagetable, dst, src, len);
    800022f0:	86d2                	mv	a3,s4
    800022f2:	864e                	mv	a2,s3
    800022f4:	85ca                	mv	a1,s2
    800022f6:	6928                	ld	a0,80(a0)
    800022f8:	b30ff0ef          	jal	80001628 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    800022fc:	70a2                	ld	ra,40(sp)
    800022fe:	7402                	ld	s0,32(sp)
    80002300:	64e2                	ld	s1,24(sp)
    80002302:	6942                	ld	s2,16(sp)
    80002304:	69a2                	ld	s3,8(sp)
    80002306:	6a02                	ld	s4,0(sp)
    80002308:	6145                	addi	sp,sp,48
    8000230a:	8082                	ret
    memmove(dst, (char*)src, len);
    8000230c:	000a061b          	sext.w	a2,s4
    80002310:	85ce                	mv	a1,s3
    80002312:	854a                	mv	a0,s2
    80002314:	a11fe0ef          	jal	80000d24 <memmove>
    return 0;
    80002318:	8526                	mv	a0,s1
    8000231a:	b7cd                	j	800022fc <either_copyin+0x2a>

000000008000231c <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    8000231c:	715d                	addi	sp,sp,-80
    8000231e:	e486                	sd	ra,72(sp)
    80002320:	e0a2                	sd	s0,64(sp)
    80002322:	fc26                	sd	s1,56(sp)
    80002324:	f84a                	sd	s2,48(sp)
    80002326:	f44e                	sd	s3,40(sp)
    80002328:	f052                	sd	s4,32(sp)
    8000232a:	ec56                	sd	s5,24(sp)
    8000232c:	e85a                	sd	s6,16(sp)
    8000232e:	e45e                	sd	s7,8(sp)
    80002330:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    80002332:	00005517          	auipc	a0,0x5
    80002336:	d4650513          	addi	a0,a0,-698 # 80007078 <etext+0x78>
    8000233a:	988fe0ef          	jal	800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000233e:	00010497          	auipc	s1,0x10
    80002342:	5ea48493          	addi	s1,s1,1514 # 80012928 <proc+0x158>
    80002346:	00016917          	auipc	s2,0x16
    8000234a:	5e290913          	addi	s2,s2,1506 # 80018928 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000234e:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    80002350:	00005997          	auipc	s3,0x5
    80002354:	f5098993          	addi	s3,s3,-176 # 800072a0 <etext+0x2a0>
    printf("%d %s %s", p->pid, state, p->name);
    80002358:	00005a97          	auipc	s5,0x5
    8000235c:	f50a8a93          	addi	s5,s5,-176 # 800072a8 <etext+0x2a8>
    printf("\n");
    80002360:	00005a17          	auipc	s4,0x5
    80002364:	d18a0a13          	addi	s4,s4,-744 # 80007078 <etext+0x78>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002368:	00005b97          	auipc	s7,0x5
    8000236c:	420b8b93          	addi	s7,s7,1056 # 80007788 <states.0>
    80002370:	a829                	j	8000238a <procdump+0x6e>
    printf("%d %s %s", p->pid, state, p->name);
    80002372:	ed86a583          	lw	a1,-296(a3)
    80002376:	8556                	mv	a0,s5
    80002378:	94afe0ef          	jal	800004c2 <printf>
    printf("\n");
    8000237c:	8552                	mv	a0,s4
    8000237e:	944fe0ef          	jal	800004c2 <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    80002382:	18048493          	addi	s1,s1,384
    80002386:	03248263          	beq	s1,s2,800023aa <procdump+0x8e>
    if(p->state == UNUSED)
    8000238a:	86a6                	mv	a3,s1
    8000238c:	ec04a783          	lw	a5,-320(s1)
    80002390:	dbed                	beqz	a5,80002382 <procdump+0x66>
      state = "???";
    80002392:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    80002394:	fcfb6fe3          	bltu	s6,a5,80002372 <procdump+0x56>
    80002398:	02079713          	slli	a4,a5,0x20
    8000239c:	01d75793          	srli	a5,a4,0x1d
    800023a0:	97de                	add	a5,a5,s7
    800023a2:	6390                	ld	a2,0(a5)
    800023a4:	f679                	bnez	a2,80002372 <procdump+0x56>
      state = "???";
    800023a6:	864e                	mv	a2,s3
    800023a8:	b7e9                	j	80002372 <procdump+0x56>
  }
    800023aa:	60a6                	ld	ra,72(sp)
    800023ac:	6406                	ld	s0,64(sp)
    800023ae:	74e2                	ld	s1,56(sp)
    800023b0:	7942                	ld	s2,48(sp)
    800023b2:	79a2                	ld	s3,40(sp)
    800023b4:	7a02                	ld	s4,32(sp)
    800023b6:	6ae2                	ld	s5,24(sp)
    800023b8:	6b42                	ld	s6,16(sp)
    800023ba:	6ba2                	ld	s7,8(sp)
    800023bc:	6161                	addi	sp,sp,80
    800023be:	8082                	ret

00000000800023c0 <swtch>:
    800023c0:	00153023          	sd	ra,0(a0)
    800023c4:	00253423          	sd	sp,8(a0)
    800023c8:	e900                	sd	s0,16(a0)
    800023ca:	ed04                	sd	s1,24(a0)
    800023cc:	03253023          	sd	s2,32(a0)
    800023d0:	03353423          	sd	s3,40(a0)
    800023d4:	03453823          	sd	s4,48(a0)
    800023d8:	03553c23          	sd	s5,56(a0)
    800023dc:	05653023          	sd	s6,64(a0)
    800023e0:	05753423          	sd	s7,72(a0)
    800023e4:	05853823          	sd	s8,80(a0)
    800023e8:	05953c23          	sd	s9,88(a0)
    800023ec:	07a53023          	sd	s10,96(a0)
    800023f0:	07b53423          	sd	s11,104(a0)
    800023f4:	0005b083          	ld	ra,0(a1)
    800023f8:	0085b103          	ld	sp,8(a1)
    800023fc:	6980                	ld	s0,16(a1)
    800023fe:	6d84                	ld	s1,24(a1)
    80002400:	0205b903          	ld	s2,32(a1)
    80002404:	0285b983          	ld	s3,40(a1)
    80002408:	0305ba03          	ld	s4,48(a1)
    8000240c:	0385ba83          	ld	s5,56(a1)
    80002410:	0405bb03          	ld	s6,64(a1)
    80002414:	0485bb83          	ld	s7,72(a1)
    80002418:	0505bc03          	ld	s8,80(a1)
    8000241c:	0585bc83          	ld	s9,88(a1)
    80002420:	0605bd03          	ld	s10,96(a1)
    80002424:	0685bd83          	ld	s11,104(a1)
    80002428:	8082                	ret

000000008000242a <trapinit>:

extern int devintr();

void
trapinit(void)
{
    8000242a:	1141                	addi	sp,sp,-16
    8000242c:	e406                	sd	ra,8(sp)
    8000242e:	e022                	sd	s0,0(sp)
    80002430:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002432:	00005597          	auipc	a1,0x5
    80002436:	eb658593          	addi	a1,a1,-330 # 800072e8 <etext+0x2e8>
    8000243a:	00016517          	auipc	a0,0x16
    8000243e:	39650513          	addi	a0,a0,918 # 800187d0 <tickslock>
    80002442:	f32fe0ef          	jal	80000b74 <initlock>
}
    80002446:	60a2                	ld	ra,8(sp)
    80002448:	6402                	ld	s0,0(sp)
    8000244a:	0141                	addi	sp,sp,16
    8000244c:	8082                	ret

000000008000244e <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    8000244e:	1141                	addi	sp,sp,-16
    80002450:	e422                	sd	s0,8(sp)
    80002452:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002454:	00003797          	auipc	a5,0x3
    80002458:	e5c78793          	addi	a5,a5,-420 # 800052b0 <kernelvec>
    8000245c:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    80002460:	6422                	ld	s0,8(sp)
    80002462:	0141                	addi	sp,sp,16
    80002464:	8082                	ret

0000000080002466 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    80002466:	1141                	addi	sp,sp,-16
    80002468:	e406                	sd	ra,8(sp)
    8000246a:	e022                	sd	s0,0(sp)
    8000246c:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    8000246e:	c72ff0ef          	jal	800018e0 <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002472:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80002476:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002478:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    8000247c:	00004697          	auipc	a3,0x4
    80002480:	b8468693          	addi	a3,a3,-1148 # 80006000 <_trampoline>
    80002484:	00004717          	auipc	a4,0x4
    80002488:	b7c70713          	addi	a4,a4,-1156 # 80006000 <_trampoline>
    8000248c:	8f15                	sub	a4,a4,a3
    8000248e:	040007b7          	lui	a5,0x4000
    80002492:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    80002494:	07b2                	slli	a5,a5,0xc
    80002496:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002498:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    8000249c:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    8000249e:	18002673          	csrr	a2,satp
    800024a2:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800024a4:	6d30                	ld	a2,88(a0)
    800024a6:	6138                	ld	a4,64(a0)
    800024a8:	6585                	lui	a1,0x1
    800024aa:	972e                	add	a4,a4,a1
    800024ac:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800024ae:	6d38                	ld	a4,88(a0)
    800024b0:	00000617          	auipc	a2,0x0
    800024b4:	11060613          	addi	a2,a2,272 # 800025c0 <usertrap>
    800024b8:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    800024ba:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    800024bc:	8612                	mv	a2,tp
    800024be:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800024c0:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    800024c4:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    800024c8:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800024cc:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    800024d0:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    800024d2:	6f18                	ld	a4,24(a4)
    800024d4:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    800024d8:	6928                	ld	a0,80(a0)
    800024da:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    800024dc:	00004717          	auipc	a4,0x4
    800024e0:	bc070713          	addi	a4,a4,-1088 # 8000609c <userret>
    800024e4:	8f15                	sub	a4,a4,a3
    800024e6:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    800024e8:	577d                	li	a4,-1
    800024ea:	177e                	slli	a4,a4,0x3f
    800024ec:	8d59                	or	a0,a0,a4
    800024ee:	9782                	jalr	a5
}
    800024f0:	60a2                	ld	ra,8(sp)
    800024f2:	6402                	ld	s0,0(sp)
    800024f4:	0141                	addi	sp,sp,16
    800024f6:	8082                	ret

00000000800024f8 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    800024f8:	1101                	addi	sp,sp,-32
    800024fa:	ec06                	sd	ra,24(sp)
    800024fc:	e822                	sd	s0,16(sp)
    800024fe:	1000                	addi	s0,sp,32
  if(cpuid() == 0){
    80002500:	bb4ff0ef          	jal	800018b4 <cpuid>
    80002504:	cd11                	beqz	a0,80002520 <clockintr+0x28>
  asm volatile("csrr %0, time" : "=r" (x) );
    80002506:	c01027f3          	rdtime	a5
  }

  // ask for the next timer interrupt. this also clears
  // the interrupt request. 1000000 is about a tenth
  // of a second.
  w_stimecmp(r_time() + 1000000);
    8000250a:	000f4737          	lui	a4,0xf4
    8000250e:	24070713          	addi	a4,a4,576 # f4240 <_entry-0x7ff0bdc0>
    80002512:	97ba                	add	a5,a5,a4
  asm volatile("csrw 0x14d, %0" : : "r" (x));
    80002514:	14d79073          	csrw	stimecmp,a5
}
    80002518:	60e2                	ld	ra,24(sp)
    8000251a:	6442                	ld	s0,16(sp)
    8000251c:	6105                	addi	sp,sp,32
    8000251e:	8082                	ret
    80002520:	e426                	sd	s1,8(sp)
    acquire(&tickslock);
    80002522:	00016497          	auipc	s1,0x16
    80002526:	2ae48493          	addi	s1,s1,686 # 800187d0 <tickslock>
    8000252a:	8526                	mv	a0,s1
    8000252c:	ec8fe0ef          	jal	80000bf4 <acquire>
    ticks++;
    80002530:	00008517          	auipc	a0,0x8
    80002534:	d4050513          	addi	a0,a0,-704 # 8000a270 <ticks>
    80002538:	411c                	lw	a5,0(a0)
    8000253a:	2785                	addiw	a5,a5,1
    8000253c:	c11c                	sw	a5,0(a0)
    wakeup(&ticks);
    8000253e:	a3bff0ef          	jal	80001f78 <wakeup>
    release(&tickslock);
    80002542:	8526                	mv	a0,s1
    80002544:	f48fe0ef          	jal	80000c8c <release>
    80002548:	64a2                	ld	s1,8(sp)
    8000254a:	bf75                	j	80002506 <clockintr+0xe>

000000008000254c <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000254c:	1101                	addi	sp,sp,-32
    8000254e:	ec06                	sd	ra,24(sp)
    80002550:	e822                	sd	s0,16(sp)
    80002552:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002554:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if(scause == 0x8000000000000009L){
    80002558:	57fd                	li	a5,-1
    8000255a:	17fe                	slli	a5,a5,0x3f
    8000255c:	07a5                	addi	a5,a5,9
    8000255e:	00f70c63          	beq	a4,a5,80002576 <devintr+0x2a>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000005L){
    80002562:	57fd                	li	a5,-1
    80002564:	17fe                	slli	a5,a5,0x3f
    80002566:	0795                	addi	a5,a5,5
    // timer interrupt.
    clockintr();
    return 2;
  } else {
    return 0;
    80002568:	4501                	li	a0,0
  } else if(scause == 0x8000000000000005L){
    8000256a:	04f70763          	beq	a4,a5,800025b8 <devintr+0x6c>
  }
}
    8000256e:	60e2                	ld	ra,24(sp)
    80002570:	6442                	ld	s0,16(sp)
    80002572:	6105                	addi	sp,sp,32
    80002574:	8082                	ret
    80002576:	e426                	sd	s1,8(sp)
    int irq = plic_claim();
    80002578:	5e5020ef          	jal	8000535c <plic_claim>
    8000257c:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    8000257e:	47a9                	li	a5,10
    80002580:	00f50963          	beq	a0,a5,80002592 <devintr+0x46>
    } else if(irq == VIRTIO0_IRQ){
    80002584:	4785                	li	a5,1
    80002586:	00f50963          	beq	a0,a5,80002598 <devintr+0x4c>
    return 1;
    8000258a:	4505                	li	a0,1
    } else if(irq){
    8000258c:	e889                	bnez	s1,8000259e <devintr+0x52>
    8000258e:	64a2                	ld	s1,8(sp)
    80002590:	bff9                	j	8000256e <devintr+0x22>
      uartintr();
    80002592:	c74fe0ef          	jal	80000a06 <uartintr>
    if(irq)
    80002596:	a819                	j	800025ac <devintr+0x60>
      virtio_disk_intr();
    80002598:	28a030ef          	jal	80005822 <virtio_disk_intr>
    if(irq)
    8000259c:	a801                	j	800025ac <devintr+0x60>
      printf("unexpected interrupt irq=%d\n", irq);
    8000259e:	85a6                	mv	a1,s1
    800025a0:	00005517          	auipc	a0,0x5
    800025a4:	d5050513          	addi	a0,a0,-688 # 800072f0 <etext+0x2f0>
    800025a8:	f1bfd0ef          	jal	800004c2 <printf>
      plic_complete(irq);
    800025ac:	8526                	mv	a0,s1
    800025ae:	5cf020ef          	jal	8000537c <plic_complete>
    return 1;
    800025b2:	4505                	li	a0,1
    800025b4:	64a2                	ld	s1,8(sp)
    800025b6:	bf65                	j	8000256e <devintr+0x22>
    clockintr();
    800025b8:	f41ff0ef          	jal	800024f8 <clockintr>
    return 2;
    800025bc:	4509                	li	a0,2
    800025be:	bf45                	j	8000256e <devintr+0x22>

00000000800025c0 <usertrap>:
{
    800025c0:	1101                	addi	sp,sp,-32
    800025c2:	ec06                	sd	ra,24(sp)
    800025c4:	e822                	sd	s0,16(sp)
    800025c6:	e426                	sd	s1,8(sp)
    800025c8:	e04a                	sd	s2,0(sp)
    800025ca:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800025cc:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    800025d0:	1007f793          	andi	a5,a5,256
    800025d4:	ef85                	bnez	a5,8000260c <usertrap+0x4c>
  asm volatile("csrw stvec, %0" : : "r" (x));
    800025d6:	00003797          	auipc	a5,0x3
    800025da:	cda78793          	addi	a5,a5,-806 # 800052b0 <kernelvec>
    800025de:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    800025e2:	afeff0ef          	jal	800018e0 <myproc>
    800025e6:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    800025e8:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800025ea:	14102773          	csrr	a4,sepc
    800025ee:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    800025f0:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    800025f4:	47a1                	li	a5,8
    800025f6:	02f70163          	beq	a4,a5,80002618 <usertrap+0x58>
  } else if((which_dev = devintr()) != 0){
    800025fa:	f53ff0ef          	jal	8000254c <devintr>
    800025fe:	892a                	mv	s2,a0
    80002600:	c135                	beqz	a0,80002664 <usertrap+0xa4>
  if(killed(p))
    80002602:	8526                	mv	a0,s1
    80002604:	b61ff0ef          	jal	80002164 <killed>
    80002608:	cd1d                	beqz	a0,80002646 <usertrap+0x86>
    8000260a:	a81d                	j	80002640 <usertrap+0x80>
    panic("usertrap: not from user mode");
    8000260c:	00005517          	auipc	a0,0x5
    80002610:	d0450513          	addi	a0,a0,-764 # 80007310 <etext+0x310>
    80002614:	980fe0ef          	jal	80000794 <panic>
    if(killed(p))
    80002618:	b4dff0ef          	jal	80002164 <killed>
    8000261c:	e121                	bnez	a0,8000265c <usertrap+0x9c>
    p->trapframe->epc += 4;
    8000261e:	6cb8                	ld	a4,88(s1)
    80002620:	6f1c                	ld	a5,24(a4)
    80002622:	0791                	addi	a5,a5,4
    80002624:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002626:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    8000262a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000262e:	10079073          	csrw	sstatus,a5
    syscall();
    80002632:	248000ef          	jal	8000287a <syscall>
  if(killed(p))
    80002636:	8526                	mv	a0,s1
    80002638:	b2dff0ef          	jal	80002164 <killed>
    8000263c:	c901                	beqz	a0,8000264c <usertrap+0x8c>
    8000263e:	4901                	li	s2,0
    exit(-1);
    80002640:	557d                	li	a0,-1
    80002642:	9f7ff0ef          	jal	80002038 <exit>
  if(which_dev == 2)
    80002646:	4789                	li	a5,2
    80002648:	04f90563          	beq	s2,a5,80002692 <usertrap+0xd2>
  usertrapret();
    8000264c:	e1bff0ef          	jal	80002466 <usertrapret>
}
    80002650:	60e2                	ld	ra,24(sp)
    80002652:	6442                	ld	s0,16(sp)
    80002654:	64a2                	ld	s1,8(sp)
    80002656:	6902                	ld	s2,0(sp)
    80002658:	6105                	addi	sp,sp,32
    8000265a:	8082                	ret
      exit(-1);
    8000265c:	557d                	li	a0,-1
    8000265e:	9dbff0ef          	jal	80002038 <exit>
    80002662:	bf75                	j	8000261e <usertrap+0x5e>
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002664:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause 0x%lx pid=%d\n", r_scause(), p->pid);
    80002668:	5890                	lw	a2,48(s1)
    8000266a:	00005517          	auipc	a0,0x5
    8000266e:	cc650513          	addi	a0,a0,-826 # 80007330 <etext+0x330>
    80002672:	e51fd0ef          	jal	800004c2 <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002676:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    8000267a:	14302673          	csrr	a2,stval
    printf("            sepc=0x%lx stval=0x%lx\n", r_sepc(), r_stval());
    8000267e:	00005517          	auipc	a0,0x5
    80002682:	ce250513          	addi	a0,a0,-798 # 80007360 <etext+0x360>
    80002686:	e3dfd0ef          	jal	800004c2 <printf>
    setkilled(p);
    8000268a:	8526                	mv	a0,s1
    8000268c:	ab5ff0ef          	jal	80002140 <setkilled>
    80002690:	b75d                	j	80002636 <usertrap+0x76>
    yield();
    80002692:	86fff0ef          	jal	80001f00 <yield>
    80002696:	bf5d                	j	8000264c <usertrap+0x8c>

0000000080002698 <kerneltrap>:
{
    80002698:	7179                	addi	sp,sp,-48
    8000269a:	f406                	sd	ra,40(sp)
    8000269c:	f022                	sd	s0,32(sp)
    8000269e:	ec26                	sd	s1,24(sp)
    800026a0:	e84a                	sd	s2,16(sp)
    800026a2:	e44e                	sd	s3,8(sp)
    800026a4:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800026a6:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026aa:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    800026ae:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    800026b2:	1004f793          	andi	a5,s1,256
    800026b6:	c795                	beqz	a5,800026e2 <kerneltrap+0x4a>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800026b8:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800026bc:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    800026be:	eb85                	bnez	a5,800026ee <kerneltrap+0x56>
  if((which_dev = devintr()) == 0){
    800026c0:	e8dff0ef          	jal	8000254c <devintr>
    800026c4:	c91d                	beqz	a0,800026fa <kerneltrap+0x62>
  if(which_dev == 2 && myproc() != 0)
    800026c6:	4789                	li	a5,2
    800026c8:	04f50a63          	beq	a0,a5,8000271c <kerneltrap+0x84>
  asm volatile("csrw sepc, %0" : : "r" (x));
    800026cc:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800026d0:	10049073          	csrw	sstatus,s1
}
    800026d4:	70a2                	ld	ra,40(sp)
    800026d6:	7402                	ld	s0,32(sp)
    800026d8:	64e2                	ld	s1,24(sp)
    800026da:	6942                	ld	s2,16(sp)
    800026dc:	69a2                	ld	s3,8(sp)
    800026de:	6145                	addi	sp,sp,48
    800026e0:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    800026e2:	00005517          	auipc	a0,0x5
    800026e6:	ca650513          	addi	a0,a0,-858 # 80007388 <etext+0x388>
    800026ea:	8aafe0ef          	jal	80000794 <panic>
    panic("kerneltrap: interrupts enabled");
    800026ee:	00005517          	auipc	a0,0x5
    800026f2:	cc250513          	addi	a0,a0,-830 # 800073b0 <etext+0x3b0>
    800026f6:	89efe0ef          	jal	80000794 <panic>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    800026fa:	14102673          	csrr	a2,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    800026fe:	143026f3          	csrr	a3,stval
    printf("scause=0x%lx sepc=0x%lx stval=0x%lx\n", scause, r_sepc(), r_stval());
    80002702:	85ce                	mv	a1,s3
    80002704:	00005517          	auipc	a0,0x5
    80002708:	ccc50513          	addi	a0,a0,-820 # 800073d0 <etext+0x3d0>
    8000270c:	db7fd0ef          	jal	800004c2 <printf>
    panic("kerneltrap");
    80002710:	00005517          	auipc	a0,0x5
    80002714:	ce850513          	addi	a0,a0,-792 # 800073f8 <etext+0x3f8>
    80002718:	87cfe0ef          	jal	80000794 <panic>
  if(which_dev == 2 && myproc() != 0)
    8000271c:	9c4ff0ef          	jal	800018e0 <myproc>
    80002720:	d555                	beqz	a0,800026cc <kerneltrap+0x34>
    yield();
    80002722:	fdeff0ef          	jal	80001f00 <yield>
    80002726:	b75d                	j	800026cc <kerneltrap+0x34>

0000000080002728 <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002728:	1101                	addi	sp,sp,-32
    8000272a:	ec06                	sd	ra,24(sp)
    8000272c:	e822                	sd	s0,16(sp)
    8000272e:	e426                	sd	s1,8(sp)
    80002730:	1000                	addi	s0,sp,32
    80002732:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002734:	9acff0ef          	jal	800018e0 <myproc>
  switch (n) {
    80002738:	4795                	li	a5,5
    8000273a:	0497e163          	bltu	a5,s1,8000277c <argraw+0x54>
    8000273e:	048a                	slli	s1,s1,0x2
    80002740:	00005717          	auipc	a4,0x5
    80002744:	07870713          	addi	a4,a4,120 # 800077b8 <states.0+0x30>
    80002748:	94ba                	add	s1,s1,a4
    8000274a:	409c                	lw	a5,0(s1)
    8000274c:	97ba                	add	a5,a5,a4
    8000274e:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002750:	6d3c                	ld	a5,88(a0)
    80002752:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002754:	60e2                	ld	ra,24(sp)
    80002756:	6442                	ld	s0,16(sp)
    80002758:	64a2                	ld	s1,8(sp)
    8000275a:	6105                	addi	sp,sp,32
    8000275c:	8082                	ret
    return p->trapframe->a1;
    8000275e:	6d3c                	ld	a5,88(a0)
    80002760:	7fa8                	ld	a0,120(a5)
    80002762:	bfcd                	j	80002754 <argraw+0x2c>
    return p->trapframe->a2;
    80002764:	6d3c                	ld	a5,88(a0)
    80002766:	63c8                	ld	a0,128(a5)
    80002768:	b7f5                	j	80002754 <argraw+0x2c>
    return p->trapframe->a3;
    8000276a:	6d3c                	ld	a5,88(a0)
    8000276c:	67c8                	ld	a0,136(a5)
    8000276e:	b7dd                	j	80002754 <argraw+0x2c>
    return p->trapframe->a4;
    80002770:	6d3c                	ld	a5,88(a0)
    80002772:	6bc8                	ld	a0,144(a5)
    80002774:	b7c5                	j	80002754 <argraw+0x2c>
    return p->trapframe->a5;
    80002776:	6d3c                	ld	a5,88(a0)
    80002778:	6fc8                	ld	a0,152(a5)
    8000277a:	bfe9                	j	80002754 <argraw+0x2c>
  panic("argraw");
    8000277c:	00005517          	auipc	a0,0x5
    80002780:	c8c50513          	addi	a0,a0,-884 # 80007408 <etext+0x408>
    80002784:	810fe0ef          	jal	80000794 <panic>

0000000080002788 <fetchaddr>:
{
    80002788:	1101                	addi	sp,sp,-32
    8000278a:	ec06                	sd	ra,24(sp)
    8000278c:	e822                	sd	s0,16(sp)
    8000278e:	e426                	sd	s1,8(sp)
    80002790:	e04a                	sd	s2,0(sp)
    80002792:	1000                	addi	s0,sp,32
    80002794:	84aa                	mv	s1,a0
    80002796:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002798:	948ff0ef          	jal	800018e0 <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    8000279c:	653c                	ld	a5,72(a0)
    8000279e:	02f4f663          	bgeu	s1,a5,800027ca <fetchaddr+0x42>
    800027a2:	00848713          	addi	a4,s1,8
    800027a6:	02e7e463          	bltu	a5,a4,800027ce <fetchaddr+0x46>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    800027aa:	46a1                	li	a3,8
    800027ac:	8626                	mv	a2,s1
    800027ae:	85ca                	mv	a1,s2
    800027b0:	6928                	ld	a0,80(a0)
    800027b2:	e77fe0ef          	jal	80001628 <copyin>
    800027b6:	00a03533          	snez	a0,a0
    800027ba:	40a00533          	neg	a0,a0
}
    800027be:	60e2                	ld	ra,24(sp)
    800027c0:	6442                	ld	s0,16(sp)
    800027c2:	64a2                	ld	s1,8(sp)
    800027c4:	6902                	ld	s2,0(sp)
    800027c6:	6105                	addi	sp,sp,32
    800027c8:	8082                	ret
    return -1;
    800027ca:	557d                	li	a0,-1
    800027cc:	bfcd                	j	800027be <fetchaddr+0x36>
    800027ce:	557d                	li	a0,-1
    800027d0:	b7fd                	j	800027be <fetchaddr+0x36>

00000000800027d2 <fetchstr>:
{
    800027d2:	7179                	addi	sp,sp,-48
    800027d4:	f406                	sd	ra,40(sp)
    800027d6:	f022                	sd	s0,32(sp)
    800027d8:	ec26                	sd	s1,24(sp)
    800027da:	e84a                	sd	s2,16(sp)
    800027dc:	e44e                	sd	s3,8(sp)
    800027de:	1800                	addi	s0,sp,48
    800027e0:	892a                	mv	s2,a0
    800027e2:	84ae                	mv	s1,a1
    800027e4:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    800027e6:	8faff0ef          	jal	800018e0 <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    800027ea:	86ce                	mv	a3,s3
    800027ec:	864a                	mv	a2,s2
    800027ee:	85a6                	mv	a1,s1
    800027f0:	6928                	ld	a0,80(a0)
    800027f2:	ebdfe0ef          	jal	800016ae <copyinstr>
    800027f6:	00054c63          	bltz	a0,8000280e <fetchstr+0x3c>
  return strlen(buf);
    800027fa:	8526                	mv	a0,s1
    800027fc:	e3cfe0ef          	jal	80000e38 <strlen>
}
    80002800:	70a2                	ld	ra,40(sp)
    80002802:	7402                	ld	s0,32(sp)
    80002804:	64e2                	ld	s1,24(sp)
    80002806:	6942                	ld	s2,16(sp)
    80002808:	69a2                	ld	s3,8(sp)
    8000280a:	6145                	addi	sp,sp,48
    8000280c:	8082                	ret
    return -1;
    8000280e:	557d                	li	a0,-1
    80002810:	bfc5                	j	80002800 <fetchstr+0x2e>

0000000080002812 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002812:	1101                	addi	sp,sp,-32
    80002814:	ec06                	sd	ra,24(sp)
    80002816:	e822                	sd	s0,16(sp)
    80002818:	e426                	sd	s1,8(sp)
    8000281a:	1000                	addi	s0,sp,32
    8000281c:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000281e:	f0bff0ef          	jal	80002728 <argraw>
    80002822:	c088                	sw	a0,0(s1)
}
    80002824:	60e2                	ld	ra,24(sp)
    80002826:	6442                	ld	s0,16(sp)
    80002828:	64a2                	ld	s1,8(sp)
    8000282a:	6105                	addi	sp,sp,32
    8000282c:	8082                	ret

000000008000282e <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    8000282e:	1101                	addi	sp,sp,-32
    80002830:	ec06                	sd	ra,24(sp)
    80002832:	e822                	sd	s0,16(sp)
    80002834:	e426                	sd	s1,8(sp)
    80002836:	1000                	addi	s0,sp,32
    80002838:	84ae                	mv	s1,a1
  *ip = argraw(n);
    8000283a:	eefff0ef          	jal	80002728 <argraw>
    8000283e:	e088                	sd	a0,0(s1)
}
    80002840:	60e2                	ld	ra,24(sp)
    80002842:	6442                	ld	s0,16(sp)
    80002844:	64a2                	ld	s1,8(sp)
    80002846:	6105                	addi	sp,sp,32
    80002848:	8082                	ret

000000008000284a <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    8000284a:	7179                	addi	sp,sp,-48
    8000284c:	f406                	sd	ra,40(sp)
    8000284e:	f022                	sd	s0,32(sp)
    80002850:	ec26                	sd	s1,24(sp)
    80002852:	e84a                	sd	s2,16(sp)
    80002854:	1800                	addi	s0,sp,48
    80002856:	84ae                	mv	s1,a1
    80002858:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    8000285a:	fd840593          	addi	a1,s0,-40
    8000285e:	fd1ff0ef          	jal	8000282e <argaddr>
  return fetchstr(addr, buf, max);
    80002862:	864a                	mv	a2,s2
    80002864:	85a6                	mv	a1,s1
    80002866:	fd843503          	ld	a0,-40(s0)
    8000286a:	f69ff0ef          	jal	800027d2 <fetchstr>
}
    8000286e:	70a2                	ld	ra,40(sp)
    80002870:	7402                	ld	s0,32(sp)
    80002872:	64e2                	ld	s1,24(sp)
    80002874:	6942                	ld	s2,16(sp)
    80002876:	6145                	addi	sp,sp,48
    80002878:	8082                	ret

000000008000287a <syscall>:
[SYS_close]   sys_close,
};

void
syscall(void)
{
    8000287a:	1101                	addi	sp,sp,-32
    8000287c:	ec06                	sd	ra,24(sp)
    8000287e:	e822                	sd	s0,16(sp)
    80002880:	e426                	sd	s1,8(sp)
    80002882:	e04a                	sd	s2,0(sp)
    80002884:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002886:	85aff0ef          	jal	800018e0 <myproc>
    8000288a:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    8000288c:	05853903          	ld	s2,88(a0)
    80002890:	0a893783          	ld	a5,168(s2)
    80002894:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002898:	37fd                	addiw	a5,a5,-1
    8000289a:	4751                	li	a4,20
    8000289c:	00f76f63          	bltu	a4,a5,800028ba <syscall+0x40>
    800028a0:	00369713          	slli	a4,a3,0x3
    800028a4:	00005797          	auipc	a5,0x5
    800028a8:	f2c78793          	addi	a5,a5,-212 # 800077d0 <syscalls>
    800028ac:	97ba                	add	a5,a5,a4
    800028ae:	639c                	ld	a5,0(a5)
    800028b0:	c789                	beqz	a5,800028ba <syscall+0x40>
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    800028b2:	9782                	jalr	a5
    800028b4:	06a93823          	sd	a0,112(s2)
    800028b8:	a829                	j	800028d2 <syscall+0x58>
  } else {
    printf("%d %s: unknown sys call %d\n",
    800028ba:	15848613          	addi	a2,s1,344
    800028be:	588c                	lw	a1,48(s1)
    800028c0:	00005517          	auipc	a0,0x5
    800028c4:	b5050513          	addi	a0,a0,-1200 # 80007410 <etext+0x410>
    800028c8:	bfbfd0ef          	jal	800004c2 <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    800028cc:	6cbc                	ld	a5,88(s1)
    800028ce:	577d                	li	a4,-1
    800028d0:	fbb8                	sd	a4,112(a5)
  }
}
    800028d2:	60e2                	ld	ra,24(sp)
    800028d4:	6442                	ld	s0,16(sp)
    800028d6:	64a2                	ld	s1,8(sp)
    800028d8:	6902                	ld	s2,0(sp)
    800028da:	6105                	addi	sp,sp,32
    800028dc:	8082                	ret

00000000800028de <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    800028de:	1101                	addi	sp,sp,-32
    800028e0:	ec06                	sd	ra,24(sp)
    800028e2:	e822                	sd	s0,16(sp)
    800028e4:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    800028e6:	fec40593          	addi	a1,s0,-20
    800028ea:	4501                	li	a0,0
    800028ec:	f27ff0ef          	jal	80002812 <argint>
  exit(n);
    800028f0:	fec42503          	lw	a0,-20(s0)
    800028f4:	f44ff0ef          	jal	80002038 <exit>
  return 0;  // not reached
}
    800028f8:	4501                	li	a0,0
    800028fa:	60e2                	ld	ra,24(sp)
    800028fc:	6442                	ld	s0,16(sp)
    800028fe:	6105                	addi	sp,sp,32
    80002900:	8082                	ret

0000000080002902 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002902:	1141                	addi	sp,sp,-16
    80002904:	e406                	sd	ra,8(sp)
    80002906:	e022                	sd	s0,0(sp)
    80002908:	0800                	addi	s0,sp,16
  return myproc()->pid;
    8000290a:	fd7fe0ef          	jal	800018e0 <myproc>
}
    8000290e:	5908                	lw	a0,48(a0)
    80002910:	60a2                	ld	ra,8(sp)
    80002912:	6402                	ld	s0,0(sp)
    80002914:	0141                	addi	sp,sp,16
    80002916:	8082                	ret

0000000080002918 <sys_fork>:

uint64
sys_fork(void)
{
    80002918:	1141                	addi	sp,sp,-16
    8000291a:	e406                	sd	ra,8(sp)
    8000291c:	e022                	sd	s0,0(sp)
    8000291e:	0800                	addi	s0,sp,16
  return fork();
    80002920:	af6ff0ef          	jal	80001c16 <fork>
}
    80002924:	60a2                	ld	ra,8(sp)
    80002926:	6402                	ld	s0,0(sp)
    80002928:	0141                	addi	sp,sp,16
    8000292a:	8082                	ret

000000008000292c <sys_wait>:

uint64
sys_wait(void)
{
    8000292c:	1101                	addi	sp,sp,-32
    8000292e:	ec06                	sd	ra,24(sp)
    80002930:	e822                	sd	s0,16(sp)
    80002932:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002934:	fe840593          	addi	a1,s0,-24
    80002938:	4501                	li	a0,0
    8000293a:	ef5ff0ef          	jal	8000282e <argaddr>
  return wait(p);
    8000293e:	fe843503          	ld	a0,-24(s0)
    80002942:	84dff0ef          	jal	8000218e <wait>
}
    80002946:	60e2                	ld	ra,24(sp)
    80002948:	6442                	ld	s0,16(sp)
    8000294a:	6105                	addi	sp,sp,32
    8000294c:	8082                	ret

000000008000294e <sys_sbrk>:

uint64
sys_sbrk(void)
{
    8000294e:	7179                	addi	sp,sp,-48
    80002950:	f406                	sd	ra,40(sp)
    80002952:	f022                	sd	s0,32(sp)
    80002954:	ec26                	sd	s1,24(sp)
    80002956:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002958:	fdc40593          	addi	a1,s0,-36
    8000295c:	4501                	li	a0,0
    8000295e:	eb5ff0ef          	jal	80002812 <argint>
  addr = myproc()->sz;
    80002962:	f7ffe0ef          	jal	800018e0 <myproc>
    80002966:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002968:	fdc42503          	lw	a0,-36(s0)
    8000296c:	a5aff0ef          	jal	80001bc6 <growproc>
    80002970:	00054863          	bltz	a0,80002980 <sys_sbrk+0x32>
    return -1;
  return addr;
}
    80002974:	8526                	mv	a0,s1
    80002976:	70a2                	ld	ra,40(sp)
    80002978:	7402                	ld	s0,32(sp)
    8000297a:	64e2                	ld	s1,24(sp)
    8000297c:	6145                	addi	sp,sp,48
    8000297e:	8082                	ret
    return -1;
    80002980:	54fd                	li	s1,-1
    80002982:	bfcd                	j	80002974 <sys_sbrk+0x26>

0000000080002984 <sys_sleep>:

uint64
sys_sleep(void)
{
    80002984:	7139                	addi	sp,sp,-64
    80002986:	fc06                	sd	ra,56(sp)
    80002988:	f822                	sd	s0,48(sp)
    8000298a:	f04a                	sd	s2,32(sp)
    8000298c:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    8000298e:	fcc40593          	addi	a1,s0,-52
    80002992:	4501                	li	a0,0
    80002994:	e7fff0ef          	jal	80002812 <argint>
  if(n < 0)
    80002998:	fcc42783          	lw	a5,-52(s0)
    8000299c:	0607c763          	bltz	a5,80002a0a <sys_sleep+0x86>
    n = 0;
  acquire(&tickslock);
    800029a0:	00016517          	auipc	a0,0x16
    800029a4:	e3050513          	addi	a0,a0,-464 # 800187d0 <tickslock>
    800029a8:	a4cfe0ef          	jal	80000bf4 <acquire>
  ticks0 = ticks;
    800029ac:	00008917          	auipc	s2,0x8
    800029b0:	8c492903          	lw	s2,-1852(s2) # 8000a270 <ticks>
  while(ticks - ticks0 < n){
    800029b4:	fcc42783          	lw	a5,-52(s0)
    800029b8:	cf8d                	beqz	a5,800029f2 <sys_sleep+0x6e>
    800029ba:	f426                	sd	s1,40(sp)
    800029bc:	ec4e                	sd	s3,24(sp)
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    800029be:	00016997          	auipc	s3,0x16
    800029c2:	e1298993          	addi	s3,s3,-494 # 800187d0 <tickslock>
    800029c6:	00008497          	auipc	s1,0x8
    800029ca:	8aa48493          	addi	s1,s1,-1878 # 8000a270 <ticks>
    if(killed(myproc())){
    800029ce:	f13fe0ef          	jal	800018e0 <myproc>
    800029d2:	f92ff0ef          	jal	80002164 <killed>
    800029d6:	ed0d                	bnez	a0,80002a10 <sys_sleep+0x8c>
    sleep(&ticks, &tickslock);
    800029d8:	85ce                	mv	a1,s3
    800029da:	8526                	mv	a0,s1
    800029dc:	d50ff0ef          	jal	80001f2c <sleep>
  while(ticks - ticks0 < n){
    800029e0:	409c                	lw	a5,0(s1)
    800029e2:	412787bb          	subw	a5,a5,s2
    800029e6:	fcc42703          	lw	a4,-52(s0)
    800029ea:	fee7e2e3          	bltu	a5,a4,800029ce <sys_sleep+0x4a>
    800029ee:	74a2                	ld	s1,40(sp)
    800029f0:	69e2                	ld	s3,24(sp)
  }
  release(&tickslock);
    800029f2:	00016517          	auipc	a0,0x16
    800029f6:	dde50513          	addi	a0,a0,-546 # 800187d0 <tickslock>
    800029fa:	a92fe0ef          	jal	80000c8c <release>
  return 0;
    800029fe:	4501                	li	a0,0
}
    80002a00:	70e2                	ld	ra,56(sp)
    80002a02:	7442                	ld	s0,48(sp)
    80002a04:	7902                	ld	s2,32(sp)
    80002a06:	6121                	addi	sp,sp,64
    80002a08:	8082                	ret
    n = 0;
    80002a0a:	fc042623          	sw	zero,-52(s0)
    80002a0e:	bf49                	j	800029a0 <sys_sleep+0x1c>
      release(&tickslock);
    80002a10:	00016517          	auipc	a0,0x16
    80002a14:	dc050513          	addi	a0,a0,-576 # 800187d0 <tickslock>
    80002a18:	a74fe0ef          	jal	80000c8c <release>
      return -1;
    80002a1c:	557d                	li	a0,-1
    80002a1e:	74a2                	ld	s1,40(sp)
    80002a20:	69e2                	ld	s3,24(sp)
    80002a22:	bff9                	j	80002a00 <sys_sleep+0x7c>

0000000080002a24 <sys_kill>:

uint64
sys_kill(void)
{
    80002a24:	1101                	addi	sp,sp,-32
    80002a26:	ec06                	sd	ra,24(sp)
    80002a28:	e822                	sd	s0,16(sp)
    80002a2a:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002a2c:	fec40593          	addi	a1,s0,-20
    80002a30:	4501                	li	a0,0
    80002a32:	de1ff0ef          	jal	80002812 <argint>
  return kill(pid);
    80002a36:	fec42503          	lw	a0,-20(s0)
    80002a3a:	ea0ff0ef          	jal	800020da <kill>
}
    80002a3e:	60e2                	ld	ra,24(sp)
    80002a40:	6442                	ld	s0,16(sp)
    80002a42:	6105                	addi	sp,sp,32
    80002a44:	8082                	ret

0000000080002a46 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002a46:	1101                	addi	sp,sp,-32
    80002a48:	ec06                	sd	ra,24(sp)
    80002a4a:	e822                	sd	s0,16(sp)
    80002a4c:	e426                	sd	s1,8(sp)
    80002a4e:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002a50:	00016517          	auipc	a0,0x16
    80002a54:	d8050513          	addi	a0,a0,-640 # 800187d0 <tickslock>
    80002a58:	99cfe0ef          	jal	80000bf4 <acquire>
  xticks = ticks;
    80002a5c:	00008497          	auipc	s1,0x8
    80002a60:	8144a483          	lw	s1,-2028(s1) # 8000a270 <ticks>
  release(&tickslock);
    80002a64:	00016517          	auipc	a0,0x16
    80002a68:	d6c50513          	addi	a0,a0,-660 # 800187d0 <tickslock>
    80002a6c:	a20fe0ef          	jal	80000c8c <release>
  return xticks;
}
    80002a70:	02049513          	slli	a0,s1,0x20
    80002a74:	9101                	srli	a0,a0,0x20
    80002a76:	60e2                	ld	ra,24(sp)
    80002a78:	6442                	ld	s0,16(sp)
    80002a7a:	64a2                	ld	s1,8(sp)
    80002a7c:	6105                	addi	sp,sp,32
    80002a7e:	8082                	ret

0000000080002a80 <sys_settickets>:

uint64
sys_settickets(void)
{
    80002a80:	7179                	addi	sp,sp,-48
    80002a82:	f406                	sd	ra,40(sp)
    80002a84:	f022                	sd	s0,32(sp)
    80002a86:	ec26                	sd	s1,24(sp)
    80002a88:	1800                	addi	s0,sp,48
  int n;
  struct proc *p = myproc();
    80002a8a:	e57fe0ef          	jal	800018e0 <myproc>
    80002a8e:	84aa                	mv	s1,a0

  argint(0, &n);
    80002a90:	fdc40593          	addi	a1,s0,-36
    80002a94:	4501                	li	a0,0
    80002a96:	d7dff0ef          	jal	80002812 <argint>

  if (n <= 0) {
    80002a9a:	fdc42783          	lw	a5,-36(s0)
    return -1;
    80002a9e:	557d                	li	a0,-1
  if (n <= 0) {
    80002aa0:	02f05663          	blez	a5,80002acc <sys_settickets+0x4c>
  }

  acquire(&p->lock);
    80002aa4:	8526                	mv	a0,s1
    80002aa6:	94efe0ef          	jal	80000bf4 <acquire>
  p->tickets = n;
    80002aaa:	fdc42783          	lw	a5,-36(s0)
    80002aae:	16f4a423          	sw	a5,360(s1)
  if (p->tickets > 0) {
    80002ab2:	00f05963          	blez	a5,80002ac4 <sys_settickets+0x44>
      p->stride = STRIDE_CONSTANT / p->tickets;
    80002ab6:	6709                	lui	a4,0x2
    80002ab8:	7107071b          	addiw	a4,a4,1808 # 2710 <_entry-0x7fffd8f0>
    80002abc:	02f7473b          	divw	a4,a4,a5
    80002ac0:	16e4b823          	sd	a4,368(s1)
  }
  release(&p->lock);
    80002ac4:	8526                	mv	a0,s1
    80002ac6:	9c6fe0ef          	jal	80000c8c <release>

  return 0;
    80002aca:	4501                	li	a0,0
}
    80002acc:	70a2                	ld	ra,40(sp)
    80002ace:	7402                	ld	s0,32(sp)
    80002ad0:	64e2                	ld	s1,24(sp)
    80002ad2:	6145                	addi	sp,sp,48
    80002ad4:	8082                	ret

0000000080002ad6 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80002ad6:	7179                	addi	sp,sp,-48
    80002ad8:	f406                	sd	ra,40(sp)
    80002ada:	f022                	sd	s0,32(sp)
    80002adc:	ec26                	sd	s1,24(sp)
    80002ade:	e84a                	sd	s2,16(sp)
    80002ae0:	e44e                	sd	s3,8(sp)
    80002ae2:	e052                	sd	s4,0(sp)
    80002ae4:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80002ae6:	00005597          	auipc	a1,0x5
    80002aea:	94a58593          	addi	a1,a1,-1718 # 80007430 <etext+0x430>
    80002aee:	00016517          	auipc	a0,0x16
    80002af2:	cfa50513          	addi	a0,a0,-774 # 800187e8 <bcache>
    80002af6:	87efe0ef          	jal	80000b74 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    80002afa:	0001e797          	auipc	a5,0x1e
    80002afe:	cee78793          	addi	a5,a5,-786 # 800207e8 <bcache+0x8000>
    80002b02:	0001e717          	auipc	a4,0x1e
    80002b06:	f4e70713          	addi	a4,a4,-178 # 80020a50 <bcache+0x8268>
    80002b0a:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    80002b0e:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002b12:	00016497          	auipc	s1,0x16
    80002b16:	cee48493          	addi	s1,s1,-786 # 80018800 <bcache+0x18>
    b->next = bcache.head.next;
    80002b1a:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    80002b1c:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    80002b1e:	00005a17          	auipc	s4,0x5
    80002b22:	91aa0a13          	addi	s4,s4,-1766 # 80007438 <etext+0x438>
    b->next = bcache.head.next;
    80002b26:	2b893783          	ld	a5,696(s2)
    80002b2a:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    80002b2c:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    80002b30:	85d2                	mv	a1,s4
    80002b32:	01048513          	addi	a0,s1,16
    80002b36:	248010ef          	jal	80003d7e <initsleeplock>
    bcache.head.next->prev = b;
    80002b3a:	2b893783          	ld	a5,696(s2)
    80002b3e:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    80002b40:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    80002b44:	45848493          	addi	s1,s1,1112
    80002b48:	fd349fe3          	bne	s1,s3,80002b26 <binit+0x50>
  }
}
    80002b4c:	70a2                	ld	ra,40(sp)
    80002b4e:	7402                	ld	s0,32(sp)
    80002b50:	64e2                	ld	s1,24(sp)
    80002b52:	6942                	ld	s2,16(sp)
    80002b54:	69a2                	ld	s3,8(sp)
    80002b56:	6a02                	ld	s4,0(sp)
    80002b58:	6145                	addi	sp,sp,48
    80002b5a:	8082                	ret

0000000080002b5c <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80002b5c:	7179                	addi	sp,sp,-48
    80002b5e:	f406                	sd	ra,40(sp)
    80002b60:	f022                	sd	s0,32(sp)
    80002b62:	ec26                	sd	s1,24(sp)
    80002b64:	e84a                	sd	s2,16(sp)
    80002b66:	e44e                	sd	s3,8(sp)
    80002b68:	1800                	addi	s0,sp,48
    80002b6a:	892a                	mv	s2,a0
    80002b6c:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80002b6e:	00016517          	auipc	a0,0x16
    80002b72:	c7a50513          	addi	a0,a0,-902 # 800187e8 <bcache>
    80002b76:	87efe0ef          	jal	80000bf4 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80002b7a:	0001e497          	auipc	s1,0x1e
    80002b7e:	f264b483          	ld	s1,-218(s1) # 80020aa0 <bcache+0x82b8>
    80002b82:	0001e797          	auipc	a5,0x1e
    80002b86:	ece78793          	addi	a5,a5,-306 # 80020a50 <bcache+0x8268>
    80002b8a:	02f48b63          	beq	s1,a5,80002bc0 <bread+0x64>
    80002b8e:	873e                	mv	a4,a5
    80002b90:	a021                	j	80002b98 <bread+0x3c>
    80002b92:	68a4                	ld	s1,80(s1)
    80002b94:	02e48663          	beq	s1,a4,80002bc0 <bread+0x64>
    if(b->dev == dev && b->blockno == blockno){
    80002b98:	449c                	lw	a5,8(s1)
    80002b9a:	ff279ce3          	bne	a5,s2,80002b92 <bread+0x36>
    80002b9e:	44dc                	lw	a5,12(s1)
    80002ba0:	ff3799e3          	bne	a5,s3,80002b92 <bread+0x36>
      b->refcnt++;
    80002ba4:	40bc                	lw	a5,64(s1)
    80002ba6:	2785                	addiw	a5,a5,1
    80002ba8:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002baa:	00016517          	auipc	a0,0x16
    80002bae:	c3e50513          	addi	a0,a0,-962 # 800187e8 <bcache>
    80002bb2:	8dafe0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    80002bb6:	01048513          	addi	a0,s1,16
    80002bba:	1fa010ef          	jal	80003db4 <acquiresleep>
      return b;
    80002bbe:	a889                	j	80002c10 <bread+0xb4>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002bc0:	0001e497          	auipc	s1,0x1e
    80002bc4:	ed84b483          	ld	s1,-296(s1) # 80020a98 <bcache+0x82b0>
    80002bc8:	0001e797          	auipc	a5,0x1e
    80002bcc:	e8878793          	addi	a5,a5,-376 # 80020a50 <bcache+0x8268>
    80002bd0:	00f48863          	beq	s1,a5,80002be0 <bread+0x84>
    80002bd4:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    80002bd6:	40bc                	lw	a5,64(s1)
    80002bd8:	cb91                	beqz	a5,80002bec <bread+0x90>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80002bda:	64a4                	ld	s1,72(s1)
    80002bdc:	fee49de3          	bne	s1,a4,80002bd6 <bread+0x7a>
  panic("bget: no buffers");
    80002be0:	00005517          	auipc	a0,0x5
    80002be4:	86050513          	addi	a0,a0,-1952 # 80007440 <etext+0x440>
    80002be8:	badfd0ef          	jal	80000794 <panic>
      b->dev = dev;
    80002bec:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    80002bf0:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    80002bf4:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    80002bf8:	4785                	li	a5,1
    80002bfa:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80002bfc:	00016517          	auipc	a0,0x16
    80002c00:	bec50513          	addi	a0,a0,-1044 # 800187e8 <bcache>
    80002c04:	888fe0ef          	jal	80000c8c <release>
      acquiresleep(&b->lock);
    80002c08:	01048513          	addi	a0,s1,16
    80002c0c:	1a8010ef          	jal	80003db4 <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    80002c10:	409c                	lw	a5,0(s1)
    80002c12:	cb89                	beqz	a5,80002c24 <bread+0xc8>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    80002c14:	8526                	mv	a0,s1
    80002c16:	70a2                	ld	ra,40(sp)
    80002c18:	7402                	ld	s0,32(sp)
    80002c1a:	64e2                	ld	s1,24(sp)
    80002c1c:	6942                	ld	s2,16(sp)
    80002c1e:	69a2                	ld	s3,8(sp)
    80002c20:	6145                	addi	sp,sp,48
    80002c22:	8082                	ret
    virtio_disk_rw(b, 0);
    80002c24:	4581                	li	a1,0
    80002c26:	8526                	mv	a0,s1
    80002c28:	1e9020ef          	jal	80005610 <virtio_disk_rw>
    b->valid = 1;
    80002c2c:	4785                	li	a5,1
    80002c2e:	c09c                	sw	a5,0(s1)
  return b;
    80002c30:	b7d5                	j	80002c14 <bread+0xb8>

0000000080002c32 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    80002c32:	1101                	addi	sp,sp,-32
    80002c34:	ec06                	sd	ra,24(sp)
    80002c36:	e822                	sd	s0,16(sp)
    80002c38:	e426                	sd	s1,8(sp)
    80002c3a:	1000                	addi	s0,sp,32
    80002c3c:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002c3e:	0541                	addi	a0,a0,16
    80002c40:	1f2010ef          	jal	80003e32 <holdingsleep>
    80002c44:	c911                	beqz	a0,80002c58 <bwrite+0x26>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80002c46:	4585                	li	a1,1
    80002c48:	8526                	mv	a0,s1
    80002c4a:	1c7020ef          	jal	80005610 <virtio_disk_rw>
}
    80002c4e:	60e2                	ld	ra,24(sp)
    80002c50:	6442                	ld	s0,16(sp)
    80002c52:	64a2                	ld	s1,8(sp)
    80002c54:	6105                	addi	sp,sp,32
    80002c56:	8082                	ret
    panic("bwrite");
    80002c58:	00005517          	auipc	a0,0x5
    80002c5c:	80050513          	addi	a0,a0,-2048 # 80007458 <etext+0x458>
    80002c60:	b35fd0ef          	jal	80000794 <panic>

0000000080002c64 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80002c64:	1101                	addi	sp,sp,-32
    80002c66:	ec06                	sd	ra,24(sp)
    80002c68:	e822                	sd	s0,16(sp)
    80002c6a:	e426                	sd	s1,8(sp)
    80002c6c:	e04a                	sd	s2,0(sp)
    80002c6e:	1000                	addi	s0,sp,32
    80002c70:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80002c72:	01050913          	addi	s2,a0,16
    80002c76:	854a                	mv	a0,s2
    80002c78:	1ba010ef          	jal	80003e32 <holdingsleep>
    80002c7c:	c135                	beqz	a0,80002ce0 <brelse+0x7c>
    panic("brelse");

  releasesleep(&b->lock);
    80002c7e:	854a                	mv	a0,s2
    80002c80:	17a010ef          	jal	80003dfa <releasesleep>

  acquire(&bcache.lock);
    80002c84:	00016517          	auipc	a0,0x16
    80002c88:	b6450513          	addi	a0,a0,-1180 # 800187e8 <bcache>
    80002c8c:	f69fd0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    80002c90:	40bc                	lw	a5,64(s1)
    80002c92:	37fd                	addiw	a5,a5,-1
    80002c94:	0007871b          	sext.w	a4,a5
    80002c98:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80002c9a:	e71d                	bnez	a4,80002cc8 <brelse+0x64>
    // no one is waiting for it.
    b->next->prev = b->prev;
    80002c9c:	68b8                	ld	a4,80(s1)
    80002c9e:	64bc                	ld	a5,72(s1)
    80002ca0:	e73c                	sd	a5,72(a4)
    b->prev->next = b->next;
    80002ca2:	68b8                	ld	a4,80(s1)
    80002ca4:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80002ca6:	0001e797          	auipc	a5,0x1e
    80002caa:	b4278793          	addi	a5,a5,-1214 # 800207e8 <bcache+0x8000>
    80002cae:	2b87b703          	ld	a4,696(a5)
    80002cb2:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80002cb4:	0001e717          	auipc	a4,0x1e
    80002cb8:	d9c70713          	addi	a4,a4,-612 # 80020a50 <bcache+0x8268>
    80002cbc:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    80002cbe:	2b87b703          	ld	a4,696(a5)
    80002cc2:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    80002cc4:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    80002cc8:	00016517          	auipc	a0,0x16
    80002ccc:	b2050513          	addi	a0,a0,-1248 # 800187e8 <bcache>
    80002cd0:	fbdfd0ef          	jal	80000c8c <release>
}
    80002cd4:	60e2                	ld	ra,24(sp)
    80002cd6:	6442                	ld	s0,16(sp)
    80002cd8:	64a2                	ld	s1,8(sp)
    80002cda:	6902                	ld	s2,0(sp)
    80002cdc:	6105                	addi	sp,sp,32
    80002cde:	8082                	ret
    panic("brelse");
    80002ce0:	00004517          	auipc	a0,0x4
    80002ce4:	78050513          	addi	a0,a0,1920 # 80007460 <etext+0x460>
    80002ce8:	aadfd0ef          	jal	80000794 <panic>

0000000080002cec <bpin>:

void
bpin(struct buf *b) {
    80002cec:	1101                	addi	sp,sp,-32
    80002cee:	ec06                	sd	ra,24(sp)
    80002cf0:	e822                	sd	s0,16(sp)
    80002cf2:	e426                	sd	s1,8(sp)
    80002cf4:	1000                	addi	s0,sp,32
    80002cf6:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002cf8:	00016517          	auipc	a0,0x16
    80002cfc:	af050513          	addi	a0,a0,-1296 # 800187e8 <bcache>
    80002d00:	ef5fd0ef          	jal	80000bf4 <acquire>
  b->refcnt++;
    80002d04:	40bc                	lw	a5,64(s1)
    80002d06:	2785                	addiw	a5,a5,1
    80002d08:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002d0a:	00016517          	auipc	a0,0x16
    80002d0e:	ade50513          	addi	a0,a0,-1314 # 800187e8 <bcache>
    80002d12:	f7bfd0ef          	jal	80000c8c <release>
}
    80002d16:	60e2                	ld	ra,24(sp)
    80002d18:	6442                	ld	s0,16(sp)
    80002d1a:	64a2                	ld	s1,8(sp)
    80002d1c:	6105                	addi	sp,sp,32
    80002d1e:	8082                	ret

0000000080002d20 <bunpin>:

void
bunpin(struct buf *b) {
    80002d20:	1101                	addi	sp,sp,-32
    80002d22:	ec06                	sd	ra,24(sp)
    80002d24:	e822                	sd	s0,16(sp)
    80002d26:	e426                	sd	s1,8(sp)
    80002d28:	1000                	addi	s0,sp,32
    80002d2a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    80002d2c:	00016517          	auipc	a0,0x16
    80002d30:	abc50513          	addi	a0,a0,-1348 # 800187e8 <bcache>
    80002d34:	ec1fd0ef          	jal	80000bf4 <acquire>
  b->refcnt--;
    80002d38:	40bc                	lw	a5,64(s1)
    80002d3a:	37fd                	addiw	a5,a5,-1
    80002d3c:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80002d3e:	00016517          	auipc	a0,0x16
    80002d42:	aaa50513          	addi	a0,a0,-1366 # 800187e8 <bcache>
    80002d46:	f47fd0ef          	jal	80000c8c <release>
}
    80002d4a:	60e2                	ld	ra,24(sp)
    80002d4c:	6442                	ld	s0,16(sp)
    80002d4e:	64a2                	ld	s1,8(sp)
    80002d50:	6105                	addi	sp,sp,32
    80002d52:	8082                	ret

0000000080002d54 <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    80002d54:	1101                	addi	sp,sp,-32
    80002d56:	ec06                	sd	ra,24(sp)
    80002d58:	e822                	sd	s0,16(sp)
    80002d5a:	e426                	sd	s1,8(sp)
    80002d5c:	e04a                	sd	s2,0(sp)
    80002d5e:	1000                	addi	s0,sp,32
    80002d60:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    80002d62:	00d5d59b          	srliw	a1,a1,0xd
    80002d66:	0001e797          	auipc	a5,0x1e
    80002d6a:	15e7a783          	lw	a5,350(a5) # 80020ec4 <sb+0x1c>
    80002d6e:	9dbd                	addw	a1,a1,a5
    80002d70:	dedff0ef          	jal	80002b5c <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80002d74:	0074f713          	andi	a4,s1,7
    80002d78:	4785                	li	a5,1
    80002d7a:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    80002d7e:	14ce                	slli	s1,s1,0x33
    80002d80:	90d9                	srli	s1,s1,0x36
    80002d82:	00950733          	add	a4,a0,s1
    80002d86:	05874703          	lbu	a4,88(a4)
    80002d8a:	00e7f6b3          	and	a3,a5,a4
    80002d8e:	c29d                	beqz	a3,80002db4 <bfree+0x60>
    80002d90:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    80002d92:	94aa                	add	s1,s1,a0
    80002d94:	fff7c793          	not	a5,a5
    80002d98:	8f7d                	and	a4,a4,a5
    80002d9a:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    80002d9e:	711000ef          	jal	80003cae <log_write>
  brelse(bp);
    80002da2:	854a                	mv	a0,s2
    80002da4:	ec1ff0ef          	jal	80002c64 <brelse>
}
    80002da8:	60e2                	ld	ra,24(sp)
    80002daa:	6442                	ld	s0,16(sp)
    80002dac:	64a2                	ld	s1,8(sp)
    80002dae:	6902                	ld	s2,0(sp)
    80002db0:	6105                	addi	sp,sp,32
    80002db2:	8082                	ret
    panic("freeing free block");
    80002db4:	00004517          	auipc	a0,0x4
    80002db8:	6b450513          	addi	a0,a0,1716 # 80007468 <etext+0x468>
    80002dbc:	9d9fd0ef          	jal	80000794 <panic>

0000000080002dc0 <balloc>:
{
    80002dc0:	711d                	addi	sp,sp,-96
    80002dc2:	ec86                	sd	ra,88(sp)
    80002dc4:	e8a2                	sd	s0,80(sp)
    80002dc6:	e4a6                	sd	s1,72(sp)
    80002dc8:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    80002dca:	0001e797          	auipc	a5,0x1e
    80002dce:	0e27a783          	lw	a5,226(a5) # 80020eac <sb+0x4>
    80002dd2:	0e078f63          	beqz	a5,80002ed0 <balloc+0x110>
    80002dd6:	e0ca                	sd	s2,64(sp)
    80002dd8:	fc4e                	sd	s3,56(sp)
    80002dda:	f852                	sd	s4,48(sp)
    80002ddc:	f456                	sd	s5,40(sp)
    80002dde:	f05a                	sd	s6,32(sp)
    80002de0:	ec5e                	sd	s7,24(sp)
    80002de2:	e862                	sd	s8,16(sp)
    80002de4:	e466                	sd	s9,8(sp)
    80002de6:	8baa                	mv	s7,a0
    80002de8:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    80002dea:	0001eb17          	auipc	s6,0x1e
    80002dee:	0beb0b13          	addi	s6,s6,190 # 80020ea8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002df2:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    80002df4:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002df6:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    80002df8:	6c89                	lui	s9,0x2
    80002dfa:	a0b5                	j	80002e66 <balloc+0xa6>
        bp->data[bi/8] |= m;  // Mark block in use.
    80002dfc:	97ca                	add	a5,a5,s2
    80002dfe:	8e55                	or	a2,a2,a3
    80002e00:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    80002e04:	854a                	mv	a0,s2
    80002e06:	6a9000ef          	jal	80003cae <log_write>
        brelse(bp);
    80002e0a:	854a                	mv	a0,s2
    80002e0c:	e59ff0ef          	jal	80002c64 <brelse>
  bp = bread(dev, bno);
    80002e10:	85a6                	mv	a1,s1
    80002e12:	855e                	mv	a0,s7
    80002e14:	d49ff0ef          	jal	80002b5c <bread>
    80002e18:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    80002e1a:	40000613          	li	a2,1024
    80002e1e:	4581                	li	a1,0
    80002e20:	05850513          	addi	a0,a0,88
    80002e24:	ea5fd0ef          	jal	80000cc8 <memset>
  log_write(bp);
    80002e28:	854a                	mv	a0,s2
    80002e2a:	685000ef          	jal	80003cae <log_write>
  brelse(bp);
    80002e2e:	854a                	mv	a0,s2
    80002e30:	e35ff0ef          	jal	80002c64 <brelse>
}
    80002e34:	6906                	ld	s2,64(sp)
    80002e36:	79e2                	ld	s3,56(sp)
    80002e38:	7a42                	ld	s4,48(sp)
    80002e3a:	7aa2                	ld	s5,40(sp)
    80002e3c:	7b02                	ld	s6,32(sp)
    80002e3e:	6be2                	ld	s7,24(sp)
    80002e40:	6c42                	ld	s8,16(sp)
    80002e42:	6ca2                	ld	s9,8(sp)
}
    80002e44:	8526                	mv	a0,s1
    80002e46:	60e6                	ld	ra,88(sp)
    80002e48:	6446                	ld	s0,80(sp)
    80002e4a:	64a6                	ld	s1,72(sp)
    80002e4c:	6125                	addi	sp,sp,96
    80002e4e:	8082                	ret
    brelse(bp);
    80002e50:	854a                	mv	a0,s2
    80002e52:	e13ff0ef          	jal	80002c64 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80002e56:	015c87bb          	addw	a5,s9,s5
    80002e5a:	00078a9b          	sext.w	s5,a5
    80002e5e:	004b2703          	lw	a4,4(s6)
    80002e62:	04eaff63          	bgeu	s5,a4,80002ec0 <balloc+0x100>
    bp = bread(dev, BBLOCK(b, sb));
    80002e66:	41fad79b          	sraiw	a5,s5,0x1f
    80002e6a:	0137d79b          	srliw	a5,a5,0x13
    80002e6e:	015787bb          	addw	a5,a5,s5
    80002e72:	40d7d79b          	sraiw	a5,a5,0xd
    80002e76:	01cb2583          	lw	a1,28(s6)
    80002e7a:	9dbd                	addw	a1,a1,a5
    80002e7c:	855e                	mv	a0,s7
    80002e7e:	cdfff0ef          	jal	80002b5c <bread>
    80002e82:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002e84:	004b2503          	lw	a0,4(s6)
    80002e88:	000a849b          	sext.w	s1,s5
    80002e8c:	8762                	mv	a4,s8
    80002e8e:	fca4f1e3          	bgeu	s1,a0,80002e50 <balloc+0x90>
      m = 1 << (bi % 8);
    80002e92:	00777693          	andi	a3,a4,7
    80002e96:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    80002e9a:	41f7579b          	sraiw	a5,a4,0x1f
    80002e9e:	01d7d79b          	srliw	a5,a5,0x1d
    80002ea2:	9fb9                	addw	a5,a5,a4
    80002ea4:	4037d79b          	sraiw	a5,a5,0x3
    80002ea8:	00f90633          	add	a2,s2,a5
    80002eac:	05864603          	lbu	a2,88(a2)
    80002eb0:	00c6f5b3          	and	a1,a3,a2
    80002eb4:	d5a1                	beqz	a1,80002dfc <balloc+0x3c>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    80002eb6:	2705                	addiw	a4,a4,1
    80002eb8:	2485                	addiw	s1,s1,1
    80002eba:	fd471ae3          	bne	a4,s4,80002e8e <balloc+0xce>
    80002ebe:	bf49                	j	80002e50 <balloc+0x90>
    80002ec0:	6906                	ld	s2,64(sp)
    80002ec2:	79e2                	ld	s3,56(sp)
    80002ec4:	7a42                	ld	s4,48(sp)
    80002ec6:	7aa2                	ld	s5,40(sp)
    80002ec8:	7b02                	ld	s6,32(sp)
    80002eca:	6be2                	ld	s7,24(sp)
    80002ecc:	6c42                	ld	s8,16(sp)
    80002ece:	6ca2                	ld	s9,8(sp)
  printf("balloc: out of blocks\n");
    80002ed0:	00004517          	auipc	a0,0x4
    80002ed4:	5b050513          	addi	a0,a0,1456 # 80007480 <etext+0x480>
    80002ed8:	deafd0ef          	jal	800004c2 <printf>
  return 0;
    80002edc:	4481                	li	s1,0
    80002ede:	b79d                	j	80002e44 <balloc+0x84>

0000000080002ee0 <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    80002ee0:	7179                	addi	sp,sp,-48
    80002ee2:	f406                	sd	ra,40(sp)
    80002ee4:	f022                	sd	s0,32(sp)
    80002ee6:	ec26                	sd	s1,24(sp)
    80002ee8:	e84a                	sd	s2,16(sp)
    80002eea:	e44e                	sd	s3,8(sp)
    80002eec:	1800                	addi	s0,sp,48
    80002eee:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    80002ef0:	47ad                	li	a5,11
    80002ef2:	02b7e663          	bltu	a5,a1,80002f1e <bmap+0x3e>
    if((addr = ip->addrs[bn]) == 0){
    80002ef6:	02059793          	slli	a5,a1,0x20
    80002efa:	01e7d593          	srli	a1,a5,0x1e
    80002efe:	00b504b3          	add	s1,a0,a1
    80002f02:	0504a903          	lw	s2,80(s1)
    80002f06:	06091a63          	bnez	s2,80002f7a <bmap+0x9a>
      addr = balloc(ip->dev);
    80002f0a:	4108                	lw	a0,0(a0)
    80002f0c:	eb5ff0ef          	jal	80002dc0 <balloc>
    80002f10:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002f14:	06090363          	beqz	s2,80002f7a <bmap+0x9a>
        return 0;
      ip->addrs[bn] = addr;
    80002f18:	0524a823          	sw	s2,80(s1)
    80002f1c:	a8b9                	j	80002f7a <bmap+0x9a>
    }
    return addr;
  }
  bn -= NDIRECT;
    80002f1e:	ff45849b          	addiw	s1,a1,-12
    80002f22:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80002f26:	0ff00793          	li	a5,255
    80002f2a:	06e7ee63          	bltu	a5,a4,80002fa6 <bmap+0xc6>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    80002f2e:	08052903          	lw	s2,128(a0)
    80002f32:	00091d63          	bnez	s2,80002f4c <bmap+0x6c>
      addr = balloc(ip->dev);
    80002f36:	4108                	lw	a0,0(a0)
    80002f38:	e89ff0ef          	jal	80002dc0 <balloc>
    80002f3c:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80002f40:	02090d63          	beqz	s2,80002f7a <bmap+0x9a>
    80002f44:	e052                	sd	s4,0(sp)
        return 0;
      ip->addrs[NDIRECT] = addr;
    80002f46:	0929a023          	sw	s2,128(s3)
    80002f4a:	a011                	j	80002f4e <bmap+0x6e>
    80002f4c:	e052                	sd	s4,0(sp)
    }
    bp = bread(ip->dev, addr);
    80002f4e:	85ca                	mv	a1,s2
    80002f50:	0009a503          	lw	a0,0(s3)
    80002f54:	c09ff0ef          	jal	80002b5c <bread>
    80002f58:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    80002f5a:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80002f5e:	02049713          	slli	a4,s1,0x20
    80002f62:	01e75593          	srli	a1,a4,0x1e
    80002f66:	00b784b3          	add	s1,a5,a1
    80002f6a:	0004a903          	lw	s2,0(s1)
    80002f6e:	00090e63          	beqz	s2,80002f8a <bmap+0xaa>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80002f72:	8552                	mv	a0,s4
    80002f74:	cf1ff0ef          	jal	80002c64 <brelse>
    return addr;
    80002f78:	6a02                	ld	s4,0(sp)
  }

  panic("bmap: out of range");
}
    80002f7a:	854a                	mv	a0,s2
    80002f7c:	70a2                	ld	ra,40(sp)
    80002f7e:	7402                	ld	s0,32(sp)
    80002f80:	64e2                	ld	s1,24(sp)
    80002f82:	6942                	ld	s2,16(sp)
    80002f84:	69a2                	ld	s3,8(sp)
    80002f86:	6145                	addi	sp,sp,48
    80002f88:	8082                	ret
      addr = balloc(ip->dev);
    80002f8a:	0009a503          	lw	a0,0(s3)
    80002f8e:	e33ff0ef          	jal	80002dc0 <balloc>
    80002f92:	0005091b          	sext.w	s2,a0
      if(addr){
    80002f96:	fc090ee3          	beqz	s2,80002f72 <bmap+0x92>
        a[bn] = addr;
    80002f9a:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    80002f9e:	8552                	mv	a0,s4
    80002fa0:	50f000ef          	jal	80003cae <log_write>
    80002fa4:	b7f9                	j	80002f72 <bmap+0x92>
    80002fa6:	e052                	sd	s4,0(sp)
  panic("bmap: out of range");
    80002fa8:	00004517          	auipc	a0,0x4
    80002fac:	4f050513          	addi	a0,a0,1264 # 80007498 <etext+0x498>
    80002fb0:	fe4fd0ef          	jal	80000794 <panic>

0000000080002fb4 <iget>:
{
    80002fb4:	7179                	addi	sp,sp,-48
    80002fb6:	f406                	sd	ra,40(sp)
    80002fb8:	f022                	sd	s0,32(sp)
    80002fba:	ec26                	sd	s1,24(sp)
    80002fbc:	e84a                	sd	s2,16(sp)
    80002fbe:	e44e                	sd	s3,8(sp)
    80002fc0:	e052                	sd	s4,0(sp)
    80002fc2:	1800                	addi	s0,sp,48
    80002fc4:	89aa                	mv	s3,a0
    80002fc6:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    80002fc8:	0001e517          	auipc	a0,0x1e
    80002fcc:	f0050513          	addi	a0,a0,-256 # 80020ec8 <itable>
    80002fd0:	c25fd0ef          	jal	80000bf4 <acquire>
  empty = 0;
    80002fd4:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002fd6:	0001e497          	auipc	s1,0x1e
    80002fda:	f0a48493          	addi	s1,s1,-246 # 80020ee0 <itable+0x18>
    80002fde:	00020697          	auipc	a3,0x20
    80002fe2:	99268693          	addi	a3,a3,-1646 # 80022970 <log>
    80002fe6:	a039                	j	80002ff4 <iget+0x40>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80002fe8:	02090963          	beqz	s2,8000301a <iget+0x66>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80002fec:	08848493          	addi	s1,s1,136
    80002ff0:	02d48863          	beq	s1,a3,80003020 <iget+0x6c>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80002ff4:	449c                	lw	a5,8(s1)
    80002ff6:	fef059e3          	blez	a5,80002fe8 <iget+0x34>
    80002ffa:	4098                	lw	a4,0(s1)
    80002ffc:	ff3716e3          	bne	a4,s3,80002fe8 <iget+0x34>
    80003000:	40d8                	lw	a4,4(s1)
    80003002:	ff4713e3          	bne	a4,s4,80002fe8 <iget+0x34>
      ip->ref++;
    80003006:	2785                	addiw	a5,a5,1
    80003008:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000300a:	0001e517          	auipc	a0,0x1e
    8000300e:	ebe50513          	addi	a0,a0,-322 # 80020ec8 <itable>
    80003012:	c7bfd0ef          	jal	80000c8c <release>
      return ip;
    80003016:	8926                	mv	s2,s1
    80003018:	a02d                	j	80003042 <iget+0x8e>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000301a:	fbe9                	bnez	a5,80002fec <iget+0x38>
      empty = ip;
    8000301c:	8926                	mv	s2,s1
    8000301e:	b7f9                	j	80002fec <iget+0x38>
  if(empty == 0)
    80003020:	02090a63          	beqz	s2,80003054 <iget+0xa0>
  ip->dev = dev;
    80003024:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003028:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    8000302c:	4785                	li	a5,1
    8000302e:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    80003032:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    80003036:	0001e517          	auipc	a0,0x1e
    8000303a:	e9250513          	addi	a0,a0,-366 # 80020ec8 <itable>
    8000303e:	c4ffd0ef          	jal	80000c8c <release>
}
    80003042:	854a                	mv	a0,s2
    80003044:	70a2                	ld	ra,40(sp)
    80003046:	7402                	ld	s0,32(sp)
    80003048:	64e2                	ld	s1,24(sp)
    8000304a:	6942                	ld	s2,16(sp)
    8000304c:	69a2                	ld	s3,8(sp)
    8000304e:	6a02                	ld	s4,0(sp)
    80003050:	6145                	addi	sp,sp,48
    80003052:	8082                	ret
    panic("iget: no inodes");
    80003054:	00004517          	auipc	a0,0x4
    80003058:	45c50513          	addi	a0,a0,1116 # 800074b0 <etext+0x4b0>
    8000305c:	f38fd0ef          	jal	80000794 <panic>

0000000080003060 <fsinit>:
fsinit(int dev) {
    80003060:	7179                	addi	sp,sp,-48
    80003062:	f406                	sd	ra,40(sp)
    80003064:	f022                	sd	s0,32(sp)
    80003066:	ec26                	sd	s1,24(sp)
    80003068:	e84a                	sd	s2,16(sp)
    8000306a:	e44e                	sd	s3,8(sp)
    8000306c:	1800                	addi	s0,sp,48
    8000306e:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    80003070:	4585                	li	a1,1
    80003072:	aebff0ef          	jal	80002b5c <bread>
    80003076:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    80003078:	0001e997          	auipc	s3,0x1e
    8000307c:	e3098993          	addi	s3,s3,-464 # 80020ea8 <sb>
    80003080:	02000613          	li	a2,32
    80003084:	05850593          	addi	a1,a0,88
    80003088:	854e                	mv	a0,s3
    8000308a:	c9bfd0ef          	jal	80000d24 <memmove>
  brelse(bp);
    8000308e:	8526                	mv	a0,s1
    80003090:	bd5ff0ef          	jal	80002c64 <brelse>
  if(sb.magic != FSMAGIC)
    80003094:	0009a703          	lw	a4,0(s3)
    80003098:	102037b7          	lui	a5,0x10203
    8000309c:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800030a0:	02f71063          	bne	a4,a5,800030c0 <fsinit+0x60>
  initlog(dev, &sb);
    800030a4:	0001e597          	auipc	a1,0x1e
    800030a8:	e0458593          	addi	a1,a1,-508 # 80020ea8 <sb>
    800030ac:	854a                	mv	a0,s2
    800030ae:	1f9000ef          	jal	80003aa6 <initlog>
}
    800030b2:	70a2                	ld	ra,40(sp)
    800030b4:	7402                	ld	s0,32(sp)
    800030b6:	64e2                	ld	s1,24(sp)
    800030b8:	6942                	ld	s2,16(sp)
    800030ba:	69a2                	ld	s3,8(sp)
    800030bc:	6145                	addi	sp,sp,48
    800030be:	8082                	ret
    panic("invalid file system");
    800030c0:	00004517          	auipc	a0,0x4
    800030c4:	40050513          	addi	a0,a0,1024 # 800074c0 <etext+0x4c0>
    800030c8:	eccfd0ef          	jal	80000794 <panic>

00000000800030cc <iinit>:
{
    800030cc:	7179                	addi	sp,sp,-48
    800030ce:	f406                	sd	ra,40(sp)
    800030d0:	f022                	sd	s0,32(sp)
    800030d2:	ec26                	sd	s1,24(sp)
    800030d4:	e84a                	sd	s2,16(sp)
    800030d6:	e44e                	sd	s3,8(sp)
    800030d8:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    800030da:	00004597          	auipc	a1,0x4
    800030de:	3fe58593          	addi	a1,a1,1022 # 800074d8 <etext+0x4d8>
    800030e2:	0001e517          	auipc	a0,0x1e
    800030e6:	de650513          	addi	a0,a0,-538 # 80020ec8 <itable>
    800030ea:	a8bfd0ef          	jal	80000b74 <initlock>
  for(i = 0; i < NINODE; i++) {
    800030ee:	0001e497          	auipc	s1,0x1e
    800030f2:	e0248493          	addi	s1,s1,-510 # 80020ef0 <itable+0x28>
    800030f6:	00020997          	auipc	s3,0x20
    800030fa:	88a98993          	addi	s3,s3,-1910 # 80022980 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    800030fe:	00004917          	auipc	s2,0x4
    80003102:	3e290913          	addi	s2,s2,994 # 800074e0 <etext+0x4e0>
    80003106:	85ca                	mv	a1,s2
    80003108:	8526                	mv	a0,s1
    8000310a:	475000ef          	jal	80003d7e <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000310e:	08848493          	addi	s1,s1,136
    80003112:	ff349ae3          	bne	s1,s3,80003106 <iinit+0x3a>
}
    80003116:	70a2                	ld	ra,40(sp)
    80003118:	7402                	ld	s0,32(sp)
    8000311a:	64e2                	ld	s1,24(sp)
    8000311c:	6942                	ld	s2,16(sp)
    8000311e:	69a2                	ld	s3,8(sp)
    80003120:	6145                	addi	sp,sp,48
    80003122:	8082                	ret

0000000080003124 <ialloc>:
{
    80003124:	7139                	addi	sp,sp,-64
    80003126:	fc06                	sd	ra,56(sp)
    80003128:	f822                	sd	s0,48(sp)
    8000312a:	0080                	addi	s0,sp,64
  for(inum = 1; inum < sb.ninodes; inum++){
    8000312c:	0001e717          	auipc	a4,0x1e
    80003130:	d8872703          	lw	a4,-632(a4) # 80020eb4 <sb+0xc>
    80003134:	4785                	li	a5,1
    80003136:	06e7f063          	bgeu	a5,a4,80003196 <ialloc+0x72>
    8000313a:	f426                	sd	s1,40(sp)
    8000313c:	f04a                	sd	s2,32(sp)
    8000313e:	ec4e                	sd	s3,24(sp)
    80003140:	e852                	sd	s4,16(sp)
    80003142:	e456                	sd	s5,8(sp)
    80003144:	e05a                	sd	s6,0(sp)
    80003146:	8aaa                	mv	s5,a0
    80003148:	8b2e                	mv	s6,a1
    8000314a:	4905                	li	s2,1
    bp = bread(dev, IBLOCK(inum, sb));
    8000314c:	0001ea17          	auipc	s4,0x1e
    80003150:	d5ca0a13          	addi	s4,s4,-676 # 80020ea8 <sb>
    80003154:	00495593          	srli	a1,s2,0x4
    80003158:	018a2783          	lw	a5,24(s4)
    8000315c:	9dbd                	addw	a1,a1,a5
    8000315e:	8556                	mv	a0,s5
    80003160:	9fdff0ef          	jal	80002b5c <bread>
    80003164:	84aa                	mv	s1,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    80003166:	05850993          	addi	s3,a0,88
    8000316a:	00f97793          	andi	a5,s2,15
    8000316e:	079a                	slli	a5,a5,0x6
    80003170:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    80003172:	00099783          	lh	a5,0(s3)
    80003176:	cb9d                	beqz	a5,800031ac <ialloc+0x88>
    brelse(bp);
    80003178:	aedff0ef          	jal	80002c64 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    8000317c:	0905                	addi	s2,s2,1
    8000317e:	00ca2703          	lw	a4,12(s4)
    80003182:	0009079b          	sext.w	a5,s2
    80003186:	fce7e7e3          	bltu	a5,a4,80003154 <ialloc+0x30>
    8000318a:	74a2                	ld	s1,40(sp)
    8000318c:	7902                	ld	s2,32(sp)
    8000318e:	69e2                	ld	s3,24(sp)
    80003190:	6a42                	ld	s4,16(sp)
    80003192:	6aa2                	ld	s5,8(sp)
    80003194:	6b02                	ld	s6,0(sp)
  printf("ialloc: no inodes\n");
    80003196:	00004517          	auipc	a0,0x4
    8000319a:	35250513          	addi	a0,a0,850 # 800074e8 <etext+0x4e8>
    8000319e:	b24fd0ef          	jal	800004c2 <printf>
  return 0;
    800031a2:	4501                	li	a0,0
}
    800031a4:	70e2                	ld	ra,56(sp)
    800031a6:	7442                	ld	s0,48(sp)
    800031a8:	6121                	addi	sp,sp,64
    800031aa:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    800031ac:	04000613          	li	a2,64
    800031b0:	4581                	li	a1,0
    800031b2:	854e                	mv	a0,s3
    800031b4:	b15fd0ef          	jal	80000cc8 <memset>
      dip->type = type;
    800031b8:	01699023          	sh	s6,0(s3)
      log_write(bp);   // mark it allocated on the disk
    800031bc:	8526                	mv	a0,s1
    800031be:	2f1000ef          	jal	80003cae <log_write>
      brelse(bp);
    800031c2:	8526                	mv	a0,s1
    800031c4:	aa1ff0ef          	jal	80002c64 <brelse>
      return iget(dev, inum);
    800031c8:	0009059b          	sext.w	a1,s2
    800031cc:	8556                	mv	a0,s5
    800031ce:	de7ff0ef          	jal	80002fb4 <iget>
    800031d2:	74a2                	ld	s1,40(sp)
    800031d4:	7902                	ld	s2,32(sp)
    800031d6:	69e2                	ld	s3,24(sp)
    800031d8:	6a42                	ld	s4,16(sp)
    800031da:	6aa2                	ld	s5,8(sp)
    800031dc:	6b02                	ld	s6,0(sp)
    800031de:	b7d9                	j	800031a4 <ialloc+0x80>

00000000800031e0 <iupdate>:
{
    800031e0:	1101                	addi	sp,sp,-32
    800031e2:	ec06                	sd	ra,24(sp)
    800031e4:	e822                	sd	s0,16(sp)
    800031e6:	e426                	sd	s1,8(sp)
    800031e8:	e04a                	sd	s2,0(sp)
    800031ea:	1000                	addi	s0,sp,32
    800031ec:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800031ee:	415c                	lw	a5,4(a0)
    800031f0:	0047d79b          	srliw	a5,a5,0x4
    800031f4:	0001e597          	auipc	a1,0x1e
    800031f8:	ccc5a583          	lw	a1,-820(a1) # 80020ec0 <sb+0x18>
    800031fc:	9dbd                	addw	a1,a1,a5
    800031fe:	4108                	lw	a0,0(a0)
    80003200:	95dff0ef          	jal	80002b5c <bread>
    80003204:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    80003206:	05850793          	addi	a5,a0,88
    8000320a:	40d8                	lw	a4,4(s1)
    8000320c:	8b3d                	andi	a4,a4,15
    8000320e:	071a                	slli	a4,a4,0x6
    80003210:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003212:	04449703          	lh	a4,68(s1)
    80003216:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    8000321a:	04649703          	lh	a4,70(s1)
    8000321e:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003222:	04849703          	lh	a4,72(s1)
    80003226:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    8000322a:	04a49703          	lh	a4,74(s1)
    8000322e:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    80003232:	44f8                	lw	a4,76(s1)
    80003234:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    80003236:	03400613          	li	a2,52
    8000323a:	05048593          	addi	a1,s1,80
    8000323e:	00c78513          	addi	a0,a5,12
    80003242:	ae3fd0ef          	jal	80000d24 <memmove>
  log_write(bp);
    80003246:	854a                	mv	a0,s2
    80003248:	267000ef          	jal	80003cae <log_write>
  brelse(bp);
    8000324c:	854a                	mv	a0,s2
    8000324e:	a17ff0ef          	jal	80002c64 <brelse>
}
    80003252:	60e2                	ld	ra,24(sp)
    80003254:	6442                	ld	s0,16(sp)
    80003256:	64a2                	ld	s1,8(sp)
    80003258:	6902                	ld	s2,0(sp)
    8000325a:	6105                	addi	sp,sp,32
    8000325c:	8082                	ret

000000008000325e <idup>:
{
    8000325e:	1101                	addi	sp,sp,-32
    80003260:	ec06                	sd	ra,24(sp)
    80003262:	e822                	sd	s0,16(sp)
    80003264:	e426                	sd	s1,8(sp)
    80003266:	1000                	addi	s0,sp,32
    80003268:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    8000326a:	0001e517          	auipc	a0,0x1e
    8000326e:	c5e50513          	addi	a0,a0,-930 # 80020ec8 <itable>
    80003272:	983fd0ef          	jal	80000bf4 <acquire>
  ip->ref++;
    80003276:	449c                	lw	a5,8(s1)
    80003278:	2785                	addiw	a5,a5,1
    8000327a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000327c:	0001e517          	auipc	a0,0x1e
    80003280:	c4c50513          	addi	a0,a0,-948 # 80020ec8 <itable>
    80003284:	a09fd0ef          	jal	80000c8c <release>
}
    80003288:	8526                	mv	a0,s1
    8000328a:	60e2                	ld	ra,24(sp)
    8000328c:	6442                	ld	s0,16(sp)
    8000328e:	64a2                	ld	s1,8(sp)
    80003290:	6105                	addi	sp,sp,32
    80003292:	8082                	ret

0000000080003294 <ilock>:
{
    80003294:	1101                	addi	sp,sp,-32
    80003296:	ec06                	sd	ra,24(sp)
    80003298:	e822                	sd	s0,16(sp)
    8000329a:	e426                	sd	s1,8(sp)
    8000329c:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000329e:	cd19                	beqz	a0,800032bc <ilock+0x28>
    800032a0:	84aa                	mv	s1,a0
    800032a2:	451c                	lw	a5,8(a0)
    800032a4:	00f05c63          	blez	a5,800032bc <ilock+0x28>
  acquiresleep(&ip->lock);
    800032a8:	0541                	addi	a0,a0,16
    800032aa:	30b000ef          	jal	80003db4 <acquiresleep>
  if(ip->valid == 0){
    800032ae:	40bc                	lw	a5,64(s1)
    800032b0:	cf89                	beqz	a5,800032ca <ilock+0x36>
}
    800032b2:	60e2                	ld	ra,24(sp)
    800032b4:	6442                	ld	s0,16(sp)
    800032b6:	64a2                	ld	s1,8(sp)
    800032b8:	6105                	addi	sp,sp,32
    800032ba:	8082                	ret
    800032bc:	e04a                	sd	s2,0(sp)
    panic("ilock");
    800032be:	00004517          	auipc	a0,0x4
    800032c2:	24250513          	addi	a0,a0,578 # 80007500 <etext+0x500>
    800032c6:	ccefd0ef          	jal	80000794 <panic>
    800032ca:	e04a                	sd	s2,0(sp)
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    800032cc:	40dc                	lw	a5,4(s1)
    800032ce:	0047d79b          	srliw	a5,a5,0x4
    800032d2:	0001e597          	auipc	a1,0x1e
    800032d6:	bee5a583          	lw	a1,-1042(a1) # 80020ec0 <sb+0x18>
    800032da:	9dbd                	addw	a1,a1,a5
    800032dc:	4088                	lw	a0,0(s1)
    800032de:	87fff0ef          	jal	80002b5c <bread>
    800032e2:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    800032e4:	05850593          	addi	a1,a0,88
    800032e8:	40dc                	lw	a5,4(s1)
    800032ea:	8bbd                	andi	a5,a5,15
    800032ec:	079a                	slli	a5,a5,0x6
    800032ee:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    800032f0:	00059783          	lh	a5,0(a1)
    800032f4:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    800032f8:	00259783          	lh	a5,2(a1)
    800032fc:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003300:	00459783          	lh	a5,4(a1)
    80003304:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    80003308:	00659783          	lh	a5,6(a1)
    8000330c:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    80003310:	459c                	lw	a5,8(a1)
    80003312:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    80003314:	03400613          	li	a2,52
    80003318:	05b1                	addi	a1,a1,12
    8000331a:	05048513          	addi	a0,s1,80
    8000331e:	a07fd0ef          	jal	80000d24 <memmove>
    brelse(bp);
    80003322:	854a                	mv	a0,s2
    80003324:	941ff0ef          	jal	80002c64 <brelse>
    ip->valid = 1;
    80003328:	4785                	li	a5,1
    8000332a:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    8000332c:	04449783          	lh	a5,68(s1)
    80003330:	c399                	beqz	a5,80003336 <ilock+0xa2>
    80003332:	6902                	ld	s2,0(sp)
    80003334:	bfbd                	j	800032b2 <ilock+0x1e>
      panic("ilock: no type");
    80003336:	00004517          	auipc	a0,0x4
    8000333a:	1d250513          	addi	a0,a0,466 # 80007508 <etext+0x508>
    8000333e:	c56fd0ef          	jal	80000794 <panic>

0000000080003342 <iunlock>:
{
    80003342:	1101                	addi	sp,sp,-32
    80003344:	ec06                	sd	ra,24(sp)
    80003346:	e822                	sd	s0,16(sp)
    80003348:	e426                	sd	s1,8(sp)
    8000334a:	e04a                	sd	s2,0(sp)
    8000334c:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    8000334e:	c505                	beqz	a0,80003376 <iunlock+0x34>
    80003350:	84aa                	mv	s1,a0
    80003352:	01050913          	addi	s2,a0,16
    80003356:	854a                	mv	a0,s2
    80003358:	2db000ef          	jal	80003e32 <holdingsleep>
    8000335c:	cd09                	beqz	a0,80003376 <iunlock+0x34>
    8000335e:	449c                	lw	a5,8(s1)
    80003360:	00f05b63          	blez	a5,80003376 <iunlock+0x34>
  releasesleep(&ip->lock);
    80003364:	854a                	mv	a0,s2
    80003366:	295000ef          	jal	80003dfa <releasesleep>
}
    8000336a:	60e2                	ld	ra,24(sp)
    8000336c:	6442                	ld	s0,16(sp)
    8000336e:	64a2                	ld	s1,8(sp)
    80003370:	6902                	ld	s2,0(sp)
    80003372:	6105                	addi	sp,sp,32
    80003374:	8082                	ret
    panic("iunlock");
    80003376:	00004517          	auipc	a0,0x4
    8000337a:	1a250513          	addi	a0,a0,418 # 80007518 <etext+0x518>
    8000337e:	c16fd0ef          	jal	80000794 <panic>

0000000080003382 <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003382:	7179                	addi	sp,sp,-48
    80003384:	f406                	sd	ra,40(sp)
    80003386:	f022                	sd	s0,32(sp)
    80003388:	ec26                	sd	s1,24(sp)
    8000338a:	e84a                	sd	s2,16(sp)
    8000338c:	e44e                	sd	s3,8(sp)
    8000338e:	1800                	addi	s0,sp,48
    80003390:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003392:	05050493          	addi	s1,a0,80
    80003396:	08050913          	addi	s2,a0,128
    8000339a:	a021                	j	800033a2 <itrunc+0x20>
    8000339c:	0491                	addi	s1,s1,4
    8000339e:	01248b63          	beq	s1,s2,800033b4 <itrunc+0x32>
    if(ip->addrs[i]){
    800033a2:	408c                	lw	a1,0(s1)
    800033a4:	dde5                	beqz	a1,8000339c <itrunc+0x1a>
      bfree(ip->dev, ip->addrs[i]);
    800033a6:	0009a503          	lw	a0,0(s3)
    800033aa:	9abff0ef          	jal	80002d54 <bfree>
      ip->addrs[i] = 0;
    800033ae:	0004a023          	sw	zero,0(s1)
    800033b2:	b7ed                	j	8000339c <itrunc+0x1a>
    }
  }

  if(ip->addrs[NDIRECT]){
    800033b4:	0809a583          	lw	a1,128(s3)
    800033b8:	ed89                	bnez	a1,800033d2 <itrunc+0x50>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    800033ba:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    800033be:	854e                	mv	a0,s3
    800033c0:	e21ff0ef          	jal	800031e0 <iupdate>
}
    800033c4:	70a2                	ld	ra,40(sp)
    800033c6:	7402                	ld	s0,32(sp)
    800033c8:	64e2                	ld	s1,24(sp)
    800033ca:	6942                	ld	s2,16(sp)
    800033cc:	69a2                	ld	s3,8(sp)
    800033ce:	6145                	addi	sp,sp,48
    800033d0:	8082                	ret
    800033d2:	e052                	sd	s4,0(sp)
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    800033d4:	0009a503          	lw	a0,0(s3)
    800033d8:	f84ff0ef          	jal	80002b5c <bread>
    800033dc:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    800033de:	05850493          	addi	s1,a0,88
    800033e2:	45850913          	addi	s2,a0,1112
    800033e6:	a021                	j	800033ee <itrunc+0x6c>
    800033e8:	0491                	addi	s1,s1,4
    800033ea:	01248963          	beq	s1,s2,800033fc <itrunc+0x7a>
      if(a[j])
    800033ee:	408c                	lw	a1,0(s1)
    800033f0:	dde5                	beqz	a1,800033e8 <itrunc+0x66>
        bfree(ip->dev, a[j]);
    800033f2:	0009a503          	lw	a0,0(s3)
    800033f6:	95fff0ef          	jal	80002d54 <bfree>
    800033fa:	b7fd                	j	800033e8 <itrunc+0x66>
    brelse(bp);
    800033fc:	8552                	mv	a0,s4
    800033fe:	867ff0ef          	jal	80002c64 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003402:	0809a583          	lw	a1,128(s3)
    80003406:	0009a503          	lw	a0,0(s3)
    8000340a:	94bff0ef          	jal	80002d54 <bfree>
    ip->addrs[NDIRECT] = 0;
    8000340e:	0809a023          	sw	zero,128(s3)
    80003412:	6a02                	ld	s4,0(sp)
    80003414:	b75d                	j	800033ba <itrunc+0x38>

0000000080003416 <iput>:
{
    80003416:	1101                	addi	sp,sp,-32
    80003418:	ec06                	sd	ra,24(sp)
    8000341a:	e822                	sd	s0,16(sp)
    8000341c:	e426                	sd	s1,8(sp)
    8000341e:	1000                	addi	s0,sp,32
    80003420:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003422:	0001e517          	auipc	a0,0x1e
    80003426:	aa650513          	addi	a0,a0,-1370 # 80020ec8 <itable>
    8000342a:	fcafd0ef          	jal	80000bf4 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    8000342e:	4498                	lw	a4,8(s1)
    80003430:	4785                	li	a5,1
    80003432:	02f70063          	beq	a4,a5,80003452 <iput+0x3c>
  ip->ref--;
    80003436:	449c                	lw	a5,8(s1)
    80003438:	37fd                	addiw	a5,a5,-1
    8000343a:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    8000343c:	0001e517          	auipc	a0,0x1e
    80003440:	a8c50513          	addi	a0,a0,-1396 # 80020ec8 <itable>
    80003444:	849fd0ef          	jal	80000c8c <release>
}
    80003448:	60e2                	ld	ra,24(sp)
    8000344a:	6442                	ld	s0,16(sp)
    8000344c:	64a2                	ld	s1,8(sp)
    8000344e:	6105                	addi	sp,sp,32
    80003450:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003452:	40bc                	lw	a5,64(s1)
    80003454:	d3ed                	beqz	a5,80003436 <iput+0x20>
    80003456:	04a49783          	lh	a5,74(s1)
    8000345a:	fff1                	bnez	a5,80003436 <iput+0x20>
    8000345c:	e04a                	sd	s2,0(sp)
    acquiresleep(&ip->lock);
    8000345e:	01048913          	addi	s2,s1,16
    80003462:	854a                	mv	a0,s2
    80003464:	151000ef          	jal	80003db4 <acquiresleep>
    release(&itable.lock);
    80003468:	0001e517          	auipc	a0,0x1e
    8000346c:	a6050513          	addi	a0,a0,-1440 # 80020ec8 <itable>
    80003470:	81dfd0ef          	jal	80000c8c <release>
    itrunc(ip);
    80003474:	8526                	mv	a0,s1
    80003476:	f0dff0ef          	jal	80003382 <itrunc>
    ip->type = 0;
    8000347a:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    8000347e:	8526                	mv	a0,s1
    80003480:	d61ff0ef          	jal	800031e0 <iupdate>
    ip->valid = 0;
    80003484:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003488:	854a                	mv	a0,s2
    8000348a:	171000ef          	jal	80003dfa <releasesleep>
    acquire(&itable.lock);
    8000348e:	0001e517          	auipc	a0,0x1e
    80003492:	a3a50513          	addi	a0,a0,-1478 # 80020ec8 <itable>
    80003496:	f5efd0ef          	jal	80000bf4 <acquire>
    8000349a:	6902                	ld	s2,0(sp)
    8000349c:	bf69                	j	80003436 <iput+0x20>

000000008000349e <iunlockput>:
{
    8000349e:	1101                	addi	sp,sp,-32
    800034a0:	ec06                	sd	ra,24(sp)
    800034a2:	e822                	sd	s0,16(sp)
    800034a4:	e426                	sd	s1,8(sp)
    800034a6:	1000                	addi	s0,sp,32
    800034a8:	84aa                	mv	s1,a0
  iunlock(ip);
    800034aa:	e99ff0ef          	jal	80003342 <iunlock>
  iput(ip);
    800034ae:	8526                	mv	a0,s1
    800034b0:	f67ff0ef          	jal	80003416 <iput>
}
    800034b4:	60e2                	ld	ra,24(sp)
    800034b6:	6442                	ld	s0,16(sp)
    800034b8:	64a2                	ld	s1,8(sp)
    800034ba:	6105                	addi	sp,sp,32
    800034bc:	8082                	ret

00000000800034be <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    800034be:	1141                	addi	sp,sp,-16
    800034c0:	e422                	sd	s0,8(sp)
    800034c2:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    800034c4:	411c                	lw	a5,0(a0)
    800034c6:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    800034c8:	415c                	lw	a5,4(a0)
    800034ca:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    800034cc:	04451783          	lh	a5,68(a0)
    800034d0:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    800034d4:	04a51783          	lh	a5,74(a0)
    800034d8:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    800034dc:	04c56783          	lwu	a5,76(a0)
    800034e0:	e99c                	sd	a5,16(a1)
}
    800034e2:	6422                	ld	s0,8(sp)
    800034e4:	0141                	addi	sp,sp,16
    800034e6:	8082                	ret

00000000800034e8 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800034e8:	457c                	lw	a5,76(a0)
    800034ea:	0ed7eb63          	bltu	a5,a3,800035e0 <readi+0xf8>
{
    800034ee:	7159                	addi	sp,sp,-112
    800034f0:	f486                	sd	ra,104(sp)
    800034f2:	f0a2                	sd	s0,96(sp)
    800034f4:	eca6                	sd	s1,88(sp)
    800034f6:	e0d2                	sd	s4,64(sp)
    800034f8:	fc56                	sd	s5,56(sp)
    800034fa:	f85a                	sd	s6,48(sp)
    800034fc:	f45e                	sd	s7,40(sp)
    800034fe:	1880                	addi	s0,sp,112
    80003500:	8b2a                	mv	s6,a0
    80003502:	8bae                	mv	s7,a1
    80003504:	8a32                	mv	s4,a2
    80003506:	84b6                	mv	s1,a3
    80003508:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    8000350a:	9f35                	addw	a4,a4,a3
    return 0;
    8000350c:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    8000350e:	0cd76063          	bltu	a4,a3,800035ce <readi+0xe6>
    80003512:	e4ce                	sd	s3,72(sp)
  if(off + n > ip->size)
    80003514:	00e7f463          	bgeu	a5,a4,8000351c <readi+0x34>
    n = ip->size - off;
    80003518:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    8000351c:	080a8f63          	beqz	s5,800035ba <readi+0xd2>
    80003520:	e8ca                	sd	s2,80(sp)
    80003522:	f062                	sd	s8,32(sp)
    80003524:	ec66                	sd	s9,24(sp)
    80003526:	e86a                	sd	s10,16(sp)
    80003528:	e46e                	sd	s11,8(sp)
    8000352a:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    8000352c:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003530:	5c7d                	li	s8,-1
    80003532:	a80d                	j	80003564 <readi+0x7c>
    80003534:	020d1d93          	slli	s11,s10,0x20
    80003538:	020ddd93          	srli	s11,s11,0x20
    8000353c:	05890613          	addi	a2,s2,88
    80003540:	86ee                	mv	a3,s11
    80003542:	963a                	add	a2,a2,a4
    80003544:	85d2                	mv	a1,s4
    80003546:	855e                	mv	a0,s7
    80003548:	d41fe0ef          	jal	80002288 <either_copyout>
    8000354c:	05850763          	beq	a0,s8,8000359a <readi+0xb2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003550:	854a                	mv	a0,s2
    80003552:	f12ff0ef          	jal	80002c64 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003556:	013d09bb          	addw	s3,s10,s3
    8000355a:	009d04bb          	addw	s1,s10,s1
    8000355e:	9a6e                	add	s4,s4,s11
    80003560:	0559f763          	bgeu	s3,s5,800035ae <readi+0xc6>
    uint addr = bmap(ip, off/BSIZE);
    80003564:	00a4d59b          	srliw	a1,s1,0xa
    80003568:	855a                	mv	a0,s6
    8000356a:	977ff0ef          	jal	80002ee0 <bmap>
    8000356e:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003572:	c5b1                	beqz	a1,800035be <readi+0xd6>
    bp = bread(ip->dev, addr);
    80003574:	000b2503          	lw	a0,0(s6)
    80003578:	de4ff0ef          	jal	80002b5c <bread>
    8000357c:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    8000357e:	3ff4f713          	andi	a4,s1,1023
    80003582:	40ec87bb          	subw	a5,s9,a4
    80003586:	413a86bb          	subw	a3,s5,s3
    8000358a:	8d3e                	mv	s10,a5
    8000358c:	2781                	sext.w	a5,a5
    8000358e:	0006861b          	sext.w	a2,a3
    80003592:	faf671e3          	bgeu	a2,a5,80003534 <readi+0x4c>
    80003596:	8d36                	mv	s10,a3
    80003598:	bf71                	j	80003534 <readi+0x4c>
      brelse(bp);
    8000359a:	854a                	mv	a0,s2
    8000359c:	ec8ff0ef          	jal	80002c64 <brelse>
      tot = -1;
    800035a0:	59fd                	li	s3,-1
      break;
    800035a2:	6946                	ld	s2,80(sp)
    800035a4:	7c02                	ld	s8,32(sp)
    800035a6:	6ce2                	ld	s9,24(sp)
    800035a8:	6d42                	ld	s10,16(sp)
    800035aa:	6da2                	ld	s11,8(sp)
    800035ac:	a831                	j	800035c8 <readi+0xe0>
    800035ae:	6946                	ld	s2,80(sp)
    800035b0:	7c02                	ld	s8,32(sp)
    800035b2:	6ce2                	ld	s9,24(sp)
    800035b4:	6d42                	ld	s10,16(sp)
    800035b6:	6da2                	ld	s11,8(sp)
    800035b8:	a801                	j	800035c8 <readi+0xe0>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    800035ba:	89d6                	mv	s3,s5
    800035bc:	a031                	j	800035c8 <readi+0xe0>
    800035be:	6946                	ld	s2,80(sp)
    800035c0:	7c02                	ld	s8,32(sp)
    800035c2:	6ce2                	ld	s9,24(sp)
    800035c4:	6d42                	ld	s10,16(sp)
    800035c6:	6da2                	ld	s11,8(sp)
  }
  return tot;
    800035c8:	0009851b          	sext.w	a0,s3
    800035cc:	69a6                	ld	s3,72(sp)
}
    800035ce:	70a6                	ld	ra,104(sp)
    800035d0:	7406                	ld	s0,96(sp)
    800035d2:	64e6                	ld	s1,88(sp)
    800035d4:	6a06                	ld	s4,64(sp)
    800035d6:	7ae2                	ld	s5,56(sp)
    800035d8:	7b42                	ld	s6,48(sp)
    800035da:	7ba2                	ld	s7,40(sp)
    800035dc:	6165                	addi	sp,sp,112
    800035de:	8082                	ret
    return 0;
    800035e0:	4501                	li	a0,0
}
    800035e2:	8082                	ret

00000000800035e4 <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    800035e4:	457c                	lw	a5,76(a0)
    800035e6:	10d7e063          	bltu	a5,a3,800036e6 <writei+0x102>
{
    800035ea:	7159                	addi	sp,sp,-112
    800035ec:	f486                	sd	ra,104(sp)
    800035ee:	f0a2                	sd	s0,96(sp)
    800035f0:	e8ca                	sd	s2,80(sp)
    800035f2:	e0d2                	sd	s4,64(sp)
    800035f4:	fc56                	sd	s5,56(sp)
    800035f6:	f85a                	sd	s6,48(sp)
    800035f8:	f45e                	sd	s7,40(sp)
    800035fa:	1880                	addi	s0,sp,112
    800035fc:	8aaa                	mv	s5,a0
    800035fe:	8bae                	mv	s7,a1
    80003600:	8a32                	mv	s4,a2
    80003602:	8936                	mv	s2,a3
    80003604:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003606:	00e687bb          	addw	a5,a3,a4
    8000360a:	0ed7e063          	bltu	a5,a3,800036ea <writei+0x106>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    8000360e:	00043737          	lui	a4,0x43
    80003612:	0cf76e63          	bltu	a4,a5,800036ee <writei+0x10a>
    80003616:	e4ce                	sd	s3,72(sp)
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003618:	0a0b0f63          	beqz	s6,800036d6 <writei+0xf2>
    8000361c:	eca6                	sd	s1,88(sp)
    8000361e:	f062                	sd	s8,32(sp)
    80003620:	ec66                	sd	s9,24(sp)
    80003622:	e86a                	sd	s10,16(sp)
    80003624:	e46e                	sd	s11,8(sp)
    80003626:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003628:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    8000362c:	5c7d                	li	s8,-1
    8000362e:	a825                	j	80003666 <writei+0x82>
    80003630:	020d1d93          	slli	s11,s10,0x20
    80003634:	020ddd93          	srli	s11,s11,0x20
    80003638:	05848513          	addi	a0,s1,88
    8000363c:	86ee                	mv	a3,s11
    8000363e:	8652                	mv	a2,s4
    80003640:	85de                	mv	a1,s7
    80003642:	953a                	add	a0,a0,a4
    80003644:	c8ffe0ef          	jal	800022d2 <either_copyin>
    80003648:	05850a63          	beq	a0,s8,8000369c <writei+0xb8>
      brelse(bp);
      break;
    }
    log_write(bp);
    8000364c:	8526                	mv	a0,s1
    8000364e:	660000ef          	jal	80003cae <log_write>
    brelse(bp);
    80003652:	8526                	mv	a0,s1
    80003654:	e10ff0ef          	jal	80002c64 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003658:	013d09bb          	addw	s3,s10,s3
    8000365c:	012d093b          	addw	s2,s10,s2
    80003660:	9a6e                	add	s4,s4,s11
    80003662:	0569f063          	bgeu	s3,s6,800036a2 <writei+0xbe>
    uint addr = bmap(ip, off/BSIZE);
    80003666:	00a9559b          	srliw	a1,s2,0xa
    8000366a:	8556                	mv	a0,s5
    8000366c:	875ff0ef          	jal	80002ee0 <bmap>
    80003670:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003674:	c59d                	beqz	a1,800036a2 <writei+0xbe>
    bp = bread(ip->dev, addr);
    80003676:	000aa503          	lw	a0,0(s5)
    8000367a:	ce2ff0ef          	jal	80002b5c <bread>
    8000367e:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003680:	3ff97713          	andi	a4,s2,1023
    80003684:	40ec87bb          	subw	a5,s9,a4
    80003688:	413b06bb          	subw	a3,s6,s3
    8000368c:	8d3e                	mv	s10,a5
    8000368e:	2781                	sext.w	a5,a5
    80003690:	0006861b          	sext.w	a2,a3
    80003694:	f8f67ee3          	bgeu	a2,a5,80003630 <writei+0x4c>
    80003698:	8d36                	mv	s10,a3
    8000369a:	bf59                	j	80003630 <writei+0x4c>
      brelse(bp);
    8000369c:	8526                	mv	a0,s1
    8000369e:	dc6ff0ef          	jal	80002c64 <brelse>
  }

  if(off > ip->size)
    800036a2:	04caa783          	lw	a5,76(s5)
    800036a6:	0327fa63          	bgeu	a5,s2,800036da <writei+0xf6>
    ip->size = off;
    800036aa:	052aa623          	sw	s2,76(s5)
    800036ae:	64e6                	ld	s1,88(sp)
    800036b0:	7c02                	ld	s8,32(sp)
    800036b2:	6ce2                	ld	s9,24(sp)
    800036b4:	6d42                	ld	s10,16(sp)
    800036b6:	6da2                	ld	s11,8(sp)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    800036b8:	8556                	mv	a0,s5
    800036ba:	b27ff0ef          	jal	800031e0 <iupdate>

  return tot;
    800036be:	0009851b          	sext.w	a0,s3
    800036c2:	69a6                	ld	s3,72(sp)
}
    800036c4:	70a6                	ld	ra,104(sp)
    800036c6:	7406                	ld	s0,96(sp)
    800036c8:	6946                	ld	s2,80(sp)
    800036ca:	6a06                	ld	s4,64(sp)
    800036cc:	7ae2                	ld	s5,56(sp)
    800036ce:	7b42                	ld	s6,48(sp)
    800036d0:	7ba2                	ld	s7,40(sp)
    800036d2:	6165                	addi	sp,sp,112
    800036d4:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    800036d6:	89da                	mv	s3,s6
    800036d8:	b7c5                	j	800036b8 <writei+0xd4>
    800036da:	64e6                	ld	s1,88(sp)
    800036dc:	7c02                	ld	s8,32(sp)
    800036de:	6ce2                	ld	s9,24(sp)
    800036e0:	6d42                	ld	s10,16(sp)
    800036e2:	6da2                	ld	s11,8(sp)
    800036e4:	bfd1                	j	800036b8 <writei+0xd4>
    return -1;
    800036e6:	557d                	li	a0,-1
}
    800036e8:	8082                	ret
    return -1;
    800036ea:	557d                	li	a0,-1
    800036ec:	bfe1                	j	800036c4 <writei+0xe0>
    return -1;
    800036ee:	557d                	li	a0,-1
    800036f0:	bfd1                	j	800036c4 <writei+0xe0>

00000000800036f2 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    800036f2:	1141                	addi	sp,sp,-16
    800036f4:	e406                	sd	ra,8(sp)
    800036f6:	e022                	sd	s0,0(sp)
    800036f8:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    800036fa:	4639                	li	a2,14
    800036fc:	e98fd0ef          	jal	80000d94 <strncmp>
}
    80003700:	60a2                	ld	ra,8(sp)
    80003702:	6402                	ld	s0,0(sp)
    80003704:	0141                	addi	sp,sp,16
    80003706:	8082                	ret

0000000080003708 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003708:	7139                	addi	sp,sp,-64
    8000370a:	fc06                	sd	ra,56(sp)
    8000370c:	f822                	sd	s0,48(sp)
    8000370e:	f426                	sd	s1,40(sp)
    80003710:	f04a                	sd	s2,32(sp)
    80003712:	ec4e                	sd	s3,24(sp)
    80003714:	e852                	sd	s4,16(sp)
    80003716:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003718:	04451703          	lh	a4,68(a0)
    8000371c:	4785                	li	a5,1
    8000371e:	00f71a63          	bne	a4,a5,80003732 <dirlookup+0x2a>
    80003722:	892a                	mv	s2,a0
    80003724:	89ae                	mv	s3,a1
    80003726:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003728:	457c                	lw	a5,76(a0)
    8000372a:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    8000372c:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000372e:	e39d                	bnez	a5,80003754 <dirlookup+0x4c>
    80003730:	a095                	j	80003794 <dirlookup+0x8c>
    panic("dirlookup not DIR");
    80003732:	00004517          	auipc	a0,0x4
    80003736:	dee50513          	addi	a0,a0,-530 # 80007520 <etext+0x520>
    8000373a:	85afd0ef          	jal	80000794 <panic>
      panic("dirlookup read");
    8000373e:	00004517          	auipc	a0,0x4
    80003742:	dfa50513          	addi	a0,a0,-518 # 80007538 <etext+0x538>
    80003746:	84efd0ef          	jal	80000794 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000374a:	24c1                	addiw	s1,s1,16
    8000374c:	04c92783          	lw	a5,76(s2)
    80003750:	04f4f163          	bgeu	s1,a5,80003792 <dirlookup+0x8a>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003754:	4741                	li	a4,16
    80003756:	86a6                	mv	a3,s1
    80003758:	fc040613          	addi	a2,s0,-64
    8000375c:	4581                	li	a1,0
    8000375e:	854a                	mv	a0,s2
    80003760:	d89ff0ef          	jal	800034e8 <readi>
    80003764:	47c1                	li	a5,16
    80003766:	fcf51ce3          	bne	a0,a5,8000373e <dirlookup+0x36>
    if(de.inum == 0)
    8000376a:	fc045783          	lhu	a5,-64(s0)
    8000376e:	dff1                	beqz	a5,8000374a <dirlookup+0x42>
    if(namecmp(name, de.name) == 0){
    80003770:	fc240593          	addi	a1,s0,-62
    80003774:	854e                	mv	a0,s3
    80003776:	f7dff0ef          	jal	800036f2 <namecmp>
    8000377a:	f961                	bnez	a0,8000374a <dirlookup+0x42>
      if(poff)
    8000377c:	000a0463          	beqz	s4,80003784 <dirlookup+0x7c>
        *poff = off;
    80003780:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003784:	fc045583          	lhu	a1,-64(s0)
    80003788:	00092503          	lw	a0,0(s2)
    8000378c:	829ff0ef          	jal	80002fb4 <iget>
    80003790:	a011                	j	80003794 <dirlookup+0x8c>
  return 0;
    80003792:	4501                	li	a0,0
}
    80003794:	70e2                	ld	ra,56(sp)
    80003796:	7442                	ld	s0,48(sp)
    80003798:	74a2                	ld	s1,40(sp)
    8000379a:	7902                	ld	s2,32(sp)
    8000379c:	69e2                	ld	s3,24(sp)
    8000379e:	6a42                	ld	s4,16(sp)
    800037a0:	6121                	addi	sp,sp,64
    800037a2:	8082                	ret

00000000800037a4 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    800037a4:	711d                	addi	sp,sp,-96
    800037a6:	ec86                	sd	ra,88(sp)
    800037a8:	e8a2                	sd	s0,80(sp)
    800037aa:	e4a6                	sd	s1,72(sp)
    800037ac:	e0ca                	sd	s2,64(sp)
    800037ae:	fc4e                	sd	s3,56(sp)
    800037b0:	f852                	sd	s4,48(sp)
    800037b2:	f456                	sd	s5,40(sp)
    800037b4:	f05a                	sd	s6,32(sp)
    800037b6:	ec5e                	sd	s7,24(sp)
    800037b8:	e862                	sd	s8,16(sp)
    800037ba:	e466                	sd	s9,8(sp)
    800037bc:	1080                	addi	s0,sp,96
    800037be:	84aa                	mv	s1,a0
    800037c0:	8b2e                	mv	s6,a1
    800037c2:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    800037c4:	00054703          	lbu	a4,0(a0)
    800037c8:	02f00793          	li	a5,47
    800037cc:	00f70e63          	beq	a4,a5,800037e8 <namex+0x44>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    800037d0:	910fe0ef          	jal	800018e0 <myproc>
    800037d4:	15053503          	ld	a0,336(a0)
    800037d8:	a87ff0ef          	jal	8000325e <idup>
    800037dc:	8a2a                	mv	s4,a0
  while(*path == '/')
    800037de:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    800037e2:	4c35                	li	s8,13

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    800037e4:	4b85                	li	s7,1
    800037e6:	a871                	j	80003882 <namex+0xde>
    ip = iget(ROOTDEV, ROOTINO);
    800037e8:	4585                	li	a1,1
    800037ea:	4505                	li	a0,1
    800037ec:	fc8ff0ef          	jal	80002fb4 <iget>
    800037f0:	8a2a                	mv	s4,a0
    800037f2:	b7f5                	j	800037de <namex+0x3a>
      iunlockput(ip);
    800037f4:	8552                	mv	a0,s4
    800037f6:	ca9ff0ef          	jal	8000349e <iunlockput>
      return 0;
    800037fa:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    800037fc:	8552                	mv	a0,s4
    800037fe:	60e6                	ld	ra,88(sp)
    80003800:	6446                	ld	s0,80(sp)
    80003802:	64a6                	ld	s1,72(sp)
    80003804:	6906                	ld	s2,64(sp)
    80003806:	79e2                	ld	s3,56(sp)
    80003808:	7a42                	ld	s4,48(sp)
    8000380a:	7aa2                	ld	s5,40(sp)
    8000380c:	7b02                	ld	s6,32(sp)
    8000380e:	6be2                	ld	s7,24(sp)
    80003810:	6c42                	ld	s8,16(sp)
    80003812:	6ca2                	ld	s9,8(sp)
    80003814:	6125                	addi	sp,sp,96
    80003816:	8082                	ret
      iunlock(ip);
    80003818:	8552                	mv	a0,s4
    8000381a:	b29ff0ef          	jal	80003342 <iunlock>
      return ip;
    8000381e:	bff9                	j	800037fc <namex+0x58>
      iunlockput(ip);
    80003820:	8552                	mv	a0,s4
    80003822:	c7dff0ef          	jal	8000349e <iunlockput>
      return 0;
    80003826:	8a4e                	mv	s4,s3
    80003828:	bfd1                	j	800037fc <namex+0x58>
  len = path - s;
    8000382a:	40998633          	sub	a2,s3,s1
    8000382e:	00060c9b          	sext.w	s9,a2
  if(len >= DIRSIZ)
    80003832:	099c5063          	bge	s8,s9,800038b2 <namex+0x10e>
    memmove(name, s, DIRSIZ);
    80003836:	4639                	li	a2,14
    80003838:	85a6                	mv	a1,s1
    8000383a:	8556                	mv	a0,s5
    8000383c:	ce8fd0ef          	jal	80000d24 <memmove>
    80003840:	84ce                	mv	s1,s3
  while(*path == '/')
    80003842:	0004c783          	lbu	a5,0(s1)
    80003846:	01279763          	bne	a5,s2,80003854 <namex+0xb0>
    path++;
    8000384a:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000384c:	0004c783          	lbu	a5,0(s1)
    80003850:	ff278de3          	beq	a5,s2,8000384a <namex+0xa6>
    ilock(ip);
    80003854:	8552                	mv	a0,s4
    80003856:	a3fff0ef          	jal	80003294 <ilock>
    if(ip->type != T_DIR){
    8000385a:	044a1783          	lh	a5,68(s4)
    8000385e:	f9779be3          	bne	a5,s7,800037f4 <namex+0x50>
    if(nameiparent && *path == '\0'){
    80003862:	000b0563          	beqz	s6,8000386c <namex+0xc8>
    80003866:	0004c783          	lbu	a5,0(s1)
    8000386a:	d7dd                	beqz	a5,80003818 <namex+0x74>
    if((next = dirlookup(ip, name, 0)) == 0){
    8000386c:	4601                	li	a2,0
    8000386e:	85d6                	mv	a1,s5
    80003870:	8552                	mv	a0,s4
    80003872:	e97ff0ef          	jal	80003708 <dirlookup>
    80003876:	89aa                	mv	s3,a0
    80003878:	d545                	beqz	a0,80003820 <namex+0x7c>
    iunlockput(ip);
    8000387a:	8552                	mv	a0,s4
    8000387c:	c23ff0ef          	jal	8000349e <iunlockput>
    ip = next;
    80003880:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003882:	0004c783          	lbu	a5,0(s1)
    80003886:	01279763          	bne	a5,s2,80003894 <namex+0xf0>
    path++;
    8000388a:	0485                	addi	s1,s1,1
  while(*path == '/')
    8000388c:	0004c783          	lbu	a5,0(s1)
    80003890:	ff278de3          	beq	a5,s2,8000388a <namex+0xe6>
  if(*path == 0)
    80003894:	cb8d                	beqz	a5,800038c6 <namex+0x122>
  while(*path != '/' && *path != 0)
    80003896:	0004c783          	lbu	a5,0(s1)
    8000389a:	89a6                	mv	s3,s1
  len = path - s;
    8000389c:	4c81                	li	s9,0
    8000389e:	4601                	li	a2,0
  while(*path != '/' && *path != 0)
    800038a0:	01278963          	beq	a5,s2,800038b2 <namex+0x10e>
    800038a4:	d3d9                	beqz	a5,8000382a <namex+0x86>
    path++;
    800038a6:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    800038a8:	0009c783          	lbu	a5,0(s3)
    800038ac:	ff279ce3          	bne	a5,s2,800038a4 <namex+0x100>
    800038b0:	bfad                	j	8000382a <namex+0x86>
    memmove(name, s, len);
    800038b2:	2601                	sext.w	a2,a2
    800038b4:	85a6                	mv	a1,s1
    800038b6:	8556                	mv	a0,s5
    800038b8:	c6cfd0ef          	jal	80000d24 <memmove>
    name[len] = 0;
    800038bc:	9cd6                	add	s9,s9,s5
    800038be:	000c8023          	sb	zero,0(s9) # 2000 <_entry-0x7fffe000>
    800038c2:	84ce                	mv	s1,s3
    800038c4:	bfbd                	j	80003842 <namex+0x9e>
  if(nameiparent){
    800038c6:	f20b0be3          	beqz	s6,800037fc <namex+0x58>
    iput(ip);
    800038ca:	8552                	mv	a0,s4
    800038cc:	b4bff0ef          	jal	80003416 <iput>
    return 0;
    800038d0:	4a01                	li	s4,0
    800038d2:	b72d                	j	800037fc <namex+0x58>

00000000800038d4 <dirlink>:
{
    800038d4:	7139                	addi	sp,sp,-64
    800038d6:	fc06                	sd	ra,56(sp)
    800038d8:	f822                	sd	s0,48(sp)
    800038da:	f04a                	sd	s2,32(sp)
    800038dc:	ec4e                	sd	s3,24(sp)
    800038de:	e852                	sd	s4,16(sp)
    800038e0:	0080                	addi	s0,sp,64
    800038e2:	892a                	mv	s2,a0
    800038e4:	8a2e                	mv	s4,a1
    800038e6:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    800038e8:	4601                	li	a2,0
    800038ea:	e1fff0ef          	jal	80003708 <dirlookup>
    800038ee:	e535                	bnez	a0,8000395a <dirlink+0x86>
    800038f0:	f426                	sd	s1,40(sp)
  for(off = 0; off < dp->size; off += sizeof(de)){
    800038f2:	04c92483          	lw	s1,76(s2)
    800038f6:	c48d                	beqz	s1,80003920 <dirlink+0x4c>
    800038f8:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800038fa:	4741                	li	a4,16
    800038fc:	86a6                	mv	a3,s1
    800038fe:	fc040613          	addi	a2,s0,-64
    80003902:	4581                	li	a1,0
    80003904:	854a                	mv	a0,s2
    80003906:	be3ff0ef          	jal	800034e8 <readi>
    8000390a:	47c1                	li	a5,16
    8000390c:	04f51b63          	bne	a0,a5,80003962 <dirlink+0x8e>
    if(de.inum == 0)
    80003910:	fc045783          	lhu	a5,-64(s0)
    80003914:	c791                	beqz	a5,80003920 <dirlink+0x4c>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003916:	24c1                	addiw	s1,s1,16
    80003918:	04c92783          	lw	a5,76(s2)
    8000391c:	fcf4efe3          	bltu	s1,a5,800038fa <dirlink+0x26>
  strncpy(de.name, name, DIRSIZ);
    80003920:	4639                	li	a2,14
    80003922:	85d2                	mv	a1,s4
    80003924:	fc240513          	addi	a0,s0,-62
    80003928:	ca2fd0ef          	jal	80000dca <strncpy>
  de.inum = inum;
    8000392c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003930:	4741                	li	a4,16
    80003932:	86a6                	mv	a3,s1
    80003934:	fc040613          	addi	a2,s0,-64
    80003938:	4581                	li	a1,0
    8000393a:	854a                	mv	a0,s2
    8000393c:	ca9ff0ef          	jal	800035e4 <writei>
    80003940:	1541                	addi	a0,a0,-16
    80003942:	00a03533          	snez	a0,a0
    80003946:	40a00533          	neg	a0,a0
    8000394a:	74a2                	ld	s1,40(sp)
}
    8000394c:	70e2                	ld	ra,56(sp)
    8000394e:	7442                	ld	s0,48(sp)
    80003950:	7902                	ld	s2,32(sp)
    80003952:	69e2                	ld	s3,24(sp)
    80003954:	6a42                	ld	s4,16(sp)
    80003956:	6121                	addi	sp,sp,64
    80003958:	8082                	ret
    iput(ip);
    8000395a:	abdff0ef          	jal	80003416 <iput>
    return -1;
    8000395e:	557d                	li	a0,-1
    80003960:	b7f5                	j	8000394c <dirlink+0x78>
      panic("dirlink read");
    80003962:	00004517          	auipc	a0,0x4
    80003966:	be650513          	addi	a0,a0,-1050 # 80007548 <etext+0x548>
    8000396a:	e2bfc0ef          	jal	80000794 <panic>

000000008000396e <namei>:

struct inode*
namei(char *path)
{
    8000396e:	1101                	addi	sp,sp,-32
    80003970:	ec06                	sd	ra,24(sp)
    80003972:	e822                	sd	s0,16(sp)
    80003974:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    80003976:	fe040613          	addi	a2,s0,-32
    8000397a:	4581                	li	a1,0
    8000397c:	e29ff0ef          	jal	800037a4 <namex>
}
    80003980:	60e2                	ld	ra,24(sp)
    80003982:	6442                	ld	s0,16(sp)
    80003984:	6105                	addi	sp,sp,32
    80003986:	8082                	ret

0000000080003988 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    80003988:	1141                	addi	sp,sp,-16
    8000398a:	e406                	sd	ra,8(sp)
    8000398c:	e022                	sd	s0,0(sp)
    8000398e:	0800                	addi	s0,sp,16
    80003990:	862e                	mv	a2,a1
  return namex(path, 1, name);
    80003992:	4585                	li	a1,1
    80003994:	e11ff0ef          	jal	800037a4 <namex>
}
    80003998:	60a2                	ld	ra,8(sp)
    8000399a:	6402                	ld	s0,0(sp)
    8000399c:	0141                	addi	sp,sp,16
    8000399e:	8082                	ret

00000000800039a0 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    800039a0:	1101                	addi	sp,sp,-32
    800039a2:	ec06                	sd	ra,24(sp)
    800039a4:	e822                	sd	s0,16(sp)
    800039a6:	e426                	sd	s1,8(sp)
    800039a8:	e04a                	sd	s2,0(sp)
    800039aa:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    800039ac:	0001f917          	auipc	s2,0x1f
    800039b0:	fc490913          	addi	s2,s2,-60 # 80022970 <log>
    800039b4:	01892583          	lw	a1,24(s2)
    800039b8:	02892503          	lw	a0,40(s2)
    800039bc:	9a0ff0ef          	jal	80002b5c <bread>
    800039c0:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    800039c2:	02c92603          	lw	a2,44(s2)
    800039c6:	cd30                	sw	a2,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    800039c8:	00c05f63          	blez	a2,800039e6 <write_head+0x46>
    800039cc:	0001f717          	auipc	a4,0x1f
    800039d0:	fd470713          	addi	a4,a4,-44 # 800229a0 <log+0x30>
    800039d4:	87aa                	mv	a5,a0
    800039d6:	060a                	slli	a2,a2,0x2
    800039d8:	962a                	add	a2,a2,a0
    hb->block[i] = log.lh.block[i];
    800039da:	4314                	lw	a3,0(a4)
    800039dc:	cff4                	sw	a3,92(a5)
  for (i = 0; i < log.lh.n; i++) {
    800039de:	0711                	addi	a4,a4,4
    800039e0:	0791                	addi	a5,a5,4
    800039e2:	fec79ce3          	bne	a5,a2,800039da <write_head+0x3a>
  }
  bwrite(buf);
    800039e6:	8526                	mv	a0,s1
    800039e8:	a4aff0ef          	jal	80002c32 <bwrite>
  brelse(buf);
    800039ec:	8526                	mv	a0,s1
    800039ee:	a76ff0ef          	jal	80002c64 <brelse>
}
    800039f2:	60e2                	ld	ra,24(sp)
    800039f4:	6442                	ld	s0,16(sp)
    800039f6:	64a2                	ld	s1,8(sp)
    800039f8:	6902                	ld	s2,0(sp)
    800039fa:	6105                	addi	sp,sp,32
    800039fc:	8082                	ret

00000000800039fe <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    800039fe:	0001f797          	auipc	a5,0x1f
    80003a02:	f9e7a783          	lw	a5,-98(a5) # 8002299c <log+0x2c>
    80003a06:	08f05f63          	blez	a5,80003aa4 <install_trans+0xa6>
{
    80003a0a:	7139                	addi	sp,sp,-64
    80003a0c:	fc06                	sd	ra,56(sp)
    80003a0e:	f822                	sd	s0,48(sp)
    80003a10:	f426                	sd	s1,40(sp)
    80003a12:	f04a                	sd	s2,32(sp)
    80003a14:	ec4e                	sd	s3,24(sp)
    80003a16:	e852                	sd	s4,16(sp)
    80003a18:	e456                	sd	s5,8(sp)
    80003a1a:	e05a                	sd	s6,0(sp)
    80003a1c:	0080                	addi	s0,sp,64
    80003a1e:	8b2a                	mv	s6,a0
    80003a20:	0001fa97          	auipc	s5,0x1f
    80003a24:	f80a8a93          	addi	s5,s5,-128 # 800229a0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003a28:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003a2a:	0001f997          	auipc	s3,0x1f
    80003a2e:	f4698993          	addi	s3,s3,-186 # 80022970 <log>
    80003a32:	a829                	j	80003a4c <install_trans+0x4e>
    brelse(lbuf);
    80003a34:	854a                	mv	a0,s2
    80003a36:	a2eff0ef          	jal	80002c64 <brelse>
    brelse(dbuf);
    80003a3a:	8526                	mv	a0,s1
    80003a3c:	a28ff0ef          	jal	80002c64 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003a40:	2a05                	addiw	s4,s4,1
    80003a42:	0a91                	addi	s5,s5,4
    80003a44:	02c9a783          	lw	a5,44(s3)
    80003a48:	04fa5463          	bge	s4,a5,80003a90 <install_trans+0x92>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    80003a4c:	0189a583          	lw	a1,24(s3)
    80003a50:	014585bb          	addw	a1,a1,s4
    80003a54:	2585                	addiw	a1,a1,1
    80003a56:	0289a503          	lw	a0,40(s3)
    80003a5a:	902ff0ef          	jal	80002b5c <bread>
    80003a5e:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    80003a60:	000aa583          	lw	a1,0(s5)
    80003a64:	0289a503          	lw	a0,40(s3)
    80003a68:	8f4ff0ef          	jal	80002b5c <bread>
    80003a6c:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80003a6e:	40000613          	li	a2,1024
    80003a72:	05890593          	addi	a1,s2,88
    80003a76:	05850513          	addi	a0,a0,88
    80003a7a:	aaafd0ef          	jal	80000d24 <memmove>
    bwrite(dbuf);  // write dst to disk
    80003a7e:	8526                	mv	a0,s1
    80003a80:	9b2ff0ef          	jal	80002c32 <bwrite>
    if(recovering == 0)
    80003a84:	fa0b18e3          	bnez	s6,80003a34 <install_trans+0x36>
      bunpin(dbuf);
    80003a88:	8526                	mv	a0,s1
    80003a8a:	a96ff0ef          	jal	80002d20 <bunpin>
    80003a8e:	b75d                	j	80003a34 <install_trans+0x36>
}
    80003a90:	70e2                	ld	ra,56(sp)
    80003a92:	7442                	ld	s0,48(sp)
    80003a94:	74a2                	ld	s1,40(sp)
    80003a96:	7902                	ld	s2,32(sp)
    80003a98:	69e2                	ld	s3,24(sp)
    80003a9a:	6a42                	ld	s4,16(sp)
    80003a9c:	6aa2                	ld	s5,8(sp)
    80003a9e:	6b02                	ld	s6,0(sp)
    80003aa0:	6121                	addi	sp,sp,64
    80003aa2:	8082                	ret
    80003aa4:	8082                	ret

0000000080003aa6 <initlog>:
{
    80003aa6:	7179                	addi	sp,sp,-48
    80003aa8:	f406                	sd	ra,40(sp)
    80003aaa:	f022                	sd	s0,32(sp)
    80003aac:	ec26                	sd	s1,24(sp)
    80003aae:	e84a                	sd	s2,16(sp)
    80003ab0:	e44e                	sd	s3,8(sp)
    80003ab2:	1800                	addi	s0,sp,48
    80003ab4:	892a                	mv	s2,a0
    80003ab6:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80003ab8:	0001f497          	auipc	s1,0x1f
    80003abc:	eb848493          	addi	s1,s1,-328 # 80022970 <log>
    80003ac0:	00004597          	auipc	a1,0x4
    80003ac4:	a9858593          	addi	a1,a1,-1384 # 80007558 <etext+0x558>
    80003ac8:	8526                	mv	a0,s1
    80003aca:	8aafd0ef          	jal	80000b74 <initlock>
  log.start = sb->logstart;
    80003ace:	0149a583          	lw	a1,20(s3)
    80003ad2:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80003ad4:	0109a783          	lw	a5,16(s3)
    80003ad8:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    80003ada:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80003ade:	854a                	mv	a0,s2
    80003ae0:	87cff0ef          	jal	80002b5c <bread>
  log.lh.n = lh->n;
    80003ae4:	4d30                	lw	a2,88(a0)
    80003ae6:	d4d0                	sw	a2,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    80003ae8:	00c05f63          	blez	a2,80003b06 <initlog+0x60>
    80003aec:	87aa                	mv	a5,a0
    80003aee:	0001f717          	auipc	a4,0x1f
    80003af2:	eb270713          	addi	a4,a4,-334 # 800229a0 <log+0x30>
    80003af6:	060a                	slli	a2,a2,0x2
    80003af8:	962a                	add	a2,a2,a0
    log.lh.block[i] = lh->block[i];
    80003afa:	4ff4                	lw	a3,92(a5)
    80003afc:	c314                	sw	a3,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80003afe:	0791                	addi	a5,a5,4
    80003b00:	0711                	addi	a4,a4,4
    80003b02:	fec79ce3          	bne	a5,a2,80003afa <initlog+0x54>
  brelse(buf);
    80003b06:	95eff0ef          	jal	80002c64 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    80003b0a:	4505                	li	a0,1
    80003b0c:	ef3ff0ef          	jal	800039fe <install_trans>
  log.lh.n = 0;
    80003b10:	0001f797          	auipc	a5,0x1f
    80003b14:	e807a623          	sw	zero,-372(a5) # 8002299c <log+0x2c>
  write_head(); // clear the log
    80003b18:	e89ff0ef          	jal	800039a0 <write_head>
}
    80003b1c:	70a2                	ld	ra,40(sp)
    80003b1e:	7402                	ld	s0,32(sp)
    80003b20:	64e2                	ld	s1,24(sp)
    80003b22:	6942                	ld	s2,16(sp)
    80003b24:	69a2                	ld	s3,8(sp)
    80003b26:	6145                	addi	sp,sp,48
    80003b28:	8082                	ret

0000000080003b2a <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    80003b2a:	1101                	addi	sp,sp,-32
    80003b2c:	ec06                	sd	ra,24(sp)
    80003b2e:	e822                	sd	s0,16(sp)
    80003b30:	e426                	sd	s1,8(sp)
    80003b32:	e04a                	sd	s2,0(sp)
    80003b34:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    80003b36:	0001f517          	auipc	a0,0x1f
    80003b3a:	e3a50513          	addi	a0,a0,-454 # 80022970 <log>
    80003b3e:	8b6fd0ef          	jal	80000bf4 <acquire>
  while(1){
    if(log.committing){
    80003b42:	0001f497          	auipc	s1,0x1f
    80003b46:	e2e48493          	addi	s1,s1,-466 # 80022970 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003b4a:	4979                	li	s2,30
    80003b4c:	a029                	j	80003b56 <begin_op+0x2c>
      sleep(&log, &log.lock);
    80003b4e:	85a6                	mv	a1,s1
    80003b50:	8526                	mv	a0,s1
    80003b52:	bdafe0ef          	jal	80001f2c <sleep>
    if(log.committing){
    80003b56:	50dc                	lw	a5,36(s1)
    80003b58:	fbfd                	bnez	a5,80003b4e <begin_op+0x24>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80003b5a:	5098                	lw	a4,32(s1)
    80003b5c:	2705                	addiw	a4,a4,1
    80003b5e:	0027179b          	slliw	a5,a4,0x2
    80003b62:	9fb9                	addw	a5,a5,a4
    80003b64:	0017979b          	slliw	a5,a5,0x1
    80003b68:	54d4                	lw	a3,44(s1)
    80003b6a:	9fb5                	addw	a5,a5,a3
    80003b6c:	00f95763          	bge	s2,a5,80003b7a <begin_op+0x50>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    80003b70:	85a6                	mv	a1,s1
    80003b72:	8526                	mv	a0,s1
    80003b74:	bb8fe0ef          	jal	80001f2c <sleep>
    80003b78:	bff9                	j	80003b56 <begin_op+0x2c>
    } else {
      log.outstanding += 1;
    80003b7a:	0001f517          	auipc	a0,0x1f
    80003b7e:	df650513          	addi	a0,a0,-522 # 80022970 <log>
    80003b82:	d118                	sw	a4,32(a0)
      release(&log.lock);
    80003b84:	908fd0ef          	jal	80000c8c <release>
      break;
    }
  }
}
    80003b88:	60e2                	ld	ra,24(sp)
    80003b8a:	6442                	ld	s0,16(sp)
    80003b8c:	64a2                	ld	s1,8(sp)
    80003b8e:	6902                	ld	s2,0(sp)
    80003b90:	6105                	addi	sp,sp,32
    80003b92:	8082                	ret

0000000080003b94 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80003b94:	7139                	addi	sp,sp,-64
    80003b96:	fc06                	sd	ra,56(sp)
    80003b98:	f822                	sd	s0,48(sp)
    80003b9a:	f426                	sd	s1,40(sp)
    80003b9c:	f04a                	sd	s2,32(sp)
    80003b9e:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    80003ba0:	0001f497          	auipc	s1,0x1f
    80003ba4:	dd048493          	addi	s1,s1,-560 # 80022970 <log>
    80003ba8:	8526                	mv	a0,s1
    80003baa:	84afd0ef          	jal	80000bf4 <acquire>
  log.outstanding -= 1;
    80003bae:	509c                	lw	a5,32(s1)
    80003bb0:	37fd                	addiw	a5,a5,-1
    80003bb2:	0007891b          	sext.w	s2,a5
    80003bb6:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80003bb8:	50dc                	lw	a5,36(s1)
    80003bba:	ef9d                	bnez	a5,80003bf8 <end_op+0x64>
    panic("log.committing");
  if(log.outstanding == 0){
    80003bbc:	04091763          	bnez	s2,80003c0a <end_op+0x76>
    do_commit = 1;
    log.committing = 1;
    80003bc0:	0001f497          	auipc	s1,0x1f
    80003bc4:	db048493          	addi	s1,s1,-592 # 80022970 <log>
    80003bc8:	4785                	li	a5,1
    80003bca:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    80003bcc:	8526                	mv	a0,s1
    80003bce:	8befd0ef          	jal	80000c8c <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    80003bd2:	54dc                	lw	a5,44(s1)
    80003bd4:	04f04b63          	bgtz	a5,80003c2a <end_op+0x96>
    acquire(&log.lock);
    80003bd8:	0001f497          	auipc	s1,0x1f
    80003bdc:	d9848493          	addi	s1,s1,-616 # 80022970 <log>
    80003be0:	8526                	mv	a0,s1
    80003be2:	812fd0ef          	jal	80000bf4 <acquire>
    log.committing = 0;
    80003be6:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    80003bea:	8526                	mv	a0,s1
    80003bec:	b8cfe0ef          	jal	80001f78 <wakeup>
    release(&log.lock);
    80003bf0:	8526                	mv	a0,s1
    80003bf2:	89afd0ef          	jal	80000c8c <release>
}
    80003bf6:	a025                	j	80003c1e <end_op+0x8a>
    80003bf8:	ec4e                	sd	s3,24(sp)
    80003bfa:	e852                	sd	s4,16(sp)
    80003bfc:	e456                	sd	s5,8(sp)
    panic("log.committing");
    80003bfe:	00004517          	auipc	a0,0x4
    80003c02:	96250513          	addi	a0,a0,-1694 # 80007560 <etext+0x560>
    80003c06:	b8ffc0ef          	jal	80000794 <panic>
    wakeup(&log);
    80003c0a:	0001f497          	auipc	s1,0x1f
    80003c0e:	d6648493          	addi	s1,s1,-666 # 80022970 <log>
    80003c12:	8526                	mv	a0,s1
    80003c14:	b64fe0ef          	jal	80001f78 <wakeup>
  release(&log.lock);
    80003c18:	8526                	mv	a0,s1
    80003c1a:	872fd0ef          	jal	80000c8c <release>
}
    80003c1e:	70e2                	ld	ra,56(sp)
    80003c20:	7442                	ld	s0,48(sp)
    80003c22:	74a2                	ld	s1,40(sp)
    80003c24:	7902                	ld	s2,32(sp)
    80003c26:	6121                	addi	sp,sp,64
    80003c28:	8082                	ret
    80003c2a:	ec4e                	sd	s3,24(sp)
    80003c2c:	e852                	sd	s4,16(sp)
    80003c2e:	e456                	sd	s5,8(sp)
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c30:	0001fa97          	auipc	s5,0x1f
    80003c34:	d70a8a93          	addi	s5,s5,-656 # 800229a0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    80003c38:	0001fa17          	auipc	s4,0x1f
    80003c3c:	d38a0a13          	addi	s4,s4,-712 # 80022970 <log>
    80003c40:	018a2583          	lw	a1,24(s4)
    80003c44:	012585bb          	addw	a1,a1,s2
    80003c48:	2585                	addiw	a1,a1,1
    80003c4a:	028a2503          	lw	a0,40(s4)
    80003c4e:	f0ffe0ef          	jal	80002b5c <bread>
    80003c52:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    80003c54:	000aa583          	lw	a1,0(s5)
    80003c58:	028a2503          	lw	a0,40(s4)
    80003c5c:	f01fe0ef          	jal	80002b5c <bread>
    80003c60:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    80003c62:	40000613          	li	a2,1024
    80003c66:	05850593          	addi	a1,a0,88
    80003c6a:	05848513          	addi	a0,s1,88
    80003c6e:	8b6fd0ef          	jal	80000d24 <memmove>
    bwrite(to);  // write the log
    80003c72:	8526                	mv	a0,s1
    80003c74:	fbffe0ef          	jal	80002c32 <bwrite>
    brelse(from);
    80003c78:	854e                	mv	a0,s3
    80003c7a:	febfe0ef          	jal	80002c64 <brelse>
    brelse(to);
    80003c7e:	8526                	mv	a0,s1
    80003c80:	fe5fe0ef          	jal	80002c64 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80003c84:	2905                	addiw	s2,s2,1
    80003c86:	0a91                	addi	s5,s5,4
    80003c88:	02ca2783          	lw	a5,44(s4)
    80003c8c:	faf94ae3          	blt	s2,a5,80003c40 <end_op+0xac>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    80003c90:	d11ff0ef          	jal	800039a0 <write_head>
    install_trans(0); // Now install writes to home locations
    80003c94:	4501                	li	a0,0
    80003c96:	d69ff0ef          	jal	800039fe <install_trans>
    log.lh.n = 0;
    80003c9a:	0001f797          	auipc	a5,0x1f
    80003c9e:	d007a123          	sw	zero,-766(a5) # 8002299c <log+0x2c>
    write_head();    // Erase the transaction from the log
    80003ca2:	cffff0ef          	jal	800039a0 <write_head>
    80003ca6:	69e2                	ld	s3,24(sp)
    80003ca8:	6a42                	ld	s4,16(sp)
    80003caa:	6aa2                	ld	s5,8(sp)
    80003cac:	b735                	j	80003bd8 <end_op+0x44>

0000000080003cae <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    80003cae:	1101                	addi	sp,sp,-32
    80003cb0:	ec06                	sd	ra,24(sp)
    80003cb2:	e822                	sd	s0,16(sp)
    80003cb4:	e426                	sd	s1,8(sp)
    80003cb6:	e04a                	sd	s2,0(sp)
    80003cb8:	1000                	addi	s0,sp,32
    80003cba:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    80003cbc:	0001f917          	auipc	s2,0x1f
    80003cc0:	cb490913          	addi	s2,s2,-844 # 80022970 <log>
    80003cc4:	854a                	mv	a0,s2
    80003cc6:	f2ffc0ef          	jal	80000bf4 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    80003cca:	02c92603          	lw	a2,44(s2)
    80003cce:	47f5                	li	a5,29
    80003cd0:	06c7c363          	blt	a5,a2,80003d36 <log_write+0x88>
    80003cd4:	0001f797          	auipc	a5,0x1f
    80003cd8:	cb87a783          	lw	a5,-840(a5) # 8002298c <log+0x1c>
    80003cdc:	37fd                	addiw	a5,a5,-1
    80003cde:	04f65c63          	bge	a2,a5,80003d36 <log_write+0x88>
    panic("too big a transaction");
  if (log.outstanding < 1)
    80003ce2:	0001f797          	auipc	a5,0x1f
    80003ce6:	cae7a783          	lw	a5,-850(a5) # 80022990 <log+0x20>
    80003cea:	04f05c63          	blez	a5,80003d42 <log_write+0x94>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80003cee:	4781                	li	a5,0
    80003cf0:	04c05f63          	blez	a2,80003d4e <log_write+0xa0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003cf4:	44cc                	lw	a1,12(s1)
    80003cf6:	0001f717          	auipc	a4,0x1f
    80003cfa:	caa70713          	addi	a4,a4,-854 # 800229a0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80003cfe:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80003d00:	4314                	lw	a3,0(a4)
    80003d02:	04b68663          	beq	a3,a1,80003d4e <log_write+0xa0>
  for (i = 0; i < log.lh.n; i++) {
    80003d06:	2785                	addiw	a5,a5,1
    80003d08:	0711                	addi	a4,a4,4
    80003d0a:	fef61be3          	bne	a2,a5,80003d00 <log_write+0x52>
      break;
  }
  log.lh.block[i] = b->blockno;
    80003d0e:	0621                	addi	a2,a2,8
    80003d10:	060a                	slli	a2,a2,0x2
    80003d12:	0001f797          	auipc	a5,0x1f
    80003d16:	c5e78793          	addi	a5,a5,-930 # 80022970 <log>
    80003d1a:	97b2                	add	a5,a5,a2
    80003d1c:	44d8                	lw	a4,12(s1)
    80003d1e:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80003d20:	8526                	mv	a0,s1
    80003d22:	fcbfe0ef          	jal	80002cec <bpin>
    log.lh.n++;
    80003d26:	0001f717          	auipc	a4,0x1f
    80003d2a:	c4a70713          	addi	a4,a4,-950 # 80022970 <log>
    80003d2e:	575c                	lw	a5,44(a4)
    80003d30:	2785                	addiw	a5,a5,1
    80003d32:	d75c                	sw	a5,44(a4)
    80003d34:	a80d                	j	80003d66 <log_write+0xb8>
    panic("too big a transaction");
    80003d36:	00004517          	auipc	a0,0x4
    80003d3a:	83a50513          	addi	a0,a0,-1990 # 80007570 <etext+0x570>
    80003d3e:	a57fc0ef          	jal	80000794 <panic>
    panic("log_write outside of trans");
    80003d42:	00004517          	auipc	a0,0x4
    80003d46:	84650513          	addi	a0,a0,-1978 # 80007588 <etext+0x588>
    80003d4a:	a4bfc0ef          	jal	80000794 <panic>
  log.lh.block[i] = b->blockno;
    80003d4e:	00878693          	addi	a3,a5,8
    80003d52:	068a                	slli	a3,a3,0x2
    80003d54:	0001f717          	auipc	a4,0x1f
    80003d58:	c1c70713          	addi	a4,a4,-996 # 80022970 <log>
    80003d5c:	9736                	add	a4,a4,a3
    80003d5e:	44d4                	lw	a3,12(s1)
    80003d60:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80003d62:	faf60fe3          	beq	a2,a5,80003d20 <log_write+0x72>
  }
  release(&log.lock);
    80003d66:	0001f517          	auipc	a0,0x1f
    80003d6a:	c0a50513          	addi	a0,a0,-1014 # 80022970 <log>
    80003d6e:	f1ffc0ef          	jal	80000c8c <release>
}
    80003d72:	60e2                	ld	ra,24(sp)
    80003d74:	6442                	ld	s0,16(sp)
    80003d76:	64a2                	ld	s1,8(sp)
    80003d78:	6902                	ld	s2,0(sp)
    80003d7a:	6105                	addi	sp,sp,32
    80003d7c:	8082                	ret

0000000080003d7e <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    80003d7e:	1101                	addi	sp,sp,-32
    80003d80:	ec06                	sd	ra,24(sp)
    80003d82:	e822                	sd	s0,16(sp)
    80003d84:	e426                	sd	s1,8(sp)
    80003d86:	e04a                	sd	s2,0(sp)
    80003d88:	1000                	addi	s0,sp,32
    80003d8a:	84aa                	mv	s1,a0
    80003d8c:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    80003d8e:	00004597          	auipc	a1,0x4
    80003d92:	81a58593          	addi	a1,a1,-2022 # 800075a8 <etext+0x5a8>
    80003d96:	0521                	addi	a0,a0,8
    80003d98:	dddfc0ef          	jal	80000b74 <initlock>
  lk->name = name;
    80003d9c:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    80003da0:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003da4:	0204a423          	sw	zero,40(s1)
}
    80003da8:	60e2                	ld	ra,24(sp)
    80003daa:	6442                	ld	s0,16(sp)
    80003dac:	64a2                	ld	s1,8(sp)
    80003dae:	6902                	ld	s2,0(sp)
    80003db0:	6105                	addi	sp,sp,32
    80003db2:	8082                	ret

0000000080003db4 <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    80003db4:	1101                	addi	sp,sp,-32
    80003db6:	ec06                	sd	ra,24(sp)
    80003db8:	e822                	sd	s0,16(sp)
    80003dba:	e426                	sd	s1,8(sp)
    80003dbc:	e04a                	sd	s2,0(sp)
    80003dbe:	1000                	addi	s0,sp,32
    80003dc0:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003dc2:	00850913          	addi	s2,a0,8
    80003dc6:	854a                	mv	a0,s2
    80003dc8:	e2dfc0ef          	jal	80000bf4 <acquire>
  while (lk->locked) {
    80003dcc:	409c                	lw	a5,0(s1)
    80003dce:	c799                	beqz	a5,80003ddc <acquiresleep+0x28>
    sleep(lk, &lk->lk);
    80003dd0:	85ca                	mv	a1,s2
    80003dd2:	8526                	mv	a0,s1
    80003dd4:	958fe0ef          	jal	80001f2c <sleep>
  while (lk->locked) {
    80003dd8:	409c                	lw	a5,0(s1)
    80003dda:	fbfd                	bnez	a5,80003dd0 <acquiresleep+0x1c>
  }
  lk->locked = 1;
    80003ddc:	4785                	li	a5,1
    80003dde:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80003de0:	b01fd0ef          	jal	800018e0 <myproc>
    80003de4:	591c                	lw	a5,48(a0)
    80003de6:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    80003de8:	854a                	mv	a0,s2
    80003dea:	ea3fc0ef          	jal	80000c8c <release>
}
    80003dee:	60e2                	ld	ra,24(sp)
    80003df0:	6442                	ld	s0,16(sp)
    80003df2:	64a2                	ld	s1,8(sp)
    80003df4:	6902                	ld	s2,0(sp)
    80003df6:	6105                	addi	sp,sp,32
    80003df8:	8082                	ret

0000000080003dfa <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80003dfa:	1101                	addi	sp,sp,-32
    80003dfc:	ec06                	sd	ra,24(sp)
    80003dfe:	e822                	sd	s0,16(sp)
    80003e00:	e426                	sd	s1,8(sp)
    80003e02:	e04a                	sd	s2,0(sp)
    80003e04:	1000                	addi	s0,sp,32
    80003e06:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80003e08:	00850913          	addi	s2,a0,8
    80003e0c:	854a                	mv	a0,s2
    80003e0e:	de7fc0ef          	jal	80000bf4 <acquire>
  lk->locked = 0;
    80003e12:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80003e16:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80003e1a:	8526                	mv	a0,s1
    80003e1c:	95cfe0ef          	jal	80001f78 <wakeup>
  release(&lk->lk);
    80003e20:	854a                	mv	a0,s2
    80003e22:	e6bfc0ef          	jal	80000c8c <release>
}
    80003e26:	60e2                	ld	ra,24(sp)
    80003e28:	6442                	ld	s0,16(sp)
    80003e2a:	64a2                	ld	s1,8(sp)
    80003e2c:	6902                	ld	s2,0(sp)
    80003e2e:	6105                	addi	sp,sp,32
    80003e30:	8082                	ret

0000000080003e32 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80003e32:	7179                	addi	sp,sp,-48
    80003e34:	f406                	sd	ra,40(sp)
    80003e36:	f022                	sd	s0,32(sp)
    80003e38:	ec26                	sd	s1,24(sp)
    80003e3a:	e84a                	sd	s2,16(sp)
    80003e3c:	1800                	addi	s0,sp,48
    80003e3e:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80003e40:	00850913          	addi	s2,a0,8
    80003e44:	854a                	mv	a0,s2
    80003e46:	daffc0ef          	jal	80000bf4 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80003e4a:	409c                	lw	a5,0(s1)
    80003e4c:	ef81                	bnez	a5,80003e64 <holdingsleep+0x32>
    80003e4e:	4481                	li	s1,0
  release(&lk->lk);
    80003e50:	854a                	mv	a0,s2
    80003e52:	e3bfc0ef          	jal	80000c8c <release>
  return r;
}
    80003e56:	8526                	mv	a0,s1
    80003e58:	70a2                	ld	ra,40(sp)
    80003e5a:	7402                	ld	s0,32(sp)
    80003e5c:	64e2                	ld	s1,24(sp)
    80003e5e:	6942                	ld	s2,16(sp)
    80003e60:	6145                	addi	sp,sp,48
    80003e62:	8082                	ret
    80003e64:	e44e                	sd	s3,8(sp)
  r = lk->locked && (lk->pid == myproc()->pid);
    80003e66:	0284a983          	lw	s3,40(s1)
    80003e6a:	a77fd0ef          	jal	800018e0 <myproc>
    80003e6e:	5904                	lw	s1,48(a0)
    80003e70:	413484b3          	sub	s1,s1,s3
    80003e74:	0014b493          	seqz	s1,s1
    80003e78:	69a2                	ld	s3,8(sp)
    80003e7a:	bfd9                	j	80003e50 <holdingsleep+0x1e>

0000000080003e7c <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    80003e7c:	1141                	addi	sp,sp,-16
    80003e7e:	e406                	sd	ra,8(sp)
    80003e80:	e022                	sd	s0,0(sp)
    80003e82:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    80003e84:	00003597          	auipc	a1,0x3
    80003e88:	73458593          	addi	a1,a1,1844 # 800075b8 <etext+0x5b8>
    80003e8c:	0001f517          	auipc	a0,0x1f
    80003e90:	c2c50513          	addi	a0,a0,-980 # 80022ab8 <ftable>
    80003e94:	ce1fc0ef          	jal	80000b74 <initlock>
}
    80003e98:	60a2                	ld	ra,8(sp)
    80003e9a:	6402                	ld	s0,0(sp)
    80003e9c:	0141                	addi	sp,sp,16
    80003e9e:	8082                	ret

0000000080003ea0 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    80003ea0:	1101                	addi	sp,sp,-32
    80003ea2:	ec06                	sd	ra,24(sp)
    80003ea4:	e822                	sd	s0,16(sp)
    80003ea6:	e426                	sd	s1,8(sp)
    80003ea8:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80003eaa:	0001f517          	auipc	a0,0x1f
    80003eae:	c0e50513          	addi	a0,a0,-1010 # 80022ab8 <ftable>
    80003eb2:	d43fc0ef          	jal	80000bf4 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003eb6:	0001f497          	auipc	s1,0x1f
    80003eba:	c1a48493          	addi	s1,s1,-998 # 80022ad0 <ftable+0x18>
    80003ebe:	00020717          	auipc	a4,0x20
    80003ec2:	bb270713          	addi	a4,a4,-1102 # 80023a70 <disk>
    if(f->ref == 0){
    80003ec6:	40dc                	lw	a5,4(s1)
    80003ec8:	cf89                	beqz	a5,80003ee2 <filealloc+0x42>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80003eca:	02848493          	addi	s1,s1,40
    80003ece:	fee49ce3          	bne	s1,a4,80003ec6 <filealloc+0x26>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    80003ed2:	0001f517          	auipc	a0,0x1f
    80003ed6:	be650513          	addi	a0,a0,-1050 # 80022ab8 <ftable>
    80003eda:	db3fc0ef          	jal	80000c8c <release>
  return 0;
    80003ede:	4481                	li	s1,0
    80003ee0:	a809                	j	80003ef2 <filealloc+0x52>
      f->ref = 1;
    80003ee2:	4785                	li	a5,1
    80003ee4:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80003ee6:	0001f517          	auipc	a0,0x1f
    80003eea:	bd250513          	addi	a0,a0,-1070 # 80022ab8 <ftable>
    80003eee:	d9ffc0ef          	jal	80000c8c <release>
}
    80003ef2:	8526                	mv	a0,s1
    80003ef4:	60e2                	ld	ra,24(sp)
    80003ef6:	6442                	ld	s0,16(sp)
    80003ef8:	64a2                	ld	s1,8(sp)
    80003efa:	6105                	addi	sp,sp,32
    80003efc:	8082                	ret

0000000080003efe <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80003efe:	1101                	addi	sp,sp,-32
    80003f00:	ec06                	sd	ra,24(sp)
    80003f02:	e822                	sd	s0,16(sp)
    80003f04:	e426                	sd	s1,8(sp)
    80003f06:	1000                	addi	s0,sp,32
    80003f08:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    80003f0a:	0001f517          	auipc	a0,0x1f
    80003f0e:	bae50513          	addi	a0,a0,-1106 # 80022ab8 <ftable>
    80003f12:	ce3fc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    80003f16:	40dc                	lw	a5,4(s1)
    80003f18:	02f05063          	blez	a5,80003f38 <filedup+0x3a>
    panic("filedup");
  f->ref++;
    80003f1c:	2785                	addiw	a5,a5,1
    80003f1e:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80003f20:	0001f517          	auipc	a0,0x1f
    80003f24:	b9850513          	addi	a0,a0,-1128 # 80022ab8 <ftable>
    80003f28:	d65fc0ef          	jal	80000c8c <release>
  return f;
}
    80003f2c:	8526                	mv	a0,s1
    80003f2e:	60e2                	ld	ra,24(sp)
    80003f30:	6442                	ld	s0,16(sp)
    80003f32:	64a2                	ld	s1,8(sp)
    80003f34:	6105                	addi	sp,sp,32
    80003f36:	8082                	ret
    panic("filedup");
    80003f38:	00003517          	auipc	a0,0x3
    80003f3c:	68850513          	addi	a0,a0,1672 # 800075c0 <etext+0x5c0>
    80003f40:	855fc0ef          	jal	80000794 <panic>

0000000080003f44 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    80003f44:	7139                	addi	sp,sp,-64
    80003f46:	fc06                	sd	ra,56(sp)
    80003f48:	f822                	sd	s0,48(sp)
    80003f4a:	f426                	sd	s1,40(sp)
    80003f4c:	0080                	addi	s0,sp,64
    80003f4e:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    80003f50:	0001f517          	auipc	a0,0x1f
    80003f54:	b6850513          	addi	a0,a0,-1176 # 80022ab8 <ftable>
    80003f58:	c9dfc0ef          	jal	80000bf4 <acquire>
  if(f->ref < 1)
    80003f5c:	40dc                	lw	a5,4(s1)
    80003f5e:	04f05a63          	blez	a5,80003fb2 <fileclose+0x6e>
    panic("fileclose");
  if(--f->ref > 0){
    80003f62:	37fd                	addiw	a5,a5,-1
    80003f64:	0007871b          	sext.w	a4,a5
    80003f68:	c0dc                	sw	a5,4(s1)
    80003f6a:	04e04e63          	bgtz	a4,80003fc6 <fileclose+0x82>
    80003f6e:	f04a                	sd	s2,32(sp)
    80003f70:	ec4e                	sd	s3,24(sp)
    80003f72:	e852                	sd	s4,16(sp)
    80003f74:	e456                	sd	s5,8(sp)
    release(&ftable.lock);
    return;
  }
  ff = *f;
    80003f76:	0004a903          	lw	s2,0(s1)
    80003f7a:	0094ca83          	lbu	s5,9(s1)
    80003f7e:	0104ba03          	ld	s4,16(s1)
    80003f82:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    80003f86:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    80003f8a:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80003f8e:	0001f517          	auipc	a0,0x1f
    80003f92:	b2a50513          	addi	a0,a0,-1238 # 80022ab8 <ftable>
    80003f96:	cf7fc0ef          	jal	80000c8c <release>

  if(ff.type == FD_PIPE){
    80003f9a:	4785                	li	a5,1
    80003f9c:	04f90063          	beq	s2,a5,80003fdc <fileclose+0x98>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80003fa0:	3979                	addiw	s2,s2,-2
    80003fa2:	4785                	li	a5,1
    80003fa4:	0527f563          	bgeu	a5,s2,80003fee <fileclose+0xaa>
    80003fa8:	7902                	ld	s2,32(sp)
    80003faa:	69e2                	ld	s3,24(sp)
    80003fac:	6a42                	ld	s4,16(sp)
    80003fae:	6aa2                	ld	s5,8(sp)
    80003fb0:	a00d                	j	80003fd2 <fileclose+0x8e>
    80003fb2:	f04a                	sd	s2,32(sp)
    80003fb4:	ec4e                	sd	s3,24(sp)
    80003fb6:	e852                	sd	s4,16(sp)
    80003fb8:	e456                	sd	s5,8(sp)
    panic("fileclose");
    80003fba:	00003517          	auipc	a0,0x3
    80003fbe:	60e50513          	addi	a0,a0,1550 # 800075c8 <etext+0x5c8>
    80003fc2:	fd2fc0ef          	jal	80000794 <panic>
    release(&ftable.lock);
    80003fc6:	0001f517          	auipc	a0,0x1f
    80003fca:	af250513          	addi	a0,a0,-1294 # 80022ab8 <ftable>
    80003fce:	cbffc0ef          	jal	80000c8c <release>
    begin_op();
    iput(ff.ip);
    end_op();
  }
}
    80003fd2:	70e2                	ld	ra,56(sp)
    80003fd4:	7442                	ld	s0,48(sp)
    80003fd6:	74a2                	ld	s1,40(sp)
    80003fd8:	6121                	addi	sp,sp,64
    80003fda:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    80003fdc:	85d6                	mv	a1,s5
    80003fde:	8552                	mv	a0,s4
    80003fe0:	336000ef          	jal	80004316 <pipeclose>
    80003fe4:	7902                	ld	s2,32(sp)
    80003fe6:	69e2                	ld	s3,24(sp)
    80003fe8:	6a42                	ld	s4,16(sp)
    80003fea:	6aa2                	ld	s5,8(sp)
    80003fec:	b7dd                	j	80003fd2 <fileclose+0x8e>
    begin_op();
    80003fee:	b3dff0ef          	jal	80003b2a <begin_op>
    iput(ff.ip);
    80003ff2:	854e                	mv	a0,s3
    80003ff4:	c22ff0ef          	jal	80003416 <iput>
    end_op();
    80003ff8:	b9dff0ef          	jal	80003b94 <end_op>
    80003ffc:	7902                	ld	s2,32(sp)
    80003ffe:	69e2                	ld	s3,24(sp)
    80004000:	6a42                	ld	s4,16(sp)
    80004002:	6aa2                	ld	s5,8(sp)
    80004004:	b7f9                	j	80003fd2 <fileclose+0x8e>

0000000080004006 <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    80004006:	715d                	addi	sp,sp,-80
    80004008:	e486                	sd	ra,72(sp)
    8000400a:	e0a2                	sd	s0,64(sp)
    8000400c:	fc26                	sd	s1,56(sp)
    8000400e:	f44e                	sd	s3,40(sp)
    80004010:	0880                	addi	s0,sp,80
    80004012:	84aa                	mv	s1,a0
    80004014:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    80004016:	8cbfd0ef          	jal	800018e0 <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    8000401a:	409c                	lw	a5,0(s1)
    8000401c:	37f9                	addiw	a5,a5,-2
    8000401e:	4705                	li	a4,1
    80004020:	04f76063          	bltu	a4,a5,80004060 <filestat+0x5a>
    80004024:	f84a                	sd	s2,48(sp)
    80004026:	892a                	mv	s2,a0
    ilock(f->ip);
    80004028:	6c88                	ld	a0,24(s1)
    8000402a:	a6aff0ef          	jal	80003294 <ilock>
    stati(f->ip, &st);
    8000402e:	fb840593          	addi	a1,s0,-72
    80004032:	6c88                	ld	a0,24(s1)
    80004034:	c8aff0ef          	jal	800034be <stati>
    iunlock(f->ip);
    80004038:	6c88                	ld	a0,24(s1)
    8000403a:	b08ff0ef          	jal	80003342 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    8000403e:	46e1                	li	a3,24
    80004040:	fb840613          	addi	a2,s0,-72
    80004044:	85ce                	mv	a1,s3
    80004046:	05093503          	ld	a0,80(s2)
    8000404a:	d08fd0ef          	jal	80001552 <copyout>
    8000404e:	41f5551b          	sraiw	a0,a0,0x1f
    80004052:	7942                	ld	s2,48(sp)
      return -1;
    return 0;
  }
  return -1;
}
    80004054:	60a6                	ld	ra,72(sp)
    80004056:	6406                	ld	s0,64(sp)
    80004058:	74e2                	ld	s1,56(sp)
    8000405a:	79a2                	ld	s3,40(sp)
    8000405c:	6161                	addi	sp,sp,80
    8000405e:	8082                	ret
  return -1;
    80004060:	557d                	li	a0,-1
    80004062:	bfcd                	j	80004054 <filestat+0x4e>

0000000080004064 <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    80004064:	7179                	addi	sp,sp,-48
    80004066:	f406                	sd	ra,40(sp)
    80004068:	f022                	sd	s0,32(sp)
    8000406a:	e84a                	sd	s2,16(sp)
    8000406c:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    8000406e:	00854783          	lbu	a5,8(a0)
    80004072:	cfd1                	beqz	a5,8000410e <fileread+0xaa>
    80004074:	ec26                	sd	s1,24(sp)
    80004076:	e44e                	sd	s3,8(sp)
    80004078:	84aa                	mv	s1,a0
    8000407a:	89ae                	mv	s3,a1
    8000407c:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    8000407e:	411c                	lw	a5,0(a0)
    80004080:	4705                	li	a4,1
    80004082:	04e78363          	beq	a5,a4,800040c8 <fileread+0x64>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004086:	470d                	li	a4,3
    80004088:	04e78763          	beq	a5,a4,800040d6 <fileread+0x72>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    8000408c:	4709                	li	a4,2
    8000408e:	06e79a63          	bne	a5,a4,80004102 <fileread+0x9e>
    ilock(f->ip);
    80004092:	6d08                	ld	a0,24(a0)
    80004094:	a00ff0ef          	jal	80003294 <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004098:	874a                	mv	a4,s2
    8000409a:	5094                	lw	a3,32(s1)
    8000409c:	864e                	mv	a2,s3
    8000409e:	4585                	li	a1,1
    800040a0:	6c88                	ld	a0,24(s1)
    800040a2:	c46ff0ef          	jal	800034e8 <readi>
    800040a6:	892a                	mv	s2,a0
    800040a8:	00a05563          	blez	a0,800040b2 <fileread+0x4e>
      f->off += r;
    800040ac:	509c                	lw	a5,32(s1)
    800040ae:	9fa9                	addw	a5,a5,a0
    800040b0:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    800040b2:	6c88                	ld	a0,24(s1)
    800040b4:	a8eff0ef          	jal	80003342 <iunlock>
    800040b8:	64e2                	ld	s1,24(sp)
    800040ba:	69a2                	ld	s3,8(sp)
  } else {
    panic("fileread");
  }

  return r;
}
    800040bc:	854a                	mv	a0,s2
    800040be:	70a2                	ld	ra,40(sp)
    800040c0:	7402                	ld	s0,32(sp)
    800040c2:	6942                	ld	s2,16(sp)
    800040c4:	6145                	addi	sp,sp,48
    800040c6:	8082                	ret
    r = piperead(f->pipe, addr, n);
    800040c8:	6908                	ld	a0,16(a0)
    800040ca:	388000ef          	jal	80004452 <piperead>
    800040ce:	892a                	mv	s2,a0
    800040d0:	64e2                	ld	s1,24(sp)
    800040d2:	69a2                	ld	s3,8(sp)
    800040d4:	b7e5                	j	800040bc <fileread+0x58>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    800040d6:	02451783          	lh	a5,36(a0)
    800040da:	03079693          	slli	a3,a5,0x30
    800040de:	92c1                	srli	a3,a3,0x30
    800040e0:	4725                	li	a4,9
    800040e2:	02d76863          	bltu	a4,a3,80004112 <fileread+0xae>
    800040e6:	0792                	slli	a5,a5,0x4
    800040e8:	0001f717          	auipc	a4,0x1f
    800040ec:	93070713          	addi	a4,a4,-1744 # 80022a18 <devsw>
    800040f0:	97ba                	add	a5,a5,a4
    800040f2:	639c                	ld	a5,0(a5)
    800040f4:	c39d                	beqz	a5,8000411a <fileread+0xb6>
    r = devsw[f->major].read(1, addr, n);
    800040f6:	4505                	li	a0,1
    800040f8:	9782                	jalr	a5
    800040fa:	892a                	mv	s2,a0
    800040fc:	64e2                	ld	s1,24(sp)
    800040fe:	69a2                	ld	s3,8(sp)
    80004100:	bf75                	j	800040bc <fileread+0x58>
    panic("fileread");
    80004102:	00003517          	auipc	a0,0x3
    80004106:	4d650513          	addi	a0,a0,1238 # 800075d8 <etext+0x5d8>
    8000410a:	e8afc0ef          	jal	80000794 <panic>
    return -1;
    8000410e:	597d                	li	s2,-1
    80004110:	b775                	j	800040bc <fileread+0x58>
      return -1;
    80004112:	597d                	li	s2,-1
    80004114:	64e2                	ld	s1,24(sp)
    80004116:	69a2                	ld	s3,8(sp)
    80004118:	b755                	j	800040bc <fileread+0x58>
    8000411a:	597d                	li	s2,-1
    8000411c:	64e2                	ld	s1,24(sp)
    8000411e:	69a2                	ld	s3,8(sp)
    80004120:	bf71                	j	800040bc <fileread+0x58>

0000000080004122 <filewrite>:
int
filewrite(struct file *f, uint64 addr, int n)
{
  int r, ret = 0;

  if(f->writable == 0)
    80004122:	00954783          	lbu	a5,9(a0)
    80004126:	10078b63          	beqz	a5,8000423c <filewrite+0x11a>
{
    8000412a:	715d                	addi	sp,sp,-80
    8000412c:	e486                	sd	ra,72(sp)
    8000412e:	e0a2                	sd	s0,64(sp)
    80004130:	f84a                	sd	s2,48(sp)
    80004132:	f052                	sd	s4,32(sp)
    80004134:	e85a                	sd	s6,16(sp)
    80004136:	0880                	addi	s0,sp,80
    80004138:	892a                	mv	s2,a0
    8000413a:	8b2e                	mv	s6,a1
    8000413c:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    8000413e:	411c                	lw	a5,0(a0)
    80004140:	4705                	li	a4,1
    80004142:	02e78763          	beq	a5,a4,80004170 <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    80004146:	470d                	li	a4,3
    80004148:	02e78863          	beq	a5,a4,80004178 <filewrite+0x56>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    8000414c:	4709                	li	a4,2
    8000414e:	0ce79c63          	bne	a5,a4,80004226 <filewrite+0x104>
    80004152:	f44e                	sd	s3,40(sp)
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    80004154:	0ac05863          	blez	a2,80004204 <filewrite+0xe2>
    80004158:	fc26                	sd	s1,56(sp)
    8000415a:	ec56                	sd	s5,24(sp)
    8000415c:	e45e                	sd	s7,8(sp)
    8000415e:	e062                	sd	s8,0(sp)
    int i = 0;
    80004160:	4981                	li	s3,0
      int n1 = n - i;
      if(n1 > max)
    80004162:	6b85                	lui	s7,0x1
    80004164:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    80004168:	6c05                	lui	s8,0x1
    8000416a:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    8000416e:	a8b5                	j	800041ea <filewrite+0xc8>
    ret = pipewrite(f->pipe, addr, n);
    80004170:	6908                	ld	a0,16(a0)
    80004172:	1fc000ef          	jal	8000436e <pipewrite>
    80004176:	a04d                	j	80004218 <filewrite+0xf6>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004178:	02451783          	lh	a5,36(a0)
    8000417c:	03079693          	slli	a3,a5,0x30
    80004180:	92c1                	srli	a3,a3,0x30
    80004182:	4725                	li	a4,9
    80004184:	0ad76e63          	bltu	a4,a3,80004240 <filewrite+0x11e>
    80004188:	0792                	slli	a5,a5,0x4
    8000418a:	0001f717          	auipc	a4,0x1f
    8000418e:	88e70713          	addi	a4,a4,-1906 # 80022a18 <devsw>
    80004192:	97ba                	add	a5,a5,a4
    80004194:	679c                	ld	a5,8(a5)
    80004196:	c7dd                	beqz	a5,80004244 <filewrite+0x122>
    ret = devsw[f->major].write(1, addr, n);
    80004198:	4505                	li	a0,1
    8000419a:	9782                	jalr	a5
    8000419c:	a8b5                	j	80004218 <filewrite+0xf6>
      if(n1 > max)
    8000419e:	00048a9b          	sext.w	s5,s1
        n1 = max;

      begin_op();
    800041a2:	989ff0ef          	jal	80003b2a <begin_op>
      ilock(f->ip);
    800041a6:	01893503          	ld	a0,24(s2)
    800041aa:	8eaff0ef          	jal	80003294 <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    800041ae:	8756                	mv	a4,s5
    800041b0:	02092683          	lw	a3,32(s2)
    800041b4:	01698633          	add	a2,s3,s6
    800041b8:	4585                	li	a1,1
    800041ba:	01893503          	ld	a0,24(s2)
    800041be:	c26ff0ef          	jal	800035e4 <writei>
    800041c2:	84aa                	mv	s1,a0
    800041c4:	00a05763          	blez	a0,800041d2 <filewrite+0xb0>
        f->off += r;
    800041c8:	02092783          	lw	a5,32(s2)
    800041cc:	9fa9                	addw	a5,a5,a0
    800041ce:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    800041d2:	01893503          	ld	a0,24(s2)
    800041d6:	96cff0ef          	jal	80003342 <iunlock>
      end_op();
    800041da:	9bbff0ef          	jal	80003b94 <end_op>

      if(r != n1){
    800041de:	029a9563          	bne	s5,s1,80004208 <filewrite+0xe6>
        // error from writei
        break;
      }
      i += r;
    800041e2:	013489bb          	addw	s3,s1,s3
    while(i < n){
    800041e6:	0149da63          	bge	s3,s4,800041fa <filewrite+0xd8>
      int n1 = n - i;
    800041ea:	413a04bb          	subw	s1,s4,s3
      if(n1 > max)
    800041ee:	0004879b          	sext.w	a5,s1
    800041f2:	fafbd6e3          	bge	s7,a5,8000419e <filewrite+0x7c>
    800041f6:	84e2                	mv	s1,s8
    800041f8:	b75d                	j	8000419e <filewrite+0x7c>
    800041fa:	74e2                	ld	s1,56(sp)
    800041fc:	6ae2                	ld	s5,24(sp)
    800041fe:	6ba2                	ld	s7,8(sp)
    80004200:	6c02                	ld	s8,0(sp)
    80004202:	a039                	j	80004210 <filewrite+0xee>
    int i = 0;
    80004204:	4981                	li	s3,0
    80004206:	a029                	j	80004210 <filewrite+0xee>
    80004208:	74e2                	ld	s1,56(sp)
    8000420a:	6ae2                	ld	s5,24(sp)
    8000420c:	6ba2                	ld	s7,8(sp)
    8000420e:	6c02                	ld	s8,0(sp)
    }
    ret = (i == n ? n : -1);
    80004210:	033a1c63          	bne	s4,s3,80004248 <filewrite+0x126>
    80004214:	8552                	mv	a0,s4
    80004216:	79a2                	ld	s3,40(sp)
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004218:	60a6                	ld	ra,72(sp)
    8000421a:	6406                	ld	s0,64(sp)
    8000421c:	7942                	ld	s2,48(sp)
    8000421e:	7a02                	ld	s4,32(sp)
    80004220:	6b42                	ld	s6,16(sp)
    80004222:	6161                	addi	sp,sp,80
    80004224:	8082                	ret
    80004226:	fc26                	sd	s1,56(sp)
    80004228:	f44e                	sd	s3,40(sp)
    8000422a:	ec56                	sd	s5,24(sp)
    8000422c:	e45e                	sd	s7,8(sp)
    8000422e:	e062                	sd	s8,0(sp)
    panic("filewrite");
    80004230:	00003517          	auipc	a0,0x3
    80004234:	3b850513          	addi	a0,a0,952 # 800075e8 <etext+0x5e8>
    80004238:	d5cfc0ef          	jal	80000794 <panic>
    return -1;
    8000423c:	557d                	li	a0,-1
}
    8000423e:	8082                	ret
      return -1;
    80004240:	557d                	li	a0,-1
    80004242:	bfd9                	j	80004218 <filewrite+0xf6>
    80004244:	557d                	li	a0,-1
    80004246:	bfc9                	j	80004218 <filewrite+0xf6>
    ret = (i == n ? n : -1);
    80004248:	557d                	li	a0,-1
    8000424a:	79a2                	ld	s3,40(sp)
    8000424c:	b7f1                	j	80004218 <filewrite+0xf6>

000000008000424e <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    8000424e:	7179                	addi	sp,sp,-48
    80004250:	f406                	sd	ra,40(sp)
    80004252:	f022                	sd	s0,32(sp)
    80004254:	ec26                	sd	s1,24(sp)
    80004256:	e052                	sd	s4,0(sp)
    80004258:	1800                	addi	s0,sp,48
    8000425a:	84aa                	mv	s1,a0
    8000425c:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    8000425e:	0005b023          	sd	zero,0(a1)
    80004262:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004266:	c3bff0ef          	jal	80003ea0 <filealloc>
    8000426a:	e088                	sd	a0,0(s1)
    8000426c:	c549                	beqz	a0,800042f6 <pipealloc+0xa8>
    8000426e:	c33ff0ef          	jal	80003ea0 <filealloc>
    80004272:	00aa3023          	sd	a0,0(s4)
    80004276:	cd25                	beqz	a0,800042ee <pipealloc+0xa0>
    80004278:	e84a                	sd	s2,16(sp)
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    8000427a:	8abfc0ef          	jal	80000b24 <kalloc>
    8000427e:	892a                	mv	s2,a0
    80004280:	c12d                	beqz	a0,800042e2 <pipealloc+0x94>
    80004282:	e44e                	sd	s3,8(sp)
    goto bad;
  pi->readopen = 1;
    80004284:	4985                	li	s3,1
    80004286:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    8000428a:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    8000428e:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004292:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004296:	00003597          	auipc	a1,0x3
    8000429a:	36258593          	addi	a1,a1,866 # 800075f8 <etext+0x5f8>
    8000429e:	8d7fc0ef          	jal	80000b74 <initlock>
  (*f0)->type = FD_PIPE;
    800042a2:	609c                	ld	a5,0(s1)
    800042a4:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    800042a8:	609c                	ld	a5,0(s1)
    800042aa:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    800042ae:	609c                	ld	a5,0(s1)
    800042b0:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    800042b4:	609c                	ld	a5,0(s1)
    800042b6:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    800042ba:	000a3783          	ld	a5,0(s4)
    800042be:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    800042c2:	000a3783          	ld	a5,0(s4)
    800042c6:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    800042ca:	000a3783          	ld	a5,0(s4)
    800042ce:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    800042d2:	000a3783          	ld	a5,0(s4)
    800042d6:	0127b823          	sd	s2,16(a5)
  return 0;
    800042da:	4501                	li	a0,0
    800042dc:	6942                	ld	s2,16(sp)
    800042de:	69a2                	ld	s3,8(sp)
    800042e0:	a01d                	j	80004306 <pipealloc+0xb8>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    800042e2:	6088                	ld	a0,0(s1)
    800042e4:	c119                	beqz	a0,800042ea <pipealloc+0x9c>
    800042e6:	6942                	ld	s2,16(sp)
    800042e8:	a029                	j	800042f2 <pipealloc+0xa4>
    800042ea:	6942                	ld	s2,16(sp)
    800042ec:	a029                	j	800042f6 <pipealloc+0xa8>
    800042ee:	6088                	ld	a0,0(s1)
    800042f0:	c10d                	beqz	a0,80004312 <pipealloc+0xc4>
    fileclose(*f0);
    800042f2:	c53ff0ef          	jal	80003f44 <fileclose>
  if(*f1)
    800042f6:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    800042fa:	557d                	li	a0,-1
  if(*f1)
    800042fc:	c789                	beqz	a5,80004306 <pipealloc+0xb8>
    fileclose(*f1);
    800042fe:	853e                	mv	a0,a5
    80004300:	c45ff0ef          	jal	80003f44 <fileclose>
  return -1;
    80004304:	557d                	li	a0,-1
}
    80004306:	70a2                	ld	ra,40(sp)
    80004308:	7402                	ld	s0,32(sp)
    8000430a:	64e2                	ld	s1,24(sp)
    8000430c:	6a02                	ld	s4,0(sp)
    8000430e:	6145                	addi	sp,sp,48
    80004310:	8082                	ret
  return -1;
    80004312:	557d                	li	a0,-1
    80004314:	bfcd                	j	80004306 <pipealloc+0xb8>

0000000080004316 <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004316:	1101                	addi	sp,sp,-32
    80004318:	ec06                	sd	ra,24(sp)
    8000431a:	e822                	sd	s0,16(sp)
    8000431c:	e426                	sd	s1,8(sp)
    8000431e:	e04a                	sd	s2,0(sp)
    80004320:	1000                	addi	s0,sp,32
    80004322:	84aa                	mv	s1,a0
    80004324:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004326:	8cffc0ef          	jal	80000bf4 <acquire>
  if(writable){
    8000432a:	02090763          	beqz	s2,80004358 <pipeclose+0x42>
    pi->writeopen = 0;
    8000432e:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004332:	21848513          	addi	a0,s1,536
    80004336:	c43fd0ef          	jal	80001f78 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    8000433a:	2204b783          	ld	a5,544(s1)
    8000433e:	e785                	bnez	a5,80004366 <pipeclose+0x50>
    release(&pi->lock);
    80004340:	8526                	mv	a0,s1
    80004342:	94bfc0ef          	jal	80000c8c <release>
    kfree((char*)pi);
    80004346:	8526                	mv	a0,s1
    80004348:	efafc0ef          	jal	80000a42 <kfree>
  } else
    release(&pi->lock);
}
    8000434c:	60e2                	ld	ra,24(sp)
    8000434e:	6442                	ld	s0,16(sp)
    80004350:	64a2                	ld	s1,8(sp)
    80004352:	6902                	ld	s2,0(sp)
    80004354:	6105                	addi	sp,sp,32
    80004356:	8082                	ret
    pi->readopen = 0;
    80004358:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    8000435c:	21c48513          	addi	a0,s1,540
    80004360:	c19fd0ef          	jal	80001f78 <wakeup>
    80004364:	bfd9                	j	8000433a <pipeclose+0x24>
    release(&pi->lock);
    80004366:	8526                	mv	a0,s1
    80004368:	925fc0ef          	jal	80000c8c <release>
}
    8000436c:	b7c5                	j	8000434c <pipeclose+0x36>

000000008000436e <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    8000436e:	711d                	addi	sp,sp,-96
    80004370:	ec86                	sd	ra,88(sp)
    80004372:	e8a2                	sd	s0,80(sp)
    80004374:	e4a6                	sd	s1,72(sp)
    80004376:	e0ca                	sd	s2,64(sp)
    80004378:	fc4e                	sd	s3,56(sp)
    8000437a:	f852                	sd	s4,48(sp)
    8000437c:	f456                	sd	s5,40(sp)
    8000437e:	1080                	addi	s0,sp,96
    80004380:	84aa                	mv	s1,a0
    80004382:	8aae                	mv	s5,a1
    80004384:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004386:	d5afd0ef          	jal	800018e0 <myproc>
    8000438a:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    8000438c:	8526                	mv	a0,s1
    8000438e:	867fc0ef          	jal	80000bf4 <acquire>
  while(i < n){
    80004392:	0b405a63          	blez	s4,80004446 <pipewrite+0xd8>
    80004396:	f05a                	sd	s6,32(sp)
    80004398:	ec5e                	sd	s7,24(sp)
    8000439a:	e862                	sd	s8,16(sp)
  int i = 0;
    8000439c:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    8000439e:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    800043a0:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    800043a4:	21c48b93          	addi	s7,s1,540
    800043a8:	a81d                	j	800043de <pipewrite+0x70>
      release(&pi->lock);
    800043aa:	8526                	mv	a0,s1
    800043ac:	8e1fc0ef          	jal	80000c8c <release>
      return -1;
    800043b0:	597d                	li	s2,-1
    800043b2:	7b02                	ld	s6,32(sp)
    800043b4:	6be2                	ld	s7,24(sp)
    800043b6:	6c42                	ld	s8,16(sp)
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    800043b8:	854a                	mv	a0,s2
    800043ba:	60e6                	ld	ra,88(sp)
    800043bc:	6446                	ld	s0,80(sp)
    800043be:	64a6                	ld	s1,72(sp)
    800043c0:	6906                	ld	s2,64(sp)
    800043c2:	79e2                	ld	s3,56(sp)
    800043c4:	7a42                	ld	s4,48(sp)
    800043c6:	7aa2                	ld	s5,40(sp)
    800043c8:	6125                	addi	sp,sp,96
    800043ca:	8082                	ret
      wakeup(&pi->nread);
    800043cc:	8562                	mv	a0,s8
    800043ce:	babfd0ef          	jal	80001f78 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    800043d2:	85a6                	mv	a1,s1
    800043d4:	855e                	mv	a0,s7
    800043d6:	b57fd0ef          	jal	80001f2c <sleep>
  while(i < n){
    800043da:	05495b63          	bge	s2,s4,80004430 <pipewrite+0xc2>
    if(pi->readopen == 0 || killed(pr)){
    800043de:	2204a783          	lw	a5,544(s1)
    800043e2:	d7e1                	beqz	a5,800043aa <pipewrite+0x3c>
    800043e4:	854e                	mv	a0,s3
    800043e6:	d7ffd0ef          	jal	80002164 <killed>
    800043ea:	f161                	bnez	a0,800043aa <pipewrite+0x3c>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    800043ec:	2184a783          	lw	a5,536(s1)
    800043f0:	21c4a703          	lw	a4,540(s1)
    800043f4:	2007879b          	addiw	a5,a5,512
    800043f8:	fcf70ae3          	beq	a4,a5,800043cc <pipewrite+0x5e>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    800043fc:	4685                	li	a3,1
    800043fe:	01590633          	add	a2,s2,s5
    80004402:	faf40593          	addi	a1,s0,-81
    80004406:	0509b503          	ld	a0,80(s3)
    8000440a:	a1efd0ef          	jal	80001628 <copyin>
    8000440e:	03650e63          	beq	a0,s6,8000444a <pipewrite+0xdc>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004412:	21c4a783          	lw	a5,540(s1)
    80004416:	0017871b          	addiw	a4,a5,1
    8000441a:	20e4ae23          	sw	a4,540(s1)
    8000441e:	1ff7f793          	andi	a5,a5,511
    80004422:	97a6                	add	a5,a5,s1
    80004424:	faf44703          	lbu	a4,-81(s0)
    80004428:	00e78c23          	sb	a4,24(a5)
      i++;
    8000442c:	2905                	addiw	s2,s2,1
    8000442e:	b775                	j	800043da <pipewrite+0x6c>
    80004430:	7b02                	ld	s6,32(sp)
    80004432:	6be2                	ld	s7,24(sp)
    80004434:	6c42                	ld	s8,16(sp)
  wakeup(&pi->nread);
    80004436:	21848513          	addi	a0,s1,536
    8000443a:	b3ffd0ef          	jal	80001f78 <wakeup>
  release(&pi->lock);
    8000443e:	8526                	mv	a0,s1
    80004440:	84dfc0ef          	jal	80000c8c <release>
  return i;
    80004444:	bf95                	j	800043b8 <pipewrite+0x4a>
  int i = 0;
    80004446:	4901                	li	s2,0
    80004448:	b7fd                	j	80004436 <pipewrite+0xc8>
    8000444a:	7b02                	ld	s6,32(sp)
    8000444c:	6be2                	ld	s7,24(sp)
    8000444e:	6c42                	ld	s8,16(sp)
    80004450:	b7dd                	j	80004436 <pipewrite+0xc8>

0000000080004452 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004452:	715d                	addi	sp,sp,-80
    80004454:	e486                	sd	ra,72(sp)
    80004456:	e0a2                	sd	s0,64(sp)
    80004458:	fc26                	sd	s1,56(sp)
    8000445a:	f84a                	sd	s2,48(sp)
    8000445c:	f44e                	sd	s3,40(sp)
    8000445e:	f052                	sd	s4,32(sp)
    80004460:	ec56                	sd	s5,24(sp)
    80004462:	0880                	addi	s0,sp,80
    80004464:	84aa                	mv	s1,a0
    80004466:	892e                	mv	s2,a1
    80004468:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    8000446a:	c76fd0ef          	jal	800018e0 <myproc>
    8000446e:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004470:	8526                	mv	a0,s1
    80004472:	f82fc0ef          	jal	80000bf4 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004476:	2184a703          	lw	a4,536(s1)
    8000447a:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    8000447e:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004482:	02f71563          	bne	a4,a5,800044ac <piperead+0x5a>
    80004486:	2244a783          	lw	a5,548(s1)
    8000448a:	cb85                	beqz	a5,800044ba <piperead+0x68>
    if(killed(pr)){
    8000448c:	8552                	mv	a0,s4
    8000448e:	cd7fd0ef          	jal	80002164 <killed>
    80004492:	ed19                	bnez	a0,800044b0 <piperead+0x5e>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004494:	85a6                	mv	a1,s1
    80004496:	854e                	mv	a0,s3
    80004498:	a95fd0ef          	jal	80001f2c <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    8000449c:	2184a703          	lw	a4,536(s1)
    800044a0:	21c4a783          	lw	a5,540(s1)
    800044a4:	fef701e3          	beq	a4,a5,80004486 <piperead+0x34>
    800044a8:	e85a                	sd	s6,16(sp)
    800044aa:	a809                	j	800044bc <piperead+0x6a>
    800044ac:	e85a                	sd	s6,16(sp)
    800044ae:	a039                	j	800044bc <piperead+0x6a>
      release(&pi->lock);
    800044b0:	8526                	mv	a0,s1
    800044b2:	fdafc0ef          	jal	80000c8c <release>
      return -1;
    800044b6:	59fd                	li	s3,-1
    800044b8:	a8b1                	j	80004514 <piperead+0xc2>
    800044ba:	e85a                	sd	s6,16(sp)
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800044bc:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800044be:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800044c0:	05505263          	blez	s5,80004504 <piperead+0xb2>
    if(pi->nread == pi->nwrite)
    800044c4:	2184a783          	lw	a5,536(s1)
    800044c8:	21c4a703          	lw	a4,540(s1)
    800044cc:	02f70c63          	beq	a4,a5,80004504 <piperead+0xb2>
    ch = pi->data[pi->nread++ % PIPESIZE];
    800044d0:	0017871b          	addiw	a4,a5,1
    800044d4:	20e4ac23          	sw	a4,536(s1)
    800044d8:	1ff7f793          	andi	a5,a5,511
    800044dc:	97a6                	add	a5,a5,s1
    800044de:	0187c783          	lbu	a5,24(a5)
    800044e2:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    800044e6:	4685                	li	a3,1
    800044e8:	fbf40613          	addi	a2,s0,-65
    800044ec:	85ca                	mv	a1,s2
    800044ee:	050a3503          	ld	a0,80(s4)
    800044f2:	860fd0ef          	jal	80001552 <copyout>
    800044f6:	01650763          	beq	a0,s6,80004504 <piperead+0xb2>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    800044fa:	2985                	addiw	s3,s3,1
    800044fc:	0905                	addi	s2,s2,1
    800044fe:	fd3a93e3          	bne	s5,s3,800044c4 <piperead+0x72>
    80004502:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004504:	21c48513          	addi	a0,s1,540
    80004508:	a71fd0ef          	jal	80001f78 <wakeup>
  release(&pi->lock);
    8000450c:	8526                	mv	a0,s1
    8000450e:	f7efc0ef          	jal	80000c8c <release>
    80004512:	6b42                	ld	s6,16(sp)
  return i;
}
    80004514:	854e                	mv	a0,s3
    80004516:	60a6                	ld	ra,72(sp)
    80004518:	6406                	ld	s0,64(sp)
    8000451a:	74e2                	ld	s1,56(sp)
    8000451c:	7942                	ld	s2,48(sp)
    8000451e:	79a2                	ld	s3,40(sp)
    80004520:	7a02                	ld	s4,32(sp)
    80004522:	6ae2                	ld	s5,24(sp)
    80004524:	6161                	addi	sp,sp,80
    80004526:	8082                	ret

0000000080004528 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004528:	1141                	addi	sp,sp,-16
    8000452a:	e422                	sd	s0,8(sp)
    8000452c:	0800                	addi	s0,sp,16
    8000452e:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004530:	8905                	andi	a0,a0,1
    80004532:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004534:	8b89                	andi	a5,a5,2
    80004536:	c399                	beqz	a5,8000453c <flags2perm+0x14>
      perm |= PTE_W;
    80004538:	00456513          	ori	a0,a0,4
    return perm;
}
    8000453c:	6422                	ld	s0,8(sp)
    8000453e:	0141                	addi	sp,sp,16
    80004540:	8082                	ret

0000000080004542 <exec>:

int
exec(char *path, char **argv)
{
    80004542:	df010113          	addi	sp,sp,-528
    80004546:	20113423          	sd	ra,520(sp)
    8000454a:	20813023          	sd	s0,512(sp)
    8000454e:	ffa6                	sd	s1,504(sp)
    80004550:	fbca                	sd	s2,496(sp)
    80004552:	0c00                	addi	s0,sp,528
    80004554:	892a                	mv	s2,a0
    80004556:	dea43c23          	sd	a0,-520(s0)
    8000455a:	e0b43023          	sd	a1,-512(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    8000455e:	b82fd0ef          	jal	800018e0 <myproc>
    80004562:	84aa                	mv	s1,a0

  begin_op();
    80004564:	dc6ff0ef          	jal	80003b2a <begin_op>

  if((ip = namei(path)) == 0){
    80004568:	854a                	mv	a0,s2
    8000456a:	c04ff0ef          	jal	8000396e <namei>
    8000456e:	c931                	beqz	a0,800045c2 <exec+0x80>
    80004570:	f3d2                	sd	s4,480(sp)
    80004572:	8a2a                	mv	s4,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004574:	d21fe0ef          	jal	80003294 <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004578:	04000713          	li	a4,64
    8000457c:	4681                	li	a3,0
    8000457e:	e5040613          	addi	a2,s0,-432
    80004582:	4581                	li	a1,0
    80004584:	8552                	mv	a0,s4
    80004586:	f63fe0ef          	jal	800034e8 <readi>
    8000458a:	04000793          	li	a5,64
    8000458e:	00f51a63          	bne	a0,a5,800045a2 <exec+0x60>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004592:	e5042703          	lw	a4,-432(s0)
    80004596:	464c47b7          	lui	a5,0x464c4
    8000459a:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    8000459e:	02f70663          	beq	a4,a5,800045ca <exec+0x88>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    800045a2:	8552                	mv	a0,s4
    800045a4:	efbfe0ef          	jal	8000349e <iunlockput>
    end_op();
    800045a8:	decff0ef          	jal	80003b94 <end_op>
  }
  return -1;
    800045ac:	557d                	li	a0,-1
    800045ae:	7a1e                	ld	s4,480(sp)
}
    800045b0:	20813083          	ld	ra,520(sp)
    800045b4:	20013403          	ld	s0,512(sp)
    800045b8:	74fe                	ld	s1,504(sp)
    800045ba:	795e                	ld	s2,496(sp)
    800045bc:	21010113          	addi	sp,sp,528
    800045c0:	8082                	ret
    end_op();
    800045c2:	dd2ff0ef          	jal	80003b94 <end_op>
    return -1;
    800045c6:	557d                	li	a0,-1
    800045c8:	b7e5                	j	800045b0 <exec+0x6e>
    800045ca:	ebda                	sd	s6,464(sp)
  if((pagetable = proc_pagetable(p)) == 0)
    800045cc:	8526                	mv	a0,s1
    800045ce:	bbafd0ef          	jal	80001988 <proc_pagetable>
    800045d2:	8b2a                	mv	s6,a0
    800045d4:	2c050b63          	beqz	a0,800048aa <exec+0x368>
    800045d8:	f7ce                	sd	s3,488(sp)
    800045da:	efd6                	sd	s5,472(sp)
    800045dc:	e7de                	sd	s7,456(sp)
    800045de:	e3e2                	sd	s8,448(sp)
    800045e0:	ff66                	sd	s9,440(sp)
    800045e2:	fb6a                	sd	s10,432(sp)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800045e4:	e7042d03          	lw	s10,-400(s0)
    800045e8:	e8845783          	lhu	a5,-376(s0)
    800045ec:	12078963          	beqz	a5,8000471e <exec+0x1dc>
    800045f0:	f76e                	sd	s11,424(sp)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    800045f2:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    800045f4:	4d81                	li	s11,0
    if(ph.vaddr % PGSIZE != 0)
    800045f6:	6c85                	lui	s9,0x1
    800045f8:	fffc8793          	addi	a5,s9,-1 # fff <_entry-0x7ffff001>
    800045fc:	def43823          	sd	a5,-528(s0)

  for(i = 0; i < sz; i += PGSIZE){
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    if(sz - i < PGSIZE)
    80004600:	6a85                	lui	s5,0x1
    80004602:	a085                	j	80004662 <exec+0x120>
      panic("loadseg: address should exist");
    80004604:	00003517          	auipc	a0,0x3
    80004608:	ffc50513          	addi	a0,a0,-4 # 80007600 <etext+0x600>
    8000460c:	988fc0ef          	jal	80000794 <panic>
    if(sz - i < PGSIZE)
    80004610:	2481                	sext.w	s1,s1
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004612:	8726                	mv	a4,s1
    80004614:	012c06bb          	addw	a3,s8,s2
    80004618:	4581                	li	a1,0
    8000461a:	8552                	mv	a0,s4
    8000461c:	ecdfe0ef          	jal	800034e8 <readi>
    80004620:	2501                	sext.w	a0,a0
    80004622:	24a49a63          	bne	s1,a0,80004876 <exec+0x334>
  for(i = 0; i < sz; i += PGSIZE){
    80004626:	012a893b          	addw	s2,s5,s2
    8000462a:	03397363          	bgeu	s2,s3,80004650 <exec+0x10e>
    pa = walkaddr(pagetable, va + i);
    8000462e:	02091593          	slli	a1,s2,0x20
    80004632:	9181                	srli	a1,a1,0x20
    80004634:	95de                	add	a1,a1,s7
    80004636:	855a                	mv	a0,s6
    80004638:	99ffc0ef          	jal	80000fd6 <walkaddr>
    8000463c:	862a                	mv	a2,a0
    if(pa == 0)
    8000463e:	d179                	beqz	a0,80004604 <exec+0xc2>
    if(sz - i < PGSIZE)
    80004640:	412984bb          	subw	s1,s3,s2
    80004644:	0004879b          	sext.w	a5,s1
    80004648:	fcfcf4e3          	bgeu	s9,a5,80004610 <exec+0xce>
    8000464c:	84d6                	mv	s1,s5
    8000464e:	b7c9                	j	80004610 <exec+0xce>
    sz = sz1;
    80004650:	e0843903          	ld	s2,-504(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004654:	2d85                	addiw	s11,s11,1
    80004656:	038d0d1b          	addiw	s10,s10,56 # 1038 <_entry-0x7fffefc8>
    8000465a:	e8845783          	lhu	a5,-376(s0)
    8000465e:	08fdd063          	bge	s11,a5,800046de <exec+0x19c>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80004662:	2d01                	sext.w	s10,s10
    80004664:	03800713          	li	a4,56
    80004668:	86ea                	mv	a3,s10
    8000466a:	e1840613          	addi	a2,s0,-488
    8000466e:	4581                	li	a1,0
    80004670:	8552                	mv	a0,s4
    80004672:	e77fe0ef          	jal	800034e8 <readi>
    80004676:	03800793          	li	a5,56
    8000467a:	1cf51663          	bne	a0,a5,80004846 <exec+0x304>
    if(ph.type != ELF_PROG_LOAD)
    8000467e:	e1842783          	lw	a5,-488(s0)
    80004682:	4705                	li	a4,1
    80004684:	fce798e3          	bne	a5,a4,80004654 <exec+0x112>
    if(ph.memsz < ph.filesz)
    80004688:	e4043483          	ld	s1,-448(s0)
    8000468c:	e3843783          	ld	a5,-456(s0)
    80004690:	1af4ef63          	bltu	s1,a5,8000484e <exec+0x30c>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    80004694:	e2843783          	ld	a5,-472(s0)
    80004698:	94be                	add	s1,s1,a5
    8000469a:	1af4ee63          	bltu	s1,a5,80004856 <exec+0x314>
    if(ph.vaddr % PGSIZE != 0)
    8000469e:	df043703          	ld	a4,-528(s0)
    800046a2:	8ff9                	and	a5,a5,a4
    800046a4:	1a079d63          	bnez	a5,8000485e <exec+0x31c>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800046a8:	e1c42503          	lw	a0,-484(s0)
    800046ac:	e7dff0ef          	jal	80004528 <flags2perm>
    800046b0:	86aa                	mv	a3,a0
    800046b2:	8626                	mv	a2,s1
    800046b4:	85ca                	mv	a1,s2
    800046b6:	855a                	mv	a0,s6
    800046b8:	c87fc0ef          	jal	8000133e <uvmalloc>
    800046bc:	e0a43423          	sd	a0,-504(s0)
    800046c0:	1a050363          	beqz	a0,80004866 <exec+0x324>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800046c4:	e2843b83          	ld	s7,-472(s0)
    800046c8:	e2042c03          	lw	s8,-480(s0)
    800046cc:	e3842983          	lw	s3,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800046d0:	00098463          	beqz	s3,800046d8 <exec+0x196>
    800046d4:	4901                	li	s2,0
    800046d6:	bfa1                	j	8000462e <exec+0xec>
    sz = sz1;
    800046d8:	e0843903          	ld	s2,-504(s0)
    800046dc:	bfa5                	j	80004654 <exec+0x112>
    800046de:	7dba                	ld	s11,424(sp)
  iunlockput(ip);
    800046e0:	8552                	mv	a0,s4
    800046e2:	dbdfe0ef          	jal	8000349e <iunlockput>
  end_op();
    800046e6:	caeff0ef          	jal	80003b94 <end_op>
  p = myproc();
    800046ea:	9f6fd0ef          	jal	800018e0 <myproc>
    800046ee:	8aaa                	mv	s5,a0
  uint64 oldsz = p->sz;
    800046f0:	04853c83          	ld	s9,72(a0)
  sz = PGROUNDUP(sz);
    800046f4:	6985                	lui	s3,0x1
    800046f6:	19fd                	addi	s3,s3,-1 # fff <_entry-0x7ffff001>
    800046f8:	99ca                	add	s3,s3,s2
    800046fa:	77fd                	lui	a5,0xfffff
    800046fc:	00f9f9b3          	and	s3,s3,a5
  if((sz1 = uvmalloc(pagetable, sz, sz + (USERSTACK+1)*PGSIZE, PTE_W)) == 0)
    80004700:	4691                	li	a3,4
    80004702:	6609                	lui	a2,0x2
    80004704:	964e                	add	a2,a2,s3
    80004706:	85ce                	mv	a1,s3
    80004708:	855a                	mv	a0,s6
    8000470a:	c35fc0ef          	jal	8000133e <uvmalloc>
    8000470e:	892a                	mv	s2,a0
    80004710:	e0a43423          	sd	a0,-504(s0)
    80004714:	e519                	bnez	a0,80004722 <exec+0x1e0>
  if(pagetable)
    80004716:	e1343423          	sd	s3,-504(s0)
    8000471a:	4a01                	li	s4,0
    8000471c:	aab1                	j	80004878 <exec+0x336>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    8000471e:	4901                	li	s2,0
    80004720:	b7c1                	j	800046e0 <exec+0x19e>
  uvmclear(pagetable, sz-(USERSTACK+1)*PGSIZE);
    80004722:	75f9                	lui	a1,0xffffe
    80004724:	95aa                	add	a1,a1,a0
    80004726:	855a                	mv	a0,s6
    80004728:	e01fc0ef          	jal	80001528 <uvmclear>
  stackbase = sp - USERSTACK*PGSIZE;
    8000472c:	7bfd                	lui	s7,0xfffff
    8000472e:	9bca                	add	s7,s7,s2
  for(argc = 0; argv[argc]; argc++) {
    80004730:	e0043783          	ld	a5,-512(s0)
    80004734:	6388                	ld	a0,0(a5)
    80004736:	cd39                	beqz	a0,80004794 <exec+0x252>
    80004738:	e9040993          	addi	s3,s0,-368
    8000473c:	f9040c13          	addi	s8,s0,-112
    80004740:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004742:	ef6fc0ef          	jal	80000e38 <strlen>
    80004746:	0015079b          	addiw	a5,a0,1
    8000474a:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    8000474e:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80004752:	11796e63          	bltu	s2,s7,8000486e <exec+0x32c>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80004756:	e0043d03          	ld	s10,-512(s0)
    8000475a:	000d3a03          	ld	s4,0(s10)
    8000475e:	8552                	mv	a0,s4
    80004760:	ed8fc0ef          	jal	80000e38 <strlen>
    80004764:	0015069b          	addiw	a3,a0,1
    80004768:	8652                	mv	a2,s4
    8000476a:	85ca                	mv	a1,s2
    8000476c:	855a                	mv	a0,s6
    8000476e:	de5fc0ef          	jal	80001552 <copyout>
    80004772:	10054063          	bltz	a0,80004872 <exec+0x330>
    ustack[argc] = sp;
    80004776:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    8000477a:	0485                	addi	s1,s1,1
    8000477c:	008d0793          	addi	a5,s10,8
    80004780:	e0f43023          	sd	a5,-512(s0)
    80004784:	008d3503          	ld	a0,8(s10)
    80004788:	c909                	beqz	a0,8000479a <exec+0x258>
    if(argc >= MAXARG)
    8000478a:	09a1                	addi	s3,s3,8
    8000478c:	fb899be3          	bne	s3,s8,80004742 <exec+0x200>
  ip = 0;
    80004790:	4a01                	li	s4,0
    80004792:	a0dd                	j	80004878 <exec+0x336>
  sp = sz;
    80004794:	e0843903          	ld	s2,-504(s0)
  for(argc = 0; argv[argc]; argc++) {
    80004798:	4481                	li	s1,0
  ustack[argc] = 0;
    8000479a:	00349793          	slli	a5,s1,0x3
    8000479e:	f9078793          	addi	a5,a5,-112 # ffffffffffffef90 <end+0xffffffff7ffdb3e0>
    800047a2:	97a2                	add	a5,a5,s0
    800047a4:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    800047a8:	00148693          	addi	a3,s1,1
    800047ac:	068e                	slli	a3,a3,0x3
    800047ae:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    800047b2:	ff097913          	andi	s2,s2,-16
  sz = sz1;
    800047b6:	e0843983          	ld	s3,-504(s0)
  if(sp < stackbase)
    800047ba:	f5796ee3          	bltu	s2,s7,80004716 <exec+0x1d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    800047be:	e9040613          	addi	a2,s0,-368
    800047c2:	85ca                	mv	a1,s2
    800047c4:	855a                	mv	a0,s6
    800047c6:	d8dfc0ef          	jal	80001552 <copyout>
    800047ca:	0e054263          	bltz	a0,800048ae <exec+0x36c>
  p->trapframe->a1 = sp;
    800047ce:	058ab783          	ld	a5,88(s5) # 1058 <_entry-0x7fffefa8>
    800047d2:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    800047d6:	df843783          	ld	a5,-520(s0)
    800047da:	0007c703          	lbu	a4,0(a5)
    800047de:	cf11                	beqz	a4,800047fa <exec+0x2b8>
    800047e0:	0785                	addi	a5,a5,1
    if(*s == '/')
    800047e2:	02f00693          	li	a3,47
    800047e6:	a039                	j	800047f4 <exec+0x2b2>
      last = s+1;
    800047e8:	def43c23          	sd	a5,-520(s0)
  for(last=s=path; *s; s++)
    800047ec:	0785                	addi	a5,a5,1
    800047ee:	fff7c703          	lbu	a4,-1(a5)
    800047f2:	c701                	beqz	a4,800047fa <exec+0x2b8>
    if(*s == '/')
    800047f4:	fed71ce3          	bne	a4,a3,800047ec <exec+0x2aa>
    800047f8:	bfc5                	j	800047e8 <exec+0x2a6>
  safestrcpy(p->name, last, sizeof(p->name));
    800047fa:	4641                	li	a2,16
    800047fc:	df843583          	ld	a1,-520(s0)
    80004800:	158a8513          	addi	a0,s5,344
    80004804:	e02fc0ef          	jal	80000e06 <safestrcpy>
  oldpagetable = p->pagetable;
    80004808:	050ab503          	ld	a0,80(s5)
  p->pagetable = pagetable;
    8000480c:	056ab823          	sd	s6,80(s5)
  p->sz = sz;
    80004810:	e0843783          	ld	a5,-504(s0)
    80004814:	04fab423          	sd	a5,72(s5)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    80004818:	058ab783          	ld	a5,88(s5)
    8000481c:	e6843703          	ld	a4,-408(s0)
    80004820:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    80004822:	058ab783          	ld	a5,88(s5)
    80004826:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    8000482a:	85e6                	mv	a1,s9
    8000482c:	9e0fd0ef          	jal	80001a0c <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    80004830:	0004851b          	sext.w	a0,s1
    80004834:	79be                	ld	s3,488(sp)
    80004836:	7a1e                	ld	s4,480(sp)
    80004838:	6afe                	ld	s5,472(sp)
    8000483a:	6b5e                	ld	s6,464(sp)
    8000483c:	6bbe                	ld	s7,456(sp)
    8000483e:	6c1e                	ld	s8,448(sp)
    80004840:	7cfa                	ld	s9,440(sp)
    80004842:	7d5a                	ld	s10,432(sp)
    80004844:	b3b5                	j	800045b0 <exec+0x6e>
    80004846:	e1243423          	sd	s2,-504(s0)
    8000484a:	7dba                	ld	s11,424(sp)
    8000484c:	a035                	j	80004878 <exec+0x336>
    8000484e:	e1243423          	sd	s2,-504(s0)
    80004852:	7dba                	ld	s11,424(sp)
    80004854:	a015                	j	80004878 <exec+0x336>
    80004856:	e1243423          	sd	s2,-504(s0)
    8000485a:	7dba                	ld	s11,424(sp)
    8000485c:	a831                	j	80004878 <exec+0x336>
    8000485e:	e1243423          	sd	s2,-504(s0)
    80004862:	7dba                	ld	s11,424(sp)
    80004864:	a811                	j	80004878 <exec+0x336>
    80004866:	e1243423          	sd	s2,-504(s0)
    8000486a:	7dba                	ld	s11,424(sp)
    8000486c:	a031                	j	80004878 <exec+0x336>
  ip = 0;
    8000486e:	4a01                	li	s4,0
    80004870:	a021                	j	80004878 <exec+0x336>
    80004872:	4a01                	li	s4,0
  if(pagetable)
    80004874:	a011                	j	80004878 <exec+0x336>
    80004876:	7dba                	ld	s11,424(sp)
    proc_freepagetable(pagetable, sz);
    80004878:	e0843583          	ld	a1,-504(s0)
    8000487c:	855a                	mv	a0,s6
    8000487e:	98efd0ef          	jal	80001a0c <proc_freepagetable>
  return -1;
    80004882:	557d                	li	a0,-1
  if(ip){
    80004884:	000a1b63          	bnez	s4,8000489a <exec+0x358>
    80004888:	79be                	ld	s3,488(sp)
    8000488a:	7a1e                	ld	s4,480(sp)
    8000488c:	6afe                	ld	s5,472(sp)
    8000488e:	6b5e                	ld	s6,464(sp)
    80004890:	6bbe                	ld	s7,456(sp)
    80004892:	6c1e                	ld	s8,448(sp)
    80004894:	7cfa                	ld	s9,440(sp)
    80004896:	7d5a                	ld	s10,432(sp)
    80004898:	bb21                	j	800045b0 <exec+0x6e>
    8000489a:	79be                	ld	s3,488(sp)
    8000489c:	6afe                	ld	s5,472(sp)
    8000489e:	6b5e                	ld	s6,464(sp)
    800048a0:	6bbe                	ld	s7,456(sp)
    800048a2:	6c1e                	ld	s8,448(sp)
    800048a4:	7cfa                	ld	s9,440(sp)
    800048a6:	7d5a                	ld	s10,432(sp)
    800048a8:	b9ed                	j	800045a2 <exec+0x60>
    800048aa:	6b5e                	ld	s6,464(sp)
    800048ac:	b9dd                	j	800045a2 <exec+0x60>
  sz = sz1;
    800048ae:	e0843983          	ld	s3,-504(s0)
    800048b2:	b595                	j	80004716 <exec+0x1d4>

00000000800048b4 <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800048b4:	7179                	addi	sp,sp,-48
    800048b6:	f406                	sd	ra,40(sp)
    800048b8:	f022                	sd	s0,32(sp)
    800048ba:	ec26                	sd	s1,24(sp)
    800048bc:	e84a                	sd	s2,16(sp)
    800048be:	1800                	addi	s0,sp,48
    800048c0:	892e                	mv	s2,a1
    800048c2:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800048c4:	fdc40593          	addi	a1,s0,-36
    800048c8:	f4bfd0ef          	jal	80002812 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    800048cc:	fdc42703          	lw	a4,-36(s0)
    800048d0:	47bd                	li	a5,15
    800048d2:	02e7e963          	bltu	a5,a4,80004904 <argfd+0x50>
    800048d6:	80afd0ef          	jal	800018e0 <myproc>
    800048da:	fdc42703          	lw	a4,-36(s0)
    800048de:	01a70793          	addi	a5,a4,26
    800048e2:	078e                	slli	a5,a5,0x3
    800048e4:	953e                	add	a0,a0,a5
    800048e6:	611c                	ld	a5,0(a0)
    800048e8:	c385                	beqz	a5,80004908 <argfd+0x54>
    return -1;
  if(pfd)
    800048ea:	00090463          	beqz	s2,800048f2 <argfd+0x3e>
    *pfd = fd;
    800048ee:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    800048f2:	4501                	li	a0,0
  if(pf)
    800048f4:	c091                	beqz	s1,800048f8 <argfd+0x44>
    *pf = f;
    800048f6:	e09c                	sd	a5,0(s1)
}
    800048f8:	70a2                	ld	ra,40(sp)
    800048fa:	7402                	ld	s0,32(sp)
    800048fc:	64e2                	ld	s1,24(sp)
    800048fe:	6942                	ld	s2,16(sp)
    80004900:	6145                	addi	sp,sp,48
    80004902:	8082                	ret
    return -1;
    80004904:	557d                	li	a0,-1
    80004906:	bfcd                	j	800048f8 <argfd+0x44>
    80004908:	557d                	li	a0,-1
    8000490a:	b7fd                	j	800048f8 <argfd+0x44>

000000008000490c <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000490c:	1101                	addi	sp,sp,-32
    8000490e:	ec06                	sd	ra,24(sp)
    80004910:	e822                	sd	s0,16(sp)
    80004912:	e426                	sd	s1,8(sp)
    80004914:	1000                	addi	s0,sp,32
    80004916:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80004918:	fc9fc0ef          	jal	800018e0 <myproc>
    8000491c:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    8000491e:	0d050793          	addi	a5,a0,208
    80004922:	4501                	li	a0,0
    80004924:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80004926:	6398                	ld	a4,0(a5)
    80004928:	cb19                	beqz	a4,8000493e <fdalloc+0x32>
  for(fd = 0; fd < NOFILE; fd++){
    8000492a:	2505                	addiw	a0,a0,1
    8000492c:	07a1                	addi	a5,a5,8
    8000492e:	fed51ce3          	bne	a0,a3,80004926 <fdalloc+0x1a>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80004932:	557d                	li	a0,-1
}
    80004934:	60e2                	ld	ra,24(sp)
    80004936:	6442                	ld	s0,16(sp)
    80004938:	64a2                	ld	s1,8(sp)
    8000493a:	6105                	addi	sp,sp,32
    8000493c:	8082                	ret
      p->ofile[fd] = f;
    8000493e:	01a50793          	addi	a5,a0,26
    80004942:	078e                	slli	a5,a5,0x3
    80004944:	963e                	add	a2,a2,a5
    80004946:	e204                	sd	s1,0(a2)
      return fd;
    80004948:	b7f5                	j	80004934 <fdalloc+0x28>

000000008000494a <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000494a:	715d                	addi	sp,sp,-80
    8000494c:	e486                	sd	ra,72(sp)
    8000494e:	e0a2                	sd	s0,64(sp)
    80004950:	fc26                	sd	s1,56(sp)
    80004952:	f84a                	sd	s2,48(sp)
    80004954:	f44e                	sd	s3,40(sp)
    80004956:	ec56                	sd	s5,24(sp)
    80004958:	e85a                	sd	s6,16(sp)
    8000495a:	0880                	addi	s0,sp,80
    8000495c:	8b2e                	mv	s6,a1
    8000495e:	89b2                	mv	s3,a2
    80004960:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    80004962:	fb040593          	addi	a1,s0,-80
    80004966:	822ff0ef          	jal	80003988 <nameiparent>
    8000496a:	84aa                	mv	s1,a0
    8000496c:	10050a63          	beqz	a0,80004a80 <create+0x136>
    return 0;

  ilock(dp);
    80004970:	925fe0ef          	jal	80003294 <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    80004974:	4601                	li	a2,0
    80004976:	fb040593          	addi	a1,s0,-80
    8000497a:	8526                	mv	a0,s1
    8000497c:	d8dfe0ef          	jal	80003708 <dirlookup>
    80004980:	8aaa                	mv	s5,a0
    80004982:	c129                	beqz	a0,800049c4 <create+0x7a>
    iunlockput(dp);
    80004984:	8526                	mv	a0,s1
    80004986:	b19fe0ef          	jal	8000349e <iunlockput>
    ilock(ip);
    8000498a:	8556                	mv	a0,s5
    8000498c:	909fe0ef          	jal	80003294 <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    80004990:	4789                	li	a5,2
    80004992:	02fb1463          	bne	s6,a5,800049ba <create+0x70>
    80004996:	044ad783          	lhu	a5,68(s5)
    8000499a:	37f9                	addiw	a5,a5,-2
    8000499c:	17c2                	slli	a5,a5,0x30
    8000499e:	93c1                	srli	a5,a5,0x30
    800049a0:	4705                	li	a4,1
    800049a2:	00f76c63          	bltu	a4,a5,800049ba <create+0x70>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    800049a6:	8556                	mv	a0,s5
    800049a8:	60a6                	ld	ra,72(sp)
    800049aa:	6406                	ld	s0,64(sp)
    800049ac:	74e2                	ld	s1,56(sp)
    800049ae:	7942                	ld	s2,48(sp)
    800049b0:	79a2                	ld	s3,40(sp)
    800049b2:	6ae2                	ld	s5,24(sp)
    800049b4:	6b42                	ld	s6,16(sp)
    800049b6:	6161                	addi	sp,sp,80
    800049b8:	8082                	ret
    iunlockput(ip);
    800049ba:	8556                	mv	a0,s5
    800049bc:	ae3fe0ef          	jal	8000349e <iunlockput>
    return 0;
    800049c0:	4a81                	li	s5,0
    800049c2:	b7d5                	j	800049a6 <create+0x5c>
    800049c4:	f052                	sd	s4,32(sp)
  if((ip = ialloc(dp->dev, type)) == 0){
    800049c6:	85da                	mv	a1,s6
    800049c8:	4088                	lw	a0,0(s1)
    800049ca:	f5afe0ef          	jal	80003124 <ialloc>
    800049ce:	8a2a                	mv	s4,a0
    800049d0:	cd15                	beqz	a0,80004a0c <create+0xc2>
  ilock(ip);
    800049d2:	8c3fe0ef          	jal	80003294 <ilock>
  ip->major = major;
    800049d6:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    800049da:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    800049de:	4905                	li	s2,1
    800049e0:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    800049e4:	8552                	mv	a0,s4
    800049e6:	ffafe0ef          	jal	800031e0 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    800049ea:	032b0763          	beq	s6,s2,80004a18 <create+0xce>
  if(dirlink(dp, name, ip->inum) < 0)
    800049ee:	004a2603          	lw	a2,4(s4)
    800049f2:	fb040593          	addi	a1,s0,-80
    800049f6:	8526                	mv	a0,s1
    800049f8:	eddfe0ef          	jal	800038d4 <dirlink>
    800049fc:	06054563          	bltz	a0,80004a66 <create+0x11c>
  iunlockput(dp);
    80004a00:	8526                	mv	a0,s1
    80004a02:	a9dfe0ef          	jal	8000349e <iunlockput>
  return ip;
    80004a06:	8ad2                	mv	s5,s4
    80004a08:	7a02                	ld	s4,32(sp)
    80004a0a:	bf71                	j	800049a6 <create+0x5c>
    iunlockput(dp);
    80004a0c:	8526                	mv	a0,s1
    80004a0e:	a91fe0ef          	jal	8000349e <iunlockput>
    return 0;
    80004a12:	8ad2                	mv	s5,s4
    80004a14:	7a02                	ld	s4,32(sp)
    80004a16:	bf41                	j	800049a6 <create+0x5c>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80004a18:	004a2603          	lw	a2,4(s4)
    80004a1c:	00003597          	auipc	a1,0x3
    80004a20:	c0458593          	addi	a1,a1,-1020 # 80007620 <etext+0x620>
    80004a24:	8552                	mv	a0,s4
    80004a26:	eaffe0ef          	jal	800038d4 <dirlink>
    80004a2a:	02054e63          	bltz	a0,80004a66 <create+0x11c>
    80004a2e:	40d0                	lw	a2,4(s1)
    80004a30:	00003597          	auipc	a1,0x3
    80004a34:	bf858593          	addi	a1,a1,-1032 # 80007628 <etext+0x628>
    80004a38:	8552                	mv	a0,s4
    80004a3a:	e9bfe0ef          	jal	800038d4 <dirlink>
    80004a3e:	02054463          	bltz	a0,80004a66 <create+0x11c>
  if(dirlink(dp, name, ip->inum) < 0)
    80004a42:	004a2603          	lw	a2,4(s4)
    80004a46:	fb040593          	addi	a1,s0,-80
    80004a4a:	8526                	mv	a0,s1
    80004a4c:	e89fe0ef          	jal	800038d4 <dirlink>
    80004a50:	00054b63          	bltz	a0,80004a66 <create+0x11c>
    dp->nlink++;  // for ".."
    80004a54:	04a4d783          	lhu	a5,74(s1)
    80004a58:	2785                	addiw	a5,a5,1
    80004a5a:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004a5e:	8526                	mv	a0,s1
    80004a60:	f80fe0ef          	jal	800031e0 <iupdate>
    80004a64:	bf71                	j	80004a00 <create+0xb6>
  ip->nlink = 0;
    80004a66:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    80004a6a:	8552                	mv	a0,s4
    80004a6c:	f74fe0ef          	jal	800031e0 <iupdate>
  iunlockput(ip);
    80004a70:	8552                	mv	a0,s4
    80004a72:	a2dfe0ef          	jal	8000349e <iunlockput>
  iunlockput(dp);
    80004a76:	8526                	mv	a0,s1
    80004a78:	a27fe0ef          	jal	8000349e <iunlockput>
  return 0;
    80004a7c:	7a02                	ld	s4,32(sp)
    80004a7e:	b725                	j	800049a6 <create+0x5c>
    return 0;
    80004a80:	8aaa                	mv	s5,a0
    80004a82:	b715                	j	800049a6 <create+0x5c>

0000000080004a84 <sys_dup>:
{
    80004a84:	7179                	addi	sp,sp,-48
    80004a86:	f406                	sd	ra,40(sp)
    80004a88:	f022                	sd	s0,32(sp)
    80004a8a:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80004a8c:	fd840613          	addi	a2,s0,-40
    80004a90:	4581                	li	a1,0
    80004a92:	4501                	li	a0,0
    80004a94:	e21ff0ef          	jal	800048b4 <argfd>
    return -1;
    80004a98:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80004a9a:	02054363          	bltz	a0,80004ac0 <sys_dup+0x3c>
    80004a9e:	ec26                	sd	s1,24(sp)
    80004aa0:	e84a                	sd	s2,16(sp)
  if((fd=fdalloc(f)) < 0)
    80004aa2:	fd843903          	ld	s2,-40(s0)
    80004aa6:	854a                	mv	a0,s2
    80004aa8:	e65ff0ef          	jal	8000490c <fdalloc>
    80004aac:	84aa                	mv	s1,a0
    return -1;
    80004aae:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    80004ab0:	00054d63          	bltz	a0,80004aca <sys_dup+0x46>
  filedup(f);
    80004ab4:	854a                	mv	a0,s2
    80004ab6:	c48ff0ef          	jal	80003efe <filedup>
  return fd;
    80004aba:	87a6                	mv	a5,s1
    80004abc:	64e2                	ld	s1,24(sp)
    80004abe:	6942                	ld	s2,16(sp)
}
    80004ac0:	853e                	mv	a0,a5
    80004ac2:	70a2                	ld	ra,40(sp)
    80004ac4:	7402                	ld	s0,32(sp)
    80004ac6:	6145                	addi	sp,sp,48
    80004ac8:	8082                	ret
    80004aca:	64e2                	ld	s1,24(sp)
    80004acc:	6942                	ld	s2,16(sp)
    80004ace:	bfcd                	j	80004ac0 <sys_dup+0x3c>

0000000080004ad0 <sys_read>:
{
    80004ad0:	7179                	addi	sp,sp,-48
    80004ad2:	f406                	sd	ra,40(sp)
    80004ad4:	f022                	sd	s0,32(sp)
    80004ad6:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004ad8:	fd840593          	addi	a1,s0,-40
    80004adc:	4505                	li	a0,1
    80004ade:	d51fd0ef          	jal	8000282e <argaddr>
  argint(2, &n);
    80004ae2:	fe440593          	addi	a1,s0,-28
    80004ae6:	4509                	li	a0,2
    80004ae8:	d2bfd0ef          	jal	80002812 <argint>
  if(argfd(0, 0, &f) < 0)
    80004aec:	fe840613          	addi	a2,s0,-24
    80004af0:	4581                	li	a1,0
    80004af2:	4501                	li	a0,0
    80004af4:	dc1ff0ef          	jal	800048b4 <argfd>
    80004af8:	87aa                	mv	a5,a0
    return -1;
    80004afa:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004afc:	0007ca63          	bltz	a5,80004b10 <sys_read+0x40>
  return fileread(f, p, n);
    80004b00:	fe442603          	lw	a2,-28(s0)
    80004b04:	fd843583          	ld	a1,-40(s0)
    80004b08:	fe843503          	ld	a0,-24(s0)
    80004b0c:	d58ff0ef          	jal	80004064 <fileread>
}
    80004b10:	70a2                	ld	ra,40(sp)
    80004b12:	7402                	ld	s0,32(sp)
    80004b14:	6145                	addi	sp,sp,48
    80004b16:	8082                	ret

0000000080004b18 <sys_write>:
{
    80004b18:	7179                	addi	sp,sp,-48
    80004b1a:	f406                	sd	ra,40(sp)
    80004b1c:	f022                	sd	s0,32(sp)
    80004b1e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80004b20:	fd840593          	addi	a1,s0,-40
    80004b24:	4505                	li	a0,1
    80004b26:	d09fd0ef          	jal	8000282e <argaddr>
  argint(2, &n);
    80004b2a:	fe440593          	addi	a1,s0,-28
    80004b2e:	4509                	li	a0,2
    80004b30:	ce3fd0ef          	jal	80002812 <argint>
  if(argfd(0, 0, &f) < 0)
    80004b34:	fe840613          	addi	a2,s0,-24
    80004b38:	4581                	li	a1,0
    80004b3a:	4501                	li	a0,0
    80004b3c:	d79ff0ef          	jal	800048b4 <argfd>
    80004b40:	87aa                	mv	a5,a0
    return -1;
    80004b42:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004b44:	0007ca63          	bltz	a5,80004b58 <sys_write+0x40>
  return filewrite(f, p, n);
    80004b48:	fe442603          	lw	a2,-28(s0)
    80004b4c:	fd843583          	ld	a1,-40(s0)
    80004b50:	fe843503          	ld	a0,-24(s0)
    80004b54:	dceff0ef          	jal	80004122 <filewrite>
}
    80004b58:	70a2                	ld	ra,40(sp)
    80004b5a:	7402                	ld	s0,32(sp)
    80004b5c:	6145                	addi	sp,sp,48
    80004b5e:	8082                	ret

0000000080004b60 <sys_close>:
{
    80004b60:	1101                	addi	sp,sp,-32
    80004b62:	ec06                	sd	ra,24(sp)
    80004b64:	e822                	sd	s0,16(sp)
    80004b66:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80004b68:	fe040613          	addi	a2,s0,-32
    80004b6c:	fec40593          	addi	a1,s0,-20
    80004b70:	4501                	li	a0,0
    80004b72:	d43ff0ef          	jal	800048b4 <argfd>
    return -1;
    80004b76:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80004b78:	02054063          	bltz	a0,80004b98 <sys_close+0x38>
  myproc()->ofile[fd] = 0;
    80004b7c:	d65fc0ef          	jal	800018e0 <myproc>
    80004b80:	fec42783          	lw	a5,-20(s0)
    80004b84:	07e9                	addi	a5,a5,26
    80004b86:	078e                	slli	a5,a5,0x3
    80004b88:	953e                	add	a0,a0,a5
    80004b8a:	00053023          	sd	zero,0(a0)
  fileclose(f);
    80004b8e:	fe043503          	ld	a0,-32(s0)
    80004b92:	bb2ff0ef          	jal	80003f44 <fileclose>
  return 0;
    80004b96:	4781                	li	a5,0
}
    80004b98:	853e                	mv	a0,a5
    80004b9a:	60e2                	ld	ra,24(sp)
    80004b9c:	6442                	ld	s0,16(sp)
    80004b9e:	6105                	addi	sp,sp,32
    80004ba0:	8082                	ret

0000000080004ba2 <sys_fstat>:
{
    80004ba2:	1101                	addi	sp,sp,-32
    80004ba4:	ec06                	sd	ra,24(sp)
    80004ba6:	e822                	sd	s0,16(sp)
    80004ba8:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    80004baa:	fe040593          	addi	a1,s0,-32
    80004bae:	4505                	li	a0,1
    80004bb0:	c7ffd0ef          	jal	8000282e <argaddr>
  if(argfd(0, 0, &f) < 0)
    80004bb4:	fe840613          	addi	a2,s0,-24
    80004bb8:	4581                	li	a1,0
    80004bba:	4501                	li	a0,0
    80004bbc:	cf9ff0ef          	jal	800048b4 <argfd>
    80004bc0:	87aa                	mv	a5,a0
    return -1;
    80004bc2:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80004bc4:	0007c863          	bltz	a5,80004bd4 <sys_fstat+0x32>
  return filestat(f, st);
    80004bc8:	fe043583          	ld	a1,-32(s0)
    80004bcc:	fe843503          	ld	a0,-24(s0)
    80004bd0:	c36ff0ef          	jal	80004006 <filestat>
}
    80004bd4:	60e2                	ld	ra,24(sp)
    80004bd6:	6442                	ld	s0,16(sp)
    80004bd8:	6105                	addi	sp,sp,32
    80004bda:	8082                	ret

0000000080004bdc <sys_link>:
{
    80004bdc:	7169                	addi	sp,sp,-304
    80004bde:	f606                	sd	ra,296(sp)
    80004be0:	f222                	sd	s0,288(sp)
    80004be2:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004be4:	08000613          	li	a2,128
    80004be8:	ed040593          	addi	a1,s0,-304
    80004bec:	4501                	li	a0,0
    80004bee:	c5dfd0ef          	jal	8000284a <argstr>
    return -1;
    80004bf2:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004bf4:	0c054e63          	bltz	a0,80004cd0 <sys_link+0xf4>
    80004bf8:	08000613          	li	a2,128
    80004bfc:	f5040593          	addi	a1,s0,-176
    80004c00:	4505                	li	a0,1
    80004c02:	c49fd0ef          	jal	8000284a <argstr>
    return -1;
    80004c06:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    80004c08:	0c054463          	bltz	a0,80004cd0 <sys_link+0xf4>
    80004c0c:	ee26                	sd	s1,280(sp)
  begin_op();
    80004c0e:	f1dfe0ef          	jal	80003b2a <begin_op>
  if((ip = namei(old)) == 0){
    80004c12:	ed040513          	addi	a0,s0,-304
    80004c16:	d59fe0ef          	jal	8000396e <namei>
    80004c1a:	84aa                	mv	s1,a0
    80004c1c:	c53d                	beqz	a0,80004c8a <sys_link+0xae>
  ilock(ip);
    80004c1e:	e76fe0ef          	jal	80003294 <ilock>
  if(ip->type == T_DIR){
    80004c22:	04449703          	lh	a4,68(s1)
    80004c26:	4785                	li	a5,1
    80004c28:	06f70663          	beq	a4,a5,80004c94 <sys_link+0xb8>
    80004c2c:	ea4a                	sd	s2,272(sp)
  ip->nlink++;
    80004c2e:	04a4d783          	lhu	a5,74(s1)
    80004c32:	2785                	addiw	a5,a5,1
    80004c34:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004c38:	8526                	mv	a0,s1
    80004c3a:	da6fe0ef          	jal	800031e0 <iupdate>
  iunlock(ip);
    80004c3e:	8526                	mv	a0,s1
    80004c40:	f02fe0ef          	jal	80003342 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80004c44:	fd040593          	addi	a1,s0,-48
    80004c48:	f5040513          	addi	a0,s0,-176
    80004c4c:	d3dfe0ef          	jal	80003988 <nameiparent>
    80004c50:	892a                	mv	s2,a0
    80004c52:	cd21                	beqz	a0,80004caa <sys_link+0xce>
  ilock(dp);
    80004c54:	e40fe0ef          	jal	80003294 <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    80004c58:	00092703          	lw	a4,0(s2)
    80004c5c:	409c                	lw	a5,0(s1)
    80004c5e:	04f71363          	bne	a4,a5,80004ca4 <sys_link+0xc8>
    80004c62:	40d0                	lw	a2,4(s1)
    80004c64:	fd040593          	addi	a1,s0,-48
    80004c68:	854a                	mv	a0,s2
    80004c6a:	c6bfe0ef          	jal	800038d4 <dirlink>
    80004c6e:	02054b63          	bltz	a0,80004ca4 <sys_link+0xc8>
  iunlockput(dp);
    80004c72:	854a                	mv	a0,s2
    80004c74:	82bfe0ef          	jal	8000349e <iunlockput>
  iput(ip);
    80004c78:	8526                	mv	a0,s1
    80004c7a:	f9cfe0ef          	jal	80003416 <iput>
  end_op();
    80004c7e:	f17fe0ef          	jal	80003b94 <end_op>
  return 0;
    80004c82:	4781                	li	a5,0
    80004c84:	64f2                	ld	s1,280(sp)
    80004c86:	6952                	ld	s2,272(sp)
    80004c88:	a0a1                	j	80004cd0 <sys_link+0xf4>
    end_op();
    80004c8a:	f0bfe0ef          	jal	80003b94 <end_op>
    return -1;
    80004c8e:	57fd                	li	a5,-1
    80004c90:	64f2                	ld	s1,280(sp)
    80004c92:	a83d                	j	80004cd0 <sys_link+0xf4>
    iunlockput(ip);
    80004c94:	8526                	mv	a0,s1
    80004c96:	809fe0ef          	jal	8000349e <iunlockput>
    end_op();
    80004c9a:	efbfe0ef          	jal	80003b94 <end_op>
    return -1;
    80004c9e:	57fd                	li	a5,-1
    80004ca0:	64f2                	ld	s1,280(sp)
    80004ca2:	a03d                	j	80004cd0 <sys_link+0xf4>
    iunlockput(dp);
    80004ca4:	854a                	mv	a0,s2
    80004ca6:	ff8fe0ef          	jal	8000349e <iunlockput>
  ilock(ip);
    80004caa:	8526                	mv	a0,s1
    80004cac:	de8fe0ef          	jal	80003294 <ilock>
  ip->nlink--;
    80004cb0:	04a4d783          	lhu	a5,74(s1)
    80004cb4:	37fd                	addiw	a5,a5,-1
    80004cb6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    80004cba:	8526                	mv	a0,s1
    80004cbc:	d24fe0ef          	jal	800031e0 <iupdate>
  iunlockput(ip);
    80004cc0:	8526                	mv	a0,s1
    80004cc2:	fdcfe0ef          	jal	8000349e <iunlockput>
  end_op();
    80004cc6:	ecffe0ef          	jal	80003b94 <end_op>
  return -1;
    80004cca:	57fd                	li	a5,-1
    80004ccc:	64f2                	ld	s1,280(sp)
    80004cce:	6952                	ld	s2,272(sp)
}
    80004cd0:	853e                	mv	a0,a5
    80004cd2:	70b2                	ld	ra,296(sp)
    80004cd4:	7412                	ld	s0,288(sp)
    80004cd6:	6155                	addi	sp,sp,304
    80004cd8:	8082                	ret

0000000080004cda <sys_unlink>:
{
    80004cda:	7151                	addi	sp,sp,-240
    80004cdc:	f586                	sd	ra,232(sp)
    80004cde:	f1a2                	sd	s0,224(sp)
    80004ce0:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80004ce2:	08000613          	li	a2,128
    80004ce6:	f3040593          	addi	a1,s0,-208
    80004cea:	4501                	li	a0,0
    80004cec:	b5ffd0ef          	jal	8000284a <argstr>
    80004cf0:	16054063          	bltz	a0,80004e50 <sys_unlink+0x176>
    80004cf4:	eda6                	sd	s1,216(sp)
  begin_op();
    80004cf6:	e35fe0ef          	jal	80003b2a <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80004cfa:	fb040593          	addi	a1,s0,-80
    80004cfe:	f3040513          	addi	a0,s0,-208
    80004d02:	c87fe0ef          	jal	80003988 <nameiparent>
    80004d06:	84aa                	mv	s1,a0
    80004d08:	c945                	beqz	a0,80004db8 <sys_unlink+0xde>
  ilock(dp);
    80004d0a:	d8afe0ef          	jal	80003294 <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    80004d0e:	00003597          	auipc	a1,0x3
    80004d12:	91258593          	addi	a1,a1,-1774 # 80007620 <etext+0x620>
    80004d16:	fb040513          	addi	a0,s0,-80
    80004d1a:	9d9fe0ef          	jal	800036f2 <namecmp>
    80004d1e:	10050e63          	beqz	a0,80004e3a <sys_unlink+0x160>
    80004d22:	00003597          	auipc	a1,0x3
    80004d26:	90658593          	addi	a1,a1,-1786 # 80007628 <etext+0x628>
    80004d2a:	fb040513          	addi	a0,s0,-80
    80004d2e:	9c5fe0ef          	jal	800036f2 <namecmp>
    80004d32:	10050463          	beqz	a0,80004e3a <sys_unlink+0x160>
    80004d36:	e9ca                	sd	s2,208(sp)
  if((ip = dirlookup(dp, name, &off)) == 0)
    80004d38:	f2c40613          	addi	a2,s0,-212
    80004d3c:	fb040593          	addi	a1,s0,-80
    80004d40:	8526                	mv	a0,s1
    80004d42:	9c7fe0ef          	jal	80003708 <dirlookup>
    80004d46:	892a                	mv	s2,a0
    80004d48:	0e050863          	beqz	a0,80004e38 <sys_unlink+0x15e>
  ilock(ip);
    80004d4c:	d48fe0ef          	jal	80003294 <ilock>
  if(ip->nlink < 1)
    80004d50:	04a91783          	lh	a5,74(s2)
    80004d54:	06f05763          	blez	a5,80004dc2 <sys_unlink+0xe8>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80004d58:	04491703          	lh	a4,68(s2)
    80004d5c:	4785                	li	a5,1
    80004d5e:	06f70963          	beq	a4,a5,80004dd0 <sys_unlink+0xf6>
  memset(&de, 0, sizeof(de));
    80004d62:	4641                	li	a2,16
    80004d64:	4581                	li	a1,0
    80004d66:	fc040513          	addi	a0,s0,-64
    80004d6a:	f5ffb0ef          	jal	80000cc8 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004d6e:	4741                	li	a4,16
    80004d70:	f2c42683          	lw	a3,-212(s0)
    80004d74:	fc040613          	addi	a2,s0,-64
    80004d78:	4581                	li	a1,0
    80004d7a:	8526                	mv	a0,s1
    80004d7c:	869fe0ef          	jal	800035e4 <writei>
    80004d80:	47c1                	li	a5,16
    80004d82:	08f51b63          	bne	a0,a5,80004e18 <sys_unlink+0x13e>
  if(ip->type == T_DIR){
    80004d86:	04491703          	lh	a4,68(s2)
    80004d8a:	4785                	li	a5,1
    80004d8c:	08f70d63          	beq	a4,a5,80004e26 <sys_unlink+0x14c>
  iunlockput(dp);
    80004d90:	8526                	mv	a0,s1
    80004d92:	f0cfe0ef          	jal	8000349e <iunlockput>
  ip->nlink--;
    80004d96:	04a95783          	lhu	a5,74(s2)
    80004d9a:	37fd                	addiw	a5,a5,-1
    80004d9c:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    80004da0:	854a                	mv	a0,s2
    80004da2:	c3efe0ef          	jal	800031e0 <iupdate>
  iunlockput(ip);
    80004da6:	854a                	mv	a0,s2
    80004da8:	ef6fe0ef          	jal	8000349e <iunlockput>
  end_op();
    80004dac:	de9fe0ef          	jal	80003b94 <end_op>
  return 0;
    80004db0:	4501                	li	a0,0
    80004db2:	64ee                	ld	s1,216(sp)
    80004db4:	694e                	ld	s2,208(sp)
    80004db6:	a849                	j	80004e48 <sys_unlink+0x16e>
    end_op();
    80004db8:	dddfe0ef          	jal	80003b94 <end_op>
    return -1;
    80004dbc:	557d                	li	a0,-1
    80004dbe:	64ee                	ld	s1,216(sp)
    80004dc0:	a061                	j	80004e48 <sys_unlink+0x16e>
    80004dc2:	e5ce                	sd	s3,200(sp)
    panic("unlink: nlink < 1");
    80004dc4:	00003517          	auipc	a0,0x3
    80004dc8:	86c50513          	addi	a0,a0,-1940 # 80007630 <etext+0x630>
    80004dcc:	9c9fb0ef          	jal	80000794 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004dd0:	04c92703          	lw	a4,76(s2)
    80004dd4:	02000793          	li	a5,32
    80004dd8:	f8e7f5e3          	bgeu	a5,a4,80004d62 <sys_unlink+0x88>
    80004ddc:	e5ce                	sd	s3,200(sp)
    80004dde:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004de2:	4741                	li	a4,16
    80004de4:	86ce                	mv	a3,s3
    80004de6:	f1840613          	addi	a2,s0,-232
    80004dea:	4581                	li	a1,0
    80004dec:	854a                	mv	a0,s2
    80004dee:	efafe0ef          	jal	800034e8 <readi>
    80004df2:	47c1                	li	a5,16
    80004df4:	00f51c63          	bne	a0,a5,80004e0c <sys_unlink+0x132>
    if(de.inum != 0)
    80004df8:	f1845783          	lhu	a5,-232(s0)
    80004dfc:	efa1                	bnez	a5,80004e54 <sys_unlink+0x17a>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80004dfe:	29c1                	addiw	s3,s3,16
    80004e00:	04c92783          	lw	a5,76(s2)
    80004e04:	fcf9efe3          	bltu	s3,a5,80004de2 <sys_unlink+0x108>
    80004e08:	69ae                	ld	s3,200(sp)
    80004e0a:	bfa1                	j	80004d62 <sys_unlink+0x88>
      panic("isdirempty: readi");
    80004e0c:	00003517          	auipc	a0,0x3
    80004e10:	83c50513          	addi	a0,a0,-1988 # 80007648 <etext+0x648>
    80004e14:	981fb0ef          	jal	80000794 <panic>
    80004e18:	e5ce                	sd	s3,200(sp)
    panic("unlink: writei");
    80004e1a:	00003517          	auipc	a0,0x3
    80004e1e:	84650513          	addi	a0,a0,-1978 # 80007660 <etext+0x660>
    80004e22:	973fb0ef          	jal	80000794 <panic>
    dp->nlink--;
    80004e26:	04a4d783          	lhu	a5,74(s1)
    80004e2a:	37fd                	addiw	a5,a5,-1
    80004e2c:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    80004e30:	8526                	mv	a0,s1
    80004e32:	baefe0ef          	jal	800031e0 <iupdate>
    80004e36:	bfa9                	j	80004d90 <sys_unlink+0xb6>
    80004e38:	694e                	ld	s2,208(sp)
  iunlockput(dp);
    80004e3a:	8526                	mv	a0,s1
    80004e3c:	e62fe0ef          	jal	8000349e <iunlockput>
  end_op();
    80004e40:	d55fe0ef          	jal	80003b94 <end_op>
  return -1;
    80004e44:	557d                	li	a0,-1
    80004e46:	64ee                	ld	s1,216(sp)
}
    80004e48:	70ae                	ld	ra,232(sp)
    80004e4a:	740e                	ld	s0,224(sp)
    80004e4c:	616d                	addi	sp,sp,240
    80004e4e:	8082                	ret
    return -1;
    80004e50:	557d                	li	a0,-1
    80004e52:	bfdd                	j	80004e48 <sys_unlink+0x16e>
    iunlockput(ip);
    80004e54:	854a                	mv	a0,s2
    80004e56:	e48fe0ef          	jal	8000349e <iunlockput>
    goto bad;
    80004e5a:	694e                	ld	s2,208(sp)
    80004e5c:	69ae                	ld	s3,200(sp)
    80004e5e:	bff1                	j	80004e3a <sys_unlink+0x160>

0000000080004e60 <sys_open>:

uint64
sys_open(void)
{
    80004e60:	7131                	addi	sp,sp,-192
    80004e62:	fd06                	sd	ra,184(sp)
    80004e64:	f922                	sd	s0,176(sp)
    80004e66:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    80004e68:	f4c40593          	addi	a1,s0,-180
    80004e6c:	4505                	li	a0,1
    80004e6e:	9a5fd0ef          	jal	80002812 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004e72:	08000613          	li	a2,128
    80004e76:	f5040593          	addi	a1,s0,-176
    80004e7a:	4501                	li	a0,0
    80004e7c:	9cffd0ef          	jal	8000284a <argstr>
    80004e80:	87aa                	mv	a5,a0
    return -1;
    80004e82:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    80004e84:	0a07c263          	bltz	a5,80004f28 <sys_open+0xc8>
    80004e88:	f526                	sd	s1,168(sp)

  begin_op();
    80004e8a:	ca1fe0ef          	jal	80003b2a <begin_op>

  if(omode & O_CREATE){
    80004e8e:	f4c42783          	lw	a5,-180(s0)
    80004e92:	2007f793          	andi	a5,a5,512
    80004e96:	c3d5                	beqz	a5,80004f3a <sys_open+0xda>
    ip = create(path, T_FILE, 0, 0);
    80004e98:	4681                	li	a3,0
    80004e9a:	4601                	li	a2,0
    80004e9c:	4589                	li	a1,2
    80004e9e:	f5040513          	addi	a0,s0,-176
    80004ea2:	aa9ff0ef          	jal	8000494a <create>
    80004ea6:	84aa                	mv	s1,a0
    if(ip == 0){
    80004ea8:	c541                	beqz	a0,80004f30 <sys_open+0xd0>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80004eaa:	04449703          	lh	a4,68(s1)
    80004eae:	478d                	li	a5,3
    80004eb0:	00f71763          	bne	a4,a5,80004ebe <sys_open+0x5e>
    80004eb4:	0464d703          	lhu	a4,70(s1)
    80004eb8:	47a5                	li	a5,9
    80004eba:	0ae7ed63          	bltu	a5,a4,80004f74 <sys_open+0x114>
    80004ebe:	f14a                	sd	s2,160(sp)
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    80004ec0:	fe1fe0ef          	jal	80003ea0 <filealloc>
    80004ec4:	892a                	mv	s2,a0
    80004ec6:	c179                	beqz	a0,80004f8c <sys_open+0x12c>
    80004ec8:	ed4e                	sd	s3,152(sp)
    80004eca:	a43ff0ef          	jal	8000490c <fdalloc>
    80004ece:	89aa                	mv	s3,a0
    80004ed0:	0a054a63          	bltz	a0,80004f84 <sys_open+0x124>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80004ed4:	04449703          	lh	a4,68(s1)
    80004ed8:	478d                	li	a5,3
    80004eda:	0cf70263          	beq	a4,a5,80004f9e <sys_open+0x13e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80004ede:	4789                	li	a5,2
    80004ee0:	00f92023          	sw	a5,0(s2)
    f->off = 0;
    80004ee4:	02092023          	sw	zero,32(s2)
  }
  f->ip = ip;
    80004ee8:	00993c23          	sd	s1,24(s2)
  f->readable = !(omode & O_WRONLY);
    80004eec:	f4c42783          	lw	a5,-180(s0)
    80004ef0:	0017c713          	xori	a4,a5,1
    80004ef4:	8b05                	andi	a4,a4,1
    80004ef6:	00e90423          	sb	a4,8(s2)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    80004efa:	0037f713          	andi	a4,a5,3
    80004efe:	00e03733          	snez	a4,a4
    80004f02:	00e904a3          	sb	a4,9(s2)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80004f06:	4007f793          	andi	a5,a5,1024
    80004f0a:	c791                	beqz	a5,80004f16 <sys_open+0xb6>
    80004f0c:	04449703          	lh	a4,68(s1)
    80004f10:	4789                	li	a5,2
    80004f12:	08f70d63          	beq	a4,a5,80004fac <sys_open+0x14c>
    itrunc(ip);
  }

  iunlock(ip);
    80004f16:	8526                	mv	a0,s1
    80004f18:	c2afe0ef          	jal	80003342 <iunlock>
  end_op();
    80004f1c:	c79fe0ef          	jal	80003b94 <end_op>

  return fd;
    80004f20:	854e                	mv	a0,s3
    80004f22:	74aa                	ld	s1,168(sp)
    80004f24:	790a                	ld	s2,160(sp)
    80004f26:	69ea                	ld	s3,152(sp)
}
    80004f28:	70ea                	ld	ra,184(sp)
    80004f2a:	744a                	ld	s0,176(sp)
    80004f2c:	6129                	addi	sp,sp,192
    80004f2e:	8082                	ret
      end_op();
    80004f30:	c65fe0ef          	jal	80003b94 <end_op>
      return -1;
    80004f34:	557d                	li	a0,-1
    80004f36:	74aa                	ld	s1,168(sp)
    80004f38:	bfc5                	j	80004f28 <sys_open+0xc8>
    if((ip = namei(path)) == 0){
    80004f3a:	f5040513          	addi	a0,s0,-176
    80004f3e:	a31fe0ef          	jal	8000396e <namei>
    80004f42:	84aa                	mv	s1,a0
    80004f44:	c11d                	beqz	a0,80004f6a <sys_open+0x10a>
    ilock(ip);
    80004f46:	b4efe0ef          	jal	80003294 <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    80004f4a:	04449703          	lh	a4,68(s1)
    80004f4e:	4785                	li	a5,1
    80004f50:	f4f71de3          	bne	a4,a5,80004eaa <sys_open+0x4a>
    80004f54:	f4c42783          	lw	a5,-180(s0)
    80004f58:	d3bd                	beqz	a5,80004ebe <sys_open+0x5e>
      iunlockput(ip);
    80004f5a:	8526                	mv	a0,s1
    80004f5c:	d42fe0ef          	jal	8000349e <iunlockput>
      end_op();
    80004f60:	c35fe0ef          	jal	80003b94 <end_op>
      return -1;
    80004f64:	557d                	li	a0,-1
    80004f66:	74aa                	ld	s1,168(sp)
    80004f68:	b7c1                	j	80004f28 <sys_open+0xc8>
      end_op();
    80004f6a:	c2bfe0ef          	jal	80003b94 <end_op>
      return -1;
    80004f6e:	557d                	li	a0,-1
    80004f70:	74aa                	ld	s1,168(sp)
    80004f72:	bf5d                	j	80004f28 <sys_open+0xc8>
    iunlockput(ip);
    80004f74:	8526                	mv	a0,s1
    80004f76:	d28fe0ef          	jal	8000349e <iunlockput>
    end_op();
    80004f7a:	c1bfe0ef          	jal	80003b94 <end_op>
    return -1;
    80004f7e:	557d                	li	a0,-1
    80004f80:	74aa                	ld	s1,168(sp)
    80004f82:	b75d                	j	80004f28 <sys_open+0xc8>
      fileclose(f);
    80004f84:	854a                	mv	a0,s2
    80004f86:	fbffe0ef          	jal	80003f44 <fileclose>
    80004f8a:	69ea                	ld	s3,152(sp)
    iunlockput(ip);
    80004f8c:	8526                	mv	a0,s1
    80004f8e:	d10fe0ef          	jal	8000349e <iunlockput>
    end_op();
    80004f92:	c03fe0ef          	jal	80003b94 <end_op>
    return -1;
    80004f96:	557d                	li	a0,-1
    80004f98:	74aa                	ld	s1,168(sp)
    80004f9a:	790a                	ld	s2,160(sp)
    80004f9c:	b771                	j	80004f28 <sys_open+0xc8>
    f->type = FD_DEVICE;
    80004f9e:	00f92023          	sw	a5,0(s2)
    f->major = ip->major;
    80004fa2:	04649783          	lh	a5,70(s1)
    80004fa6:	02f91223          	sh	a5,36(s2)
    80004faa:	bf3d                	j	80004ee8 <sys_open+0x88>
    itrunc(ip);
    80004fac:	8526                	mv	a0,s1
    80004fae:	bd4fe0ef          	jal	80003382 <itrunc>
    80004fb2:	b795                	j	80004f16 <sys_open+0xb6>

0000000080004fb4 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80004fb4:	7175                	addi	sp,sp,-144
    80004fb6:	e506                	sd	ra,136(sp)
    80004fb8:	e122                	sd	s0,128(sp)
    80004fba:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80004fbc:	b6ffe0ef          	jal	80003b2a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80004fc0:	08000613          	li	a2,128
    80004fc4:	f7040593          	addi	a1,s0,-144
    80004fc8:	4501                	li	a0,0
    80004fca:	881fd0ef          	jal	8000284a <argstr>
    80004fce:	02054363          	bltz	a0,80004ff4 <sys_mkdir+0x40>
    80004fd2:	4681                	li	a3,0
    80004fd4:	4601                	li	a2,0
    80004fd6:	4585                	li	a1,1
    80004fd8:	f7040513          	addi	a0,s0,-144
    80004fdc:	96fff0ef          	jal	8000494a <create>
    80004fe0:	c911                	beqz	a0,80004ff4 <sys_mkdir+0x40>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80004fe2:	cbcfe0ef          	jal	8000349e <iunlockput>
  end_op();
    80004fe6:	baffe0ef          	jal	80003b94 <end_op>
  return 0;
    80004fea:	4501                	li	a0,0
}
    80004fec:	60aa                	ld	ra,136(sp)
    80004fee:	640a                	ld	s0,128(sp)
    80004ff0:	6149                	addi	sp,sp,144
    80004ff2:	8082                	ret
    end_op();
    80004ff4:	ba1fe0ef          	jal	80003b94 <end_op>
    return -1;
    80004ff8:	557d                	li	a0,-1
    80004ffa:	bfcd                	j	80004fec <sys_mkdir+0x38>

0000000080004ffc <sys_mknod>:

uint64
sys_mknod(void)
{
    80004ffc:	7135                	addi	sp,sp,-160
    80004ffe:	ed06                	sd	ra,152(sp)
    80005000:	e922                	sd	s0,144(sp)
    80005002:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005004:	b27fe0ef          	jal	80003b2a <begin_op>
  argint(1, &major);
    80005008:	f6c40593          	addi	a1,s0,-148
    8000500c:	4505                	li	a0,1
    8000500e:	805fd0ef          	jal	80002812 <argint>
  argint(2, &minor);
    80005012:	f6840593          	addi	a1,s0,-152
    80005016:	4509                	li	a0,2
    80005018:	ffafd0ef          	jal	80002812 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    8000501c:	08000613          	li	a2,128
    80005020:	f7040593          	addi	a1,s0,-144
    80005024:	4501                	li	a0,0
    80005026:	825fd0ef          	jal	8000284a <argstr>
    8000502a:	02054563          	bltz	a0,80005054 <sys_mknod+0x58>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    8000502e:	f6841683          	lh	a3,-152(s0)
    80005032:	f6c41603          	lh	a2,-148(s0)
    80005036:	458d                	li	a1,3
    80005038:	f7040513          	addi	a0,s0,-144
    8000503c:	90fff0ef          	jal	8000494a <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005040:	c911                	beqz	a0,80005054 <sys_mknod+0x58>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005042:	c5cfe0ef          	jal	8000349e <iunlockput>
  end_op();
    80005046:	b4ffe0ef          	jal	80003b94 <end_op>
  return 0;
    8000504a:	4501                	li	a0,0
}
    8000504c:	60ea                	ld	ra,152(sp)
    8000504e:	644a                	ld	s0,144(sp)
    80005050:	610d                	addi	sp,sp,160
    80005052:	8082                	ret
    end_op();
    80005054:	b41fe0ef          	jal	80003b94 <end_op>
    return -1;
    80005058:	557d                	li	a0,-1
    8000505a:	bfcd                	j	8000504c <sys_mknod+0x50>

000000008000505c <sys_chdir>:

uint64
sys_chdir(void)
{
    8000505c:	7135                	addi	sp,sp,-160
    8000505e:	ed06                	sd	ra,152(sp)
    80005060:	e922                	sd	s0,144(sp)
    80005062:	e14a                	sd	s2,128(sp)
    80005064:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005066:	87bfc0ef          	jal	800018e0 <myproc>
    8000506a:	892a                	mv	s2,a0
  
  begin_op();
    8000506c:	abffe0ef          	jal	80003b2a <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005070:	08000613          	li	a2,128
    80005074:	f6040593          	addi	a1,s0,-160
    80005078:	4501                	li	a0,0
    8000507a:	fd0fd0ef          	jal	8000284a <argstr>
    8000507e:	04054363          	bltz	a0,800050c4 <sys_chdir+0x68>
    80005082:	e526                	sd	s1,136(sp)
    80005084:	f6040513          	addi	a0,s0,-160
    80005088:	8e7fe0ef          	jal	8000396e <namei>
    8000508c:	84aa                	mv	s1,a0
    8000508e:	c915                	beqz	a0,800050c2 <sys_chdir+0x66>
    end_op();
    return -1;
  }
  ilock(ip);
    80005090:	a04fe0ef          	jal	80003294 <ilock>
  if(ip->type != T_DIR){
    80005094:	04449703          	lh	a4,68(s1)
    80005098:	4785                	li	a5,1
    8000509a:	02f71963          	bne	a4,a5,800050cc <sys_chdir+0x70>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    8000509e:	8526                	mv	a0,s1
    800050a0:	aa2fe0ef          	jal	80003342 <iunlock>
  iput(p->cwd);
    800050a4:	15093503          	ld	a0,336(s2)
    800050a8:	b6efe0ef          	jal	80003416 <iput>
  end_op();
    800050ac:	ae9fe0ef          	jal	80003b94 <end_op>
  p->cwd = ip;
    800050b0:	14993823          	sd	s1,336(s2)
  return 0;
    800050b4:	4501                	li	a0,0
    800050b6:	64aa                	ld	s1,136(sp)
}
    800050b8:	60ea                	ld	ra,152(sp)
    800050ba:	644a                	ld	s0,144(sp)
    800050bc:	690a                	ld	s2,128(sp)
    800050be:	610d                	addi	sp,sp,160
    800050c0:	8082                	ret
    800050c2:	64aa                	ld	s1,136(sp)
    end_op();
    800050c4:	ad1fe0ef          	jal	80003b94 <end_op>
    return -1;
    800050c8:	557d                	li	a0,-1
    800050ca:	b7fd                	j	800050b8 <sys_chdir+0x5c>
    iunlockput(ip);
    800050cc:	8526                	mv	a0,s1
    800050ce:	bd0fe0ef          	jal	8000349e <iunlockput>
    end_op();
    800050d2:	ac3fe0ef          	jal	80003b94 <end_op>
    return -1;
    800050d6:	557d                	li	a0,-1
    800050d8:	64aa                	ld	s1,136(sp)
    800050da:	bff9                	j	800050b8 <sys_chdir+0x5c>

00000000800050dc <sys_exec>:

uint64
sys_exec(void)
{
    800050dc:	7121                	addi	sp,sp,-448
    800050de:	ff06                	sd	ra,440(sp)
    800050e0:	fb22                	sd	s0,432(sp)
    800050e2:	0380                	addi	s0,sp,448
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    800050e4:	e4840593          	addi	a1,s0,-440
    800050e8:	4505                	li	a0,1
    800050ea:	f44fd0ef          	jal	8000282e <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    800050ee:	08000613          	li	a2,128
    800050f2:	f5040593          	addi	a1,s0,-176
    800050f6:	4501                	li	a0,0
    800050f8:	f52fd0ef          	jal	8000284a <argstr>
    800050fc:	87aa                	mv	a5,a0
    return -1;
    800050fe:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005100:	0c07c463          	bltz	a5,800051c8 <sys_exec+0xec>
    80005104:	f726                	sd	s1,424(sp)
    80005106:	f34a                	sd	s2,416(sp)
    80005108:	ef4e                	sd	s3,408(sp)
    8000510a:	eb52                	sd	s4,400(sp)
  }
  memset(argv, 0, sizeof(argv));
    8000510c:	10000613          	li	a2,256
    80005110:	4581                	li	a1,0
    80005112:	e5040513          	addi	a0,s0,-432
    80005116:	bb3fb0ef          	jal	80000cc8 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    8000511a:	e5040493          	addi	s1,s0,-432
  memset(argv, 0, sizeof(argv));
    8000511e:	89a6                	mv	s3,s1
    80005120:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005122:	02000a13          	li	s4,32
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005126:	00391513          	slli	a0,s2,0x3
    8000512a:	e4040593          	addi	a1,s0,-448
    8000512e:	e4843783          	ld	a5,-440(s0)
    80005132:	953e                	add	a0,a0,a5
    80005134:	e54fd0ef          	jal	80002788 <fetchaddr>
    80005138:	02054663          	bltz	a0,80005164 <sys_exec+0x88>
      goto bad;
    }
    if(uarg == 0){
    8000513c:	e4043783          	ld	a5,-448(s0)
    80005140:	c3a9                	beqz	a5,80005182 <sys_exec+0xa6>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005142:	9e3fb0ef          	jal	80000b24 <kalloc>
    80005146:	85aa                	mv	a1,a0
    80005148:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    8000514c:	cd01                	beqz	a0,80005164 <sys_exec+0x88>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    8000514e:	6605                	lui	a2,0x1
    80005150:	e4043503          	ld	a0,-448(s0)
    80005154:	e7efd0ef          	jal	800027d2 <fetchstr>
    80005158:	00054663          	bltz	a0,80005164 <sys_exec+0x88>
    if(i >= NELEM(argv)){
    8000515c:	0905                	addi	s2,s2,1
    8000515e:	09a1                	addi	s3,s3,8
    80005160:	fd4913e3          	bne	s2,s4,80005126 <sys_exec+0x4a>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005164:	f5040913          	addi	s2,s0,-176
    80005168:	6088                	ld	a0,0(s1)
    8000516a:	c931                	beqz	a0,800051be <sys_exec+0xe2>
    kfree(argv[i]);
    8000516c:	8d7fb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005170:	04a1                	addi	s1,s1,8
    80005172:	ff249be3          	bne	s1,s2,80005168 <sys_exec+0x8c>
  return -1;
    80005176:	557d                	li	a0,-1
    80005178:	74ba                	ld	s1,424(sp)
    8000517a:	791a                	ld	s2,416(sp)
    8000517c:	69fa                	ld	s3,408(sp)
    8000517e:	6a5a                	ld	s4,400(sp)
    80005180:	a0a1                	j	800051c8 <sys_exec+0xec>
      argv[i] = 0;
    80005182:	0009079b          	sext.w	a5,s2
    80005186:	078e                	slli	a5,a5,0x3
    80005188:	fd078793          	addi	a5,a5,-48
    8000518c:	97a2                	add	a5,a5,s0
    8000518e:	e807b023          	sd	zero,-384(a5)
  int ret = exec(path, argv);
    80005192:	e5040593          	addi	a1,s0,-432
    80005196:	f5040513          	addi	a0,s0,-176
    8000519a:	ba8ff0ef          	jal	80004542 <exec>
    8000519e:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800051a0:	f5040993          	addi	s3,s0,-176
    800051a4:	6088                	ld	a0,0(s1)
    800051a6:	c511                	beqz	a0,800051b2 <sys_exec+0xd6>
    kfree(argv[i]);
    800051a8:	89bfb0ef          	jal	80000a42 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    800051ac:	04a1                	addi	s1,s1,8
    800051ae:	ff349be3          	bne	s1,s3,800051a4 <sys_exec+0xc8>
  return ret;
    800051b2:	854a                	mv	a0,s2
    800051b4:	74ba                	ld	s1,424(sp)
    800051b6:	791a                	ld	s2,416(sp)
    800051b8:	69fa                	ld	s3,408(sp)
    800051ba:	6a5a                	ld	s4,400(sp)
    800051bc:	a031                	j	800051c8 <sys_exec+0xec>
  return -1;
    800051be:	557d                	li	a0,-1
    800051c0:	74ba                	ld	s1,424(sp)
    800051c2:	791a                	ld	s2,416(sp)
    800051c4:	69fa                	ld	s3,408(sp)
    800051c6:	6a5a                	ld	s4,400(sp)
}
    800051c8:	70fa                	ld	ra,440(sp)
    800051ca:	745a                	ld	s0,432(sp)
    800051cc:	6139                	addi	sp,sp,448
    800051ce:	8082                	ret

00000000800051d0 <sys_pipe>:

uint64
sys_pipe(void)
{
    800051d0:	7139                	addi	sp,sp,-64
    800051d2:	fc06                	sd	ra,56(sp)
    800051d4:	f822                	sd	s0,48(sp)
    800051d6:	f426                	sd	s1,40(sp)
    800051d8:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    800051da:	f06fc0ef          	jal	800018e0 <myproc>
    800051de:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    800051e0:	fd840593          	addi	a1,s0,-40
    800051e4:	4501                	li	a0,0
    800051e6:	e48fd0ef          	jal	8000282e <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    800051ea:	fc840593          	addi	a1,s0,-56
    800051ee:	fd040513          	addi	a0,s0,-48
    800051f2:	85cff0ef          	jal	8000424e <pipealloc>
    return -1;
    800051f6:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    800051f8:	0a054463          	bltz	a0,800052a0 <sys_pipe+0xd0>
  fd0 = -1;
    800051fc:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005200:	fd043503          	ld	a0,-48(s0)
    80005204:	f08ff0ef          	jal	8000490c <fdalloc>
    80005208:	fca42223          	sw	a0,-60(s0)
    8000520c:	08054163          	bltz	a0,8000528e <sys_pipe+0xbe>
    80005210:	fc843503          	ld	a0,-56(s0)
    80005214:	ef8ff0ef          	jal	8000490c <fdalloc>
    80005218:	fca42023          	sw	a0,-64(s0)
    8000521c:	06054063          	bltz	a0,8000527c <sys_pipe+0xac>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005220:	4691                	li	a3,4
    80005222:	fc440613          	addi	a2,s0,-60
    80005226:	fd843583          	ld	a1,-40(s0)
    8000522a:	68a8                	ld	a0,80(s1)
    8000522c:	b26fc0ef          	jal	80001552 <copyout>
    80005230:	00054e63          	bltz	a0,8000524c <sys_pipe+0x7c>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005234:	4691                	li	a3,4
    80005236:	fc040613          	addi	a2,s0,-64
    8000523a:	fd843583          	ld	a1,-40(s0)
    8000523e:	0591                	addi	a1,a1,4
    80005240:	68a8                	ld	a0,80(s1)
    80005242:	b10fc0ef          	jal	80001552 <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005246:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005248:	04055c63          	bgez	a0,800052a0 <sys_pipe+0xd0>
    p->ofile[fd0] = 0;
    8000524c:	fc442783          	lw	a5,-60(s0)
    80005250:	07e9                	addi	a5,a5,26
    80005252:	078e                	slli	a5,a5,0x3
    80005254:	97a6                	add	a5,a5,s1
    80005256:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    8000525a:	fc042783          	lw	a5,-64(s0)
    8000525e:	07e9                	addi	a5,a5,26
    80005260:	078e                	slli	a5,a5,0x3
    80005262:	94be                	add	s1,s1,a5
    80005264:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005268:	fd043503          	ld	a0,-48(s0)
    8000526c:	cd9fe0ef          	jal	80003f44 <fileclose>
    fileclose(wf);
    80005270:	fc843503          	ld	a0,-56(s0)
    80005274:	cd1fe0ef          	jal	80003f44 <fileclose>
    return -1;
    80005278:	57fd                	li	a5,-1
    8000527a:	a01d                	j	800052a0 <sys_pipe+0xd0>
    if(fd0 >= 0)
    8000527c:	fc442783          	lw	a5,-60(s0)
    80005280:	0007c763          	bltz	a5,8000528e <sys_pipe+0xbe>
      p->ofile[fd0] = 0;
    80005284:	07e9                	addi	a5,a5,26
    80005286:	078e                	slli	a5,a5,0x3
    80005288:	97a6                	add	a5,a5,s1
    8000528a:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    8000528e:	fd043503          	ld	a0,-48(s0)
    80005292:	cb3fe0ef          	jal	80003f44 <fileclose>
    fileclose(wf);
    80005296:	fc843503          	ld	a0,-56(s0)
    8000529a:	cabfe0ef          	jal	80003f44 <fileclose>
    return -1;
    8000529e:	57fd                	li	a5,-1
}
    800052a0:	853e                	mv	a0,a5
    800052a2:	70e2                	ld	ra,56(sp)
    800052a4:	7442                	ld	s0,48(sp)
    800052a6:	74a2                	ld	s1,40(sp)
    800052a8:	6121                	addi	sp,sp,64
    800052aa:	8082                	ret
    800052ac:	0000                	unimp
	...

00000000800052b0 <kernelvec>:
    800052b0:	7111                	addi	sp,sp,-256
    800052b2:	e006                	sd	ra,0(sp)
    800052b4:	e40a                	sd	sp,8(sp)
    800052b6:	e80e                	sd	gp,16(sp)
    800052b8:	ec12                	sd	tp,24(sp)
    800052ba:	f016                	sd	t0,32(sp)
    800052bc:	f41a                	sd	t1,40(sp)
    800052be:	f81e                	sd	t2,48(sp)
    800052c0:	e4aa                	sd	a0,72(sp)
    800052c2:	e8ae                	sd	a1,80(sp)
    800052c4:	ecb2                	sd	a2,88(sp)
    800052c6:	f0b6                	sd	a3,96(sp)
    800052c8:	f4ba                	sd	a4,104(sp)
    800052ca:	f8be                	sd	a5,112(sp)
    800052cc:	fcc2                	sd	a6,120(sp)
    800052ce:	e146                	sd	a7,128(sp)
    800052d0:	edf2                	sd	t3,216(sp)
    800052d2:	f1f6                	sd	t4,224(sp)
    800052d4:	f5fa                	sd	t5,232(sp)
    800052d6:	f9fe                	sd	t6,240(sp)
    800052d8:	bc0fd0ef          	jal	80002698 <kerneltrap>
    800052dc:	6082                	ld	ra,0(sp)
    800052de:	6122                	ld	sp,8(sp)
    800052e0:	61c2                	ld	gp,16(sp)
    800052e2:	7282                	ld	t0,32(sp)
    800052e4:	7322                	ld	t1,40(sp)
    800052e6:	73c2                	ld	t2,48(sp)
    800052e8:	6526                	ld	a0,72(sp)
    800052ea:	65c6                	ld	a1,80(sp)
    800052ec:	6666                	ld	a2,88(sp)
    800052ee:	7686                	ld	a3,96(sp)
    800052f0:	7726                	ld	a4,104(sp)
    800052f2:	77c6                	ld	a5,112(sp)
    800052f4:	7866                	ld	a6,120(sp)
    800052f6:	688a                	ld	a7,128(sp)
    800052f8:	6e6e                	ld	t3,216(sp)
    800052fa:	7e8e                	ld	t4,224(sp)
    800052fc:	7f2e                	ld	t5,232(sp)
    800052fe:	7fce                	ld	t6,240(sp)
    80005300:	6111                	addi	sp,sp,256
    80005302:	10200073          	sret
	...

000000008000530e <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    8000530e:	1141                	addi	sp,sp,-16
    80005310:	e422                	sd	s0,8(sp)
    80005312:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005314:	0c0007b7          	lui	a5,0xc000
    80005318:	4705                	li	a4,1
    8000531a:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    8000531c:	0c0007b7          	lui	a5,0xc000
    80005320:	c3d8                	sw	a4,4(a5)
}
    80005322:	6422                	ld	s0,8(sp)
    80005324:	0141                	addi	sp,sp,16
    80005326:	8082                	ret

0000000080005328 <plicinithart>:

void
plicinithart(void)
{
    80005328:	1141                	addi	sp,sp,-16
    8000532a:	e406                	sd	ra,8(sp)
    8000532c:	e022                	sd	s0,0(sp)
    8000532e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005330:	d84fc0ef          	jal	800018b4 <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005334:	0085171b          	slliw	a4,a0,0x8
    80005338:	0c0027b7          	lui	a5,0xc002
    8000533c:	97ba                	add	a5,a5,a4
    8000533e:	40200713          	li	a4,1026
    80005342:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005346:	00d5151b          	slliw	a0,a0,0xd
    8000534a:	0c2017b7          	lui	a5,0xc201
    8000534e:	97aa                	add	a5,a5,a0
    80005350:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005354:	60a2                	ld	ra,8(sp)
    80005356:	6402                	ld	s0,0(sp)
    80005358:	0141                	addi	sp,sp,16
    8000535a:	8082                	ret

000000008000535c <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    8000535c:	1141                	addi	sp,sp,-16
    8000535e:	e406                	sd	ra,8(sp)
    80005360:	e022                	sd	s0,0(sp)
    80005362:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005364:	d50fc0ef          	jal	800018b4 <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005368:	00d5151b          	slliw	a0,a0,0xd
    8000536c:	0c2017b7          	lui	a5,0xc201
    80005370:	97aa                	add	a5,a5,a0
  return irq;
}
    80005372:	43c8                	lw	a0,4(a5)
    80005374:	60a2                	ld	ra,8(sp)
    80005376:	6402                	ld	s0,0(sp)
    80005378:	0141                	addi	sp,sp,16
    8000537a:	8082                	ret

000000008000537c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    8000537c:	1101                	addi	sp,sp,-32
    8000537e:	ec06                	sd	ra,24(sp)
    80005380:	e822                	sd	s0,16(sp)
    80005382:	e426                	sd	s1,8(sp)
    80005384:	1000                	addi	s0,sp,32
    80005386:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005388:	d2cfc0ef          	jal	800018b4 <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    8000538c:	00d5151b          	slliw	a0,a0,0xd
    80005390:	0c2017b7          	lui	a5,0xc201
    80005394:	97aa                	add	a5,a5,a0
    80005396:	c3c4                	sw	s1,4(a5)
}
    80005398:	60e2                	ld	ra,24(sp)
    8000539a:	6442                	ld	s0,16(sp)
    8000539c:	64a2                	ld	s1,8(sp)
    8000539e:	6105                	addi	sp,sp,32
    800053a0:	8082                	ret

00000000800053a2 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    800053a2:	1141                	addi	sp,sp,-16
    800053a4:	e406                	sd	ra,8(sp)
    800053a6:	e022                	sd	s0,0(sp)
    800053a8:	0800                	addi	s0,sp,16
  if(i >= NUM)
    800053aa:	479d                	li	a5,7
    800053ac:	04a7ca63          	blt	a5,a0,80005400 <free_desc+0x5e>
    panic("free_desc 1");
  if(disk.free[i])
    800053b0:	0001e797          	auipc	a5,0x1e
    800053b4:	6c078793          	addi	a5,a5,1728 # 80023a70 <disk>
    800053b8:	97aa                	add	a5,a5,a0
    800053ba:	0187c783          	lbu	a5,24(a5)
    800053be:	e7b9                	bnez	a5,8000540c <free_desc+0x6a>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    800053c0:	00451693          	slli	a3,a0,0x4
    800053c4:	0001e797          	auipc	a5,0x1e
    800053c8:	6ac78793          	addi	a5,a5,1708 # 80023a70 <disk>
    800053cc:	6398                	ld	a4,0(a5)
    800053ce:	9736                	add	a4,a4,a3
    800053d0:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    800053d4:	6398                	ld	a4,0(a5)
    800053d6:	9736                	add	a4,a4,a3
    800053d8:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    800053dc:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    800053e0:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    800053e4:	97aa                	add	a5,a5,a0
    800053e6:	4705                	li	a4,1
    800053e8:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    800053ec:	0001e517          	auipc	a0,0x1e
    800053f0:	69c50513          	addi	a0,a0,1692 # 80023a88 <disk+0x18>
    800053f4:	b85fc0ef          	jal	80001f78 <wakeup>
}
    800053f8:	60a2                	ld	ra,8(sp)
    800053fa:	6402                	ld	s0,0(sp)
    800053fc:	0141                	addi	sp,sp,16
    800053fe:	8082                	ret
    panic("free_desc 1");
    80005400:	00002517          	auipc	a0,0x2
    80005404:	27050513          	addi	a0,a0,624 # 80007670 <etext+0x670>
    80005408:	b8cfb0ef          	jal	80000794 <panic>
    panic("free_desc 2");
    8000540c:	00002517          	auipc	a0,0x2
    80005410:	27450513          	addi	a0,a0,628 # 80007680 <etext+0x680>
    80005414:	b80fb0ef          	jal	80000794 <panic>

0000000080005418 <virtio_disk_init>:
{
    80005418:	1101                	addi	sp,sp,-32
    8000541a:	ec06                	sd	ra,24(sp)
    8000541c:	e822                	sd	s0,16(sp)
    8000541e:	e426                	sd	s1,8(sp)
    80005420:	e04a                	sd	s2,0(sp)
    80005422:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005424:	00002597          	auipc	a1,0x2
    80005428:	26c58593          	addi	a1,a1,620 # 80007690 <etext+0x690>
    8000542c:	0001e517          	auipc	a0,0x1e
    80005430:	76c50513          	addi	a0,a0,1900 # 80023b98 <disk+0x128>
    80005434:	f40fb0ef          	jal	80000b74 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005438:	100017b7          	lui	a5,0x10001
    8000543c:	4398                	lw	a4,0(a5)
    8000543e:	2701                	sext.w	a4,a4
    80005440:	747277b7          	lui	a5,0x74727
    80005444:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    80005448:	18f71063          	bne	a4,a5,800055c8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    8000544c:	100017b7          	lui	a5,0x10001
    80005450:	0791                	addi	a5,a5,4 # 10001004 <_entry-0x6fffeffc>
    80005452:	439c                	lw	a5,0(a5)
    80005454:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005456:	4709                	li	a4,2
    80005458:	16e79863          	bne	a5,a4,800055c8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000545c:	100017b7          	lui	a5,0x10001
    80005460:	07a1                	addi	a5,a5,8 # 10001008 <_entry-0x6fffeff8>
    80005462:	439c                	lw	a5,0(a5)
    80005464:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80005466:	16e79163          	bne	a5,a4,800055c8 <virtio_disk_init+0x1b0>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000546a:	100017b7          	lui	a5,0x10001
    8000546e:	47d8                	lw	a4,12(a5)
    80005470:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80005472:	554d47b7          	lui	a5,0x554d4
    80005476:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000547a:	14f71763          	bne	a4,a5,800055c8 <virtio_disk_init+0x1b0>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000547e:	100017b7          	lui	a5,0x10001
    80005482:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80005486:	4705                	li	a4,1
    80005488:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000548a:	470d                	li	a4,3
    8000548c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000548e:	10001737          	lui	a4,0x10001
    80005492:	4b14                	lw	a3,16(a4)
  features &= ~(1 << VIRTIO_RING_F_INDIRECT_DESC);
    80005494:	c7ffe737          	lui	a4,0xc7ffe
    80005498:	75f70713          	addi	a4,a4,1887 # ffffffffc7ffe75f <end+0xffffffff47fdabaf>
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    8000549c:	8ef9                	and	a3,a3,a4
    8000549e:	10001737          	lui	a4,0x10001
    800054a2:	d314                	sw	a3,32(a4)
  *R(VIRTIO_MMIO_STATUS) = status;
    800054a4:	472d                	li	a4,11
    800054a6:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    800054a8:	07078793          	addi	a5,a5,112
  status = *R(VIRTIO_MMIO_STATUS);
    800054ac:	439c                	lw	a5,0(a5)
    800054ae:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    800054b2:	8ba1                	andi	a5,a5,8
    800054b4:	12078063          	beqz	a5,800055d4 <virtio_disk_init+0x1bc>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    800054b8:	100017b7          	lui	a5,0x10001
    800054bc:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    800054c0:	100017b7          	lui	a5,0x10001
    800054c4:	04478793          	addi	a5,a5,68 # 10001044 <_entry-0x6fffefbc>
    800054c8:	439c                	lw	a5,0(a5)
    800054ca:	2781                	sext.w	a5,a5
    800054cc:	10079a63          	bnez	a5,800055e0 <virtio_disk_init+0x1c8>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    800054d0:	100017b7          	lui	a5,0x10001
    800054d4:	03478793          	addi	a5,a5,52 # 10001034 <_entry-0x6fffefcc>
    800054d8:	439c                	lw	a5,0(a5)
    800054da:	2781                	sext.w	a5,a5
  if(max == 0)
    800054dc:	10078863          	beqz	a5,800055ec <virtio_disk_init+0x1d4>
  if(max < NUM)
    800054e0:	471d                	li	a4,7
    800054e2:	10f77b63          	bgeu	a4,a5,800055f8 <virtio_disk_init+0x1e0>
  disk.desc = kalloc();
    800054e6:	e3efb0ef          	jal	80000b24 <kalloc>
    800054ea:	0001e497          	auipc	s1,0x1e
    800054ee:	58648493          	addi	s1,s1,1414 # 80023a70 <disk>
    800054f2:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800054f4:	e30fb0ef          	jal	80000b24 <kalloc>
    800054f8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800054fa:	e2afb0ef          	jal	80000b24 <kalloc>
    800054fe:	87aa                	mv	a5,a0
    80005500:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    80005502:	6088                	ld	a0,0(s1)
    80005504:	10050063          	beqz	a0,80005604 <virtio_disk_init+0x1ec>
    80005508:	0001e717          	auipc	a4,0x1e
    8000550c:	57073703          	ld	a4,1392(a4) # 80023a78 <disk+0x8>
    80005510:	0e070a63          	beqz	a4,80005604 <virtio_disk_init+0x1ec>
    80005514:	0e078863          	beqz	a5,80005604 <virtio_disk_init+0x1ec>
  memset(disk.desc, 0, PGSIZE);
    80005518:	6605                	lui	a2,0x1
    8000551a:	4581                	li	a1,0
    8000551c:	facfb0ef          	jal	80000cc8 <memset>
  memset(disk.avail, 0, PGSIZE);
    80005520:	0001e497          	auipc	s1,0x1e
    80005524:	55048493          	addi	s1,s1,1360 # 80023a70 <disk>
    80005528:	6605                	lui	a2,0x1
    8000552a:	4581                	li	a1,0
    8000552c:	6488                	ld	a0,8(s1)
    8000552e:	f9afb0ef          	jal	80000cc8 <memset>
  memset(disk.used, 0, PGSIZE);
    80005532:	6605                	lui	a2,0x1
    80005534:	4581                	li	a1,0
    80005536:	6888                	ld	a0,16(s1)
    80005538:	f90fb0ef          	jal	80000cc8 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    8000553c:	100017b7          	lui	a5,0x10001
    80005540:	4721                	li	a4,8
    80005542:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    80005544:	4098                	lw	a4,0(s1)
    80005546:	100017b7          	lui	a5,0x10001
    8000554a:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    8000554e:	40d8                	lw	a4,4(s1)
    80005550:	100017b7          	lui	a5,0x10001
    80005554:	08e7a223          	sw	a4,132(a5) # 10001084 <_entry-0x6fffef7c>
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    80005558:	649c                	ld	a5,8(s1)
    8000555a:	0007869b          	sext.w	a3,a5
    8000555e:	10001737          	lui	a4,0x10001
    80005562:	08d72823          	sw	a3,144(a4) # 10001090 <_entry-0x6fffef70>
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80005566:	9781                	srai	a5,a5,0x20
    80005568:	10001737          	lui	a4,0x10001
    8000556c:	08f72a23          	sw	a5,148(a4) # 10001094 <_entry-0x6fffef6c>
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    80005570:	689c                	ld	a5,16(s1)
    80005572:	0007869b          	sext.w	a3,a5
    80005576:	10001737          	lui	a4,0x10001
    8000557a:	0ad72023          	sw	a3,160(a4) # 100010a0 <_entry-0x6fffef60>
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    8000557e:	9781                	srai	a5,a5,0x20
    80005580:	10001737          	lui	a4,0x10001
    80005584:	0af72223          	sw	a5,164(a4) # 100010a4 <_entry-0x6fffef5c>
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    80005588:	10001737          	lui	a4,0x10001
    8000558c:	4785                	li	a5,1
    8000558e:	c37c                	sw	a5,68(a4)
    disk.free[i] = 1;
    80005590:	00f48c23          	sb	a5,24(s1)
    80005594:	00f48ca3          	sb	a5,25(s1)
    80005598:	00f48d23          	sb	a5,26(s1)
    8000559c:	00f48da3          	sb	a5,27(s1)
    800055a0:	00f48e23          	sb	a5,28(s1)
    800055a4:	00f48ea3          	sb	a5,29(s1)
    800055a8:	00f48f23          	sb	a5,30(s1)
    800055ac:	00f48fa3          	sb	a5,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    800055b0:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    800055b4:	100017b7          	lui	a5,0x10001
    800055b8:	0727a823          	sw	s2,112(a5) # 10001070 <_entry-0x6fffef90>
}
    800055bc:	60e2                	ld	ra,24(sp)
    800055be:	6442                	ld	s0,16(sp)
    800055c0:	64a2                	ld	s1,8(sp)
    800055c2:	6902                	ld	s2,0(sp)
    800055c4:	6105                	addi	sp,sp,32
    800055c6:	8082                	ret
    panic("could not find virtio disk");
    800055c8:	00002517          	auipc	a0,0x2
    800055cc:	0d850513          	addi	a0,a0,216 # 800076a0 <etext+0x6a0>
    800055d0:	9c4fb0ef          	jal	80000794 <panic>
    panic("virtio disk FEATURES_OK unset");
    800055d4:	00002517          	auipc	a0,0x2
    800055d8:	0ec50513          	addi	a0,a0,236 # 800076c0 <etext+0x6c0>
    800055dc:	9b8fb0ef          	jal	80000794 <panic>
    panic("virtio disk should not be ready");
    800055e0:	00002517          	auipc	a0,0x2
    800055e4:	10050513          	addi	a0,a0,256 # 800076e0 <etext+0x6e0>
    800055e8:	9acfb0ef          	jal	80000794 <panic>
    panic("virtio disk has no queue 0");
    800055ec:	00002517          	auipc	a0,0x2
    800055f0:	11450513          	addi	a0,a0,276 # 80007700 <etext+0x700>
    800055f4:	9a0fb0ef          	jal	80000794 <panic>
    panic("virtio disk max queue too short");
    800055f8:	00002517          	auipc	a0,0x2
    800055fc:	12850513          	addi	a0,a0,296 # 80007720 <etext+0x720>
    80005600:	994fb0ef          	jal	80000794 <panic>
    panic("virtio disk kalloc");
    80005604:	00002517          	auipc	a0,0x2
    80005608:	13c50513          	addi	a0,a0,316 # 80007740 <etext+0x740>
    8000560c:	988fb0ef          	jal	80000794 <panic>

0000000080005610 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    80005610:	7159                	addi	sp,sp,-112
    80005612:	f486                	sd	ra,104(sp)
    80005614:	f0a2                	sd	s0,96(sp)
    80005616:	eca6                	sd	s1,88(sp)
    80005618:	e8ca                	sd	s2,80(sp)
    8000561a:	e4ce                	sd	s3,72(sp)
    8000561c:	e0d2                	sd	s4,64(sp)
    8000561e:	fc56                	sd	s5,56(sp)
    80005620:	f85a                	sd	s6,48(sp)
    80005622:	f45e                	sd	s7,40(sp)
    80005624:	f062                	sd	s8,32(sp)
    80005626:	ec66                	sd	s9,24(sp)
    80005628:	1880                	addi	s0,sp,112
    8000562a:	8a2a                	mv	s4,a0
    8000562c:	8bae                	mv	s7,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    8000562e:	00c52c83          	lw	s9,12(a0)
    80005632:	001c9c9b          	slliw	s9,s9,0x1
    80005636:	1c82                	slli	s9,s9,0x20
    80005638:	020cdc93          	srli	s9,s9,0x20

  acquire(&disk.vdisk_lock);
    8000563c:	0001e517          	auipc	a0,0x1e
    80005640:	55c50513          	addi	a0,a0,1372 # 80023b98 <disk+0x128>
    80005644:	db0fb0ef          	jal	80000bf4 <acquire>
  for(int i = 0; i < 3; i++){
    80005648:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    8000564a:	44a1                	li	s1,8
      disk.free[i] = 0;
    8000564c:	0001eb17          	auipc	s6,0x1e
    80005650:	424b0b13          	addi	s6,s6,1060 # 80023a70 <disk>
  for(int i = 0; i < 3; i++){
    80005654:	4a8d                	li	s5,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80005656:	0001ec17          	auipc	s8,0x1e
    8000565a:	542c0c13          	addi	s8,s8,1346 # 80023b98 <disk+0x128>
    8000565e:	a8b9                	j	800056bc <virtio_disk_rw+0xac>
      disk.free[i] = 0;
    80005660:	00fb0733          	add	a4,s6,a5
    80005664:	00070c23          	sb	zero,24(a4) # 10001018 <_entry-0x6fffefe8>
    idx[i] = alloc_desc();
    80005668:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    8000566a:	0207c563          	bltz	a5,80005694 <virtio_disk_rw+0x84>
  for(int i = 0; i < 3; i++){
    8000566e:	2905                	addiw	s2,s2,1
    80005670:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    80005672:	05590963          	beq	s2,s5,800056c4 <virtio_disk_rw+0xb4>
    idx[i] = alloc_desc();
    80005676:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80005678:	0001e717          	auipc	a4,0x1e
    8000567c:	3f870713          	addi	a4,a4,1016 # 80023a70 <disk>
    80005680:	87ce                	mv	a5,s3
    if(disk.free[i]){
    80005682:	01874683          	lbu	a3,24(a4)
    80005686:	fee9                	bnez	a3,80005660 <virtio_disk_rw+0x50>
  for(int i = 0; i < NUM; i++){
    80005688:	2785                	addiw	a5,a5,1
    8000568a:	0705                	addi	a4,a4,1
    8000568c:	fe979be3          	bne	a5,s1,80005682 <virtio_disk_rw+0x72>
    idx[i] = alloc_desc();
    80005690:	57fd                	li	a5,-1
    80005692:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    80005694:	01205d63          	blez	s2,800056ae <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    80005698:	f9042503          	lw	a0,-112(s0)
    8000569c:	d07ff0ef          	jal	800053a2 <free_desc>
      for(int j = 0; j < i; j++)
    800056a0:	4785                	li	a5,1
    800056a2:	0127d663          	bge	a5,s2,800056ae <virtio_disk_rw+0x9e>
        free_desc(idx[j]);
    800056a6:	f9442503          	lw	a0,-108(s0)
    800056aa:	cf9ff0ef          	jal	800053a2 <free_desc>
    sleep(&disk.free[0], &disk.vdisk_lock);
    800056ae:	85e2                	mv	a1,s8
    800056b0:	0001e517          	auipc	a0,0x1e
    800056b4:	3d850513          	addi	a0,a0,984 # 80023a88 <disk+0x18>
    800056b8:	875fc0ef          	jal	80001f2c <sleep>
  for(int i = 0; i < 3; i++){
    800056bc:	f9040613          	addi	a2,s0,-112
    800056c0:	894e                	mv	s2,s3
    800056c2:	bf55                	j	80005676 <virtio_disk_rw+0x66>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800056c4:	f9042503          	lw	a0,-112(s0)
    800056c8:	00451693          	slli	a3,a0,0x4

  if(write)
    800056cc:	0001e797          	auipc	a5,0x1e
    800056d0:	3a478793          	addi	a5,a5,932 # 80023a70 <disk>
    800056d4:	00a50713          	addi	a4,a0,10
    800056d8:	0712                	slli	a4,a4,0x4
    800056da:	973e                	add	a4,a4,a5
    800056dc:	01703633          	snez	a2,s7
    800056e0:	c710                	sw	a2,8(a4)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800056e2:	00072623          	sw	zero,12(a4)
  buf0->sector = sector;
    800056e6:	01973823          	sd	s9,16(a4)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800056ea:	6398                	ld	a4,0(a5)
    800056ec:	9736                	add	a4,a4,a3
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800056ee:	0a868613          	addi	a2,a3,168
    800056f2:	963e                	add	a2,a2,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800056f4:	e310                	sd	a2,0(a4)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800056f6:	6390                	ld	a2,0(a5)
    800056f8:	00d605b3          	add	a1,a2,a3
    800056fc:	4741                	li	a4,16
    800056fe:	c598                	sw	a4,8(a1)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    80005700:	4805                	li	a6,1
    80005702:	01059623          	sh	a6,12(a1)
  disk.desc[idx[0]].next = idx[1];
    80005706:	f9442703          	lw	a4,-108(s0)
    8000570a:	00e59723          	sh	a4,14(a1)

  disk.desc[idx[1]].addr = (uint64) b->data;
    8000570e:	0712                	slli	a4,a4,0x4
    80005710:	963a                	add	a2,a2,a4
    80005712:	058a0593          	addi	a1,s4,88
    80005716:	e20c                	sd	a1,0(a2)
  disk.desc[idx[1]].len = BSIZE;
    80005718:	0007b883          	ld	a7,0(a5)
    8000571c:	9746                	add	a4,a4,a7
    8000571e:	40000613          	li	a2,1024
    80005722:	c710                	sw	a2,8(a4)
  if(write)
    80005724:	001bb613          	seqz	a2,s7
    80005728:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    8000572c:	00166613          	ori	a2,a2,1
    80005730:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[1]].next = idx[2];
    80005734:	f9842583          	lw	a1,-104(s0)
    80005738:	00b71723          	sh	a1,14(a4)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    8000573c:	00250613          	addi	a2,a0,2
    80005740:	0612                	slli	a2,a2,0x4
    80005742:	963e                	add	a2,a2,a5
    80005744:	577d                	li	a4,-1
    80005746:	00e60823          	sb	a4,16(a2)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000574a:	0592                	slli	a1,a1,0x4
    8000574c:	98ae                	add	a7,a7,a1
    8000574e:	03068713          	addi	a4,a3,48
    80005752:	973e                	add	a4,a4,a5
    80005754:	00e8b023          	sd	a4,0(a7)
  disk.desc[idx[2]].len = 1;
    80005758:	6398                	ld	a4,0(a5)
    8000575a:	972e                	add	a4,a4,a1
    8000575c:	01072423          	sw	a6,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80005760:	4689                	li	a3,2
    80005762:	00d71623          	sh	a3,12(a4)
  disk.desc[idx[2]].next = 0;
    80005766:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000576a:	010a2223          	sw	a6,4(s4)
  disk.info[idx[0]].b = b;
    8000576e:	01463423          	sd	s4,8(a2)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80005772:	6794                	ld	a3,8(a5)
    80005774:	0026d703          	lhu	a4,2(a3)
    80005778:	8b1d                	andi	a4,a4,7
    8000577a:	0706                	slli	a4,a4,0x1
    8000577c:	96ba                	add	a3,a3,a4
    8000577e:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80005782:	0330000f          	fence	rw,rw

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80005786:	6798                	ld	a4,8(a5)
    80005788:	00275783          	lhu	a5,2(a4)
    8000578c:	2785                	addiw	a5,a5,1
    8000578e:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80005792:	0330000f          	fence	rw,rw

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80005796:	100017b7          	lui	a5,0x10001
    8000579a:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    8000579e:	004a2783          	lw	a5,4(s4)
    sleep(b, &disk.vdisk_lock);
    800057a2:	0001e917          	auipc	s2,0x1e
    800057a6:	3f690913          	addi	s2,s2,1014 # 80023b98 <disk+0x128>
  while(b->disk == 1) {
    800057aa:	4485                	li	s1,1
    800057ac:	01079a63          	bne	a5,a6,800057c0 <virtio_disk_rw+0x1b0>
    sleep(b, &disk.vdisk_lock);
    800057b0:	85ca                	mv	a1,s2
    800057b2:	8552                	mv	a0,s4
    800057b4:	f78fc0ef          	jal	80001f2c <sleep>
  while(b->disk == 1) {
    800057b8:	004a2783          	lw	a5,4(s4)
    800057bc:	fe978ae3          	beq	a5,s1,800057b0 <virtio_disk_rw+0x1a0>
  }

  disk.info[idx[0]].b = 0;
    800057c0:	f9042903          	lw	s2,-112(s0)
    800057c4:	00290713          	addi	a4,s2,2
    800057c8:	0712                	slli	a4,a4,0x4
    800057ca:	0001e797          	auipc	a5,0x1e
    800057ce:	2a678793          	addi	a5,a5,678 # 80023a70 <disk>
    800057d2:	97ba                	add	a5,a5,a4
    800057d4:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    800057d8:	0001e997          	auipc	s3,0x1e
    800057dc:	29898993          	addi	s3,s3,664 # 80023a70 <disk>
    800057e0:	00491713          	slli	a4,s2,0x4
    800057e4:	0009b783          	ld	a5,0(s3)
    800057e8:	97ba                	add	a5,a5,a4
    800057ea:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800057ee:	854a                	mv	a0,s2
    800057f0:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800057f4:	bafff0ef          	jal	800053a2 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800057f8:	8885                	andi	s1,s1,1
    800057fa:	f0fd                	bnez	s1,800057e0 <virtio_disk_rw+0x1d0>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800057fc:	0001e517          	auipc	a0,0x1e
    80005800:	39c50513          	addi	a0,a0,924 # 80023b98 <disk+0x128>
    80005804:	c88fb0ef          	jal	80000c8c <release>
}
    80005808:	70a6                	ld	ra,104(sp)
    8000580a:	7406                	ld	s0,96(sp)
    8000580c:	64e6                	ld	s1,88(sp)
    8000580e:	6946                	ld	s2,80(sp)
    80005810:	69a6                	ld	s3,72(sp)
    80005812:	6a06                	ld	s4,64(sp)
    80005814:	7ae2                	ld	s5,56(sp)
    80005816:	7b42                	ld	s6,48(sp)
    80005818:	7ba2                	ld	s7,40(sp)
    8000581a:	7c02                	ld	s8,32(sp)
    8000581c:	6ce2                	ld	s9,24(sp)
    8000581e:	6165                	addi	sp,sp,112
    80005820:	8082                	ret

0000000080005822 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    80005822:	1101                	addi	sp,sp,-32
    80005824:	ec06                	sd	ra,24(sp)
    80005826:	e822                	sd	s0,16(sp)
    80005828:	e426                	sd	s1,8(sp)
    8000582a:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    8000582c:	0001e497          	auipc	s1,0x1e
    80005830:	24448493          	addi	s1,s1,580 # 80023a70 <disk>
    80005834:	0001e517          	auipc	a0,0x1e
    80005838:	36450513          	addi	a0,a0,868 # 80023b98 <disk+0x128>
    8000583c:	bb8fb0ef          	jal	80000bf4 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80005840:	100017b7          	lui	a5,0x10001
    80005844:	53b8                	lw	a4,96(a5)
    80005846:	8b0d                	andi	a4,a4,3
    80005848:	100017b7          	lui	a5,0x10001
    8000584c:	d3f8                	sw	a4,100(a5)

  __sync_synchronize();
    8000584e:	0330000f          	fence	rw,rw

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80005852:	689c                	ld	a5,16(s1)
    80005854:	0204d703          	lhu	a4,32(s1)
    80005858:	0027d783          	lhu	a5,2(a5) # 10001002 <_entry-0x6fffeffe>
    8000585c:	04f70663          	beq	a4,a5,800058a8 <virtio_disk_intr+0x86>
    __sync_synchronize();
    80005860:	0330000f          	fence	rw,rw
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80005864:	6898                	ld	a4,16(s1)
    80005866:	0204d783          	lhu	a5,32(s1)
    8000586a:	8b9d                	andi	a5,a5,7
    8000586c:	078e                	slli	a5,a5,0x3
    8000586e:	97ba                	add	a5,a5,a4
    80005870:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80005872:	00278713          	addi	a4,a5,2
    80005876:	0712                	slli	a4,a4,0x4
    80005878:	9726                	add	a4,a4,s1
    8000587a:	01074703          	lbu	a4,16(a4)
    8000587e:	e321                	bnez	a4,800058be <virtio_disk_intr+0x9c>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80005880:	0789                	addi	a5,a5,2
    80005882:	0792                	slli	a5,a5,0x4
    80005884:	97a6                	add	a5,a5,s1
    80005886:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    80005888:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000588c:	eecfc0ef          	jal	80001f78 <wakeup>

    disk.used_idx += 1;
    80005890:	0204d783          	lhu	a5,32(s1)
    80005894:	2785                	addiw	a5,a5,1
    80005896:	17c2                	slli	a5,a5,0x30
    80005898:	93c1                	srli	a5,a5,0x30
    8000589a:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    8000589e:	6898                	ld	a4,16(s1)
    800058a0:	00275703          	lhu	a4,2(a4)
    800058a4:	faf71ee3          	bne	a4,a5,80005860 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    800058a8:	0001e517          	auipc	a0,0x1e
    800058ac:	2f050513          	addi	a0,a0,752 # 80023b98 <disk+0x128>
    800058b0:	bdcfb0ef          	jal	80000c8c <release>
}
    800058b4:	60e2                	ld	ra,24(sp)
    800058b6:	6442                	ld	s0,16(sp)
    800058b8:	64a2                	ld	s1,8(sp)
    800058ba:	6105                	addi	sp,sp,32
    800058bc:	8082                	ret
      panic("virtio_disk_intr status");
    800058be:	00002517          	auipc	a0,0x2
    800058c2:	e9a50513          	addi	a0,a0,-358 # 80007758 <etext+0x758>
    800058c6:	ecffa0ef          	jal	80000794 <panic>

00000000800058ca <random>:

static unsigned int seed = 1;

int 
random(int max)
{
    800058ca:	1141                	addi	sp,sp,-16
    800058cc:	e422                	sd	s0,8(sp)
    800058ce:	0800                	addi	s0,sp,16
  seed = (uint64)seed * 48271 % 2147483647;
    800058d0:	00005697          	auipc	a3,0x5
    800058d4:	90868693          	addi	a3,a3,-1784 # 8000a1d8 <seed>
    800058d8:	0006e783          	lwu	a5,0(a3)
    800058dc:	6731                	lui	a4,0xc
    800058de:	c8f70713          	addi	a4,a4,-881 # bc8f <_entry-0x7fff4371>
    800058e2:	02e787b3          	mul	a5,a5,a4
    800058e6:	80000737          	lui	a4,0x80000
    800058ea:	fff74713          	not	a4,a4
    800058ee:	02e7f7b3          	remu	a5,a5,a4
    800058f2:	2781                	sext.w	a5,a5
    800058f4:	c29c                	sw	a5,0(a3)
  return seed % max;
    800058f6:	02a7f53b          	remuw	a0,a5,a0
    800058fa:	6422                	ld	s0,8(sp)
    800058fc:	0141                	addi	sp,sp,16
    800058fe:	8082                	ret
	...

0000000080006000 <_trampoline>:
    80006000:	14051073          	csrw	sscratch,a0
    80006004:	02000537          	lui	a0,0x2000
    80006008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000600a:	0536                	slli	a0,a0,0xd
    8000600c:	02153423          	sd	ra,40(a0)
    80006010:	02253823          	sd	sp,48(a0)
    80006014:	02353c23          	sd	gp,56(a0)
    80006018:	04453023          	sd	tp,64(a0)
    8000601c:	04553423          	sd	t0,72(a0)
    80006020:	04653823          	sd	t1,80(a0)
    80006024:	04753c23          	sd	t2,88(a0)
    80006028:	f120                	sd	s0,96(a0)
    8000602a:	f524                	sd	s1,104(a0)
    8000602c:	fd2c                	sd	a1,120(a0)
    8000602e:	e150                	sd	a2,128(a0)
    80006030:	e554                	sd	a3,136(a0)
    80006032:	e958                	sd	a4,144(a0)
    80006034:	ed5c                	sd	a5,152(a0)
    80006036:	0b053023          	sd	a6,160(a0)
    8000603a:	0b153423          	sd	a7,168(a0)
    8000603e:	0b253823          	sd	s2,176(a0)
    80006042:	0b353c23          	sd	s3,184(a0)
    80006046:	0d453023          	sd	s4,192(a0)
    8000604a:	0d553423          	sd	s5,200(a0)
    8000604e:	0d653823          	sd	s6,208(a0)
    80006052:	0d753c23          	sd	s7,216(a0)
    80006056:	0f853023          	sd	s8,224(a0)
    8000605a:	0f953423          	sd	s9,232(a0)
    8000605e:	0fa53823          	sd	s10,240(a0)
    80006062:	0fb53c23          	sd	s11,248(a0)
    80006066:	11c53023          	sd	t3,256(a0)
    8000606a:	11d53423          	sd	t4,264(a0)
    8000606e:	11e53823          	sd	t5,272(a0)
    80006072:	11f53c23          	sd	t6,280(a0)
    80006076:	140022f3          	csrr	t0,sscratch
    8000607a:	06553823          	sd	t0,112(a0)
    8000607e:	00853103          	ld	sp,8(a0)
    80006082:	02053203          	ld	tp,32(a0)
    80006086:	01053283          	ld	t0,16(a0)
    8000608a:	00053303          	ld	t1,0(a0)
    8000608e:	12000073          	sfence.vma
    80006092:	18031073          	csrw	satp,t1
    80006096:	12000073          	sfence.vma
    8000609a:	8282                	jr	t0

000000008000609c <userret>:
    8000609c:	12000073          	sfence.vma
    800060a0:	18051073          	csrw	satp,a0
    800060a4:	12000073          	sfence.vma
    800060a8:	02000537          	lui	a0,0x2000
    800060ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800060ae:	0536                	slli	a0,a0,0xd
    800060b0:	02853083          	ld	ra,40(a0)
    800060b4:	03053103          	ld	sp,48(a0)
    800060b8:	03853183          	ld	gp,56(a0)
    800060bc:	04053203          	ld	tp,64(a0)
    800060c0:	04853283          	ld	t0,72(a0)
    800060c4:	05053303          	ld	t1,80(a0)
    800060c8:	05853383          	ld	t2,88(a0)
    800060cc:	7120                	ld	s0,96(a0)
    800060ce:	7524                	ld	s1,104(a0)
    800060d0:	7d2c                	ld	a1,120(a0)
    800060d2:	6150                	ld	a2,128(a0)
    800060d4:	6554                	ld	a3,136(a0)
    800060d6:	6958                	ld	a4,144(a0)
    800060d8:	6d5c                	ld	a5,152(a0)
    800060da:	0a053803          	ld	a6,160(a0)
    800060de:	0a853883          	ld	a7,168(a0)
    800060e2:	0b053903          	ld	s2,176(a0)
    800060e6:	0b853983          	ld	s3,184(a0)
    800060ea:	0c053a03          	ld	s4,192(a0)
    800060ee:	0c853a83          	ld	s5,200(a0)
    800060f2:	0d053b03          	ld	s6,208(a0)
    800060f6:	0d853b83          	ld	s7,216(a0)
    800060fa:	0e053c03          	ld	s8,224(a0)
    800060fe:	0e853c83          	ld	s9,232(a0)
    80006102:	0f053d03          	ld	s10,240(a0)
    80006106:	0f853d83          	ld	s11,248(a0)
    8000610a:	10053e03          	ld	t3,256(a0)
    8000610e:	10853e83          	ld	t4,264(a0)
    80006112:	11053f03          	ld	t5,272(a0)
    80006116:	11853f83          	ld	t6,280(a0)
    8000611a:	7928                	ld	a0,112(a0)
    8000611c:	10200073          	sret
	...
