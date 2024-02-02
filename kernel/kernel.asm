
kernel/kernel:     file format elf64-littleriscv


Disassembly of section .text:

0000000080000000 <_entry>:
    80000000:	00009117          	auipc	sp,0x9
    80000004:	91013103          	ld	sp,-1776(sp) # 80008910 <_GLOBAL_OFFSET_TABLE_+0x8>
    80000008:	6505                	lui	a0,0x1
    8000000a:	f14025f3          	csrr	a1,mhartid
    8000000e:	0585                	addi	a1,a1,1
    80000010:	02b50533          	mul	a0,a0,a1
    80000014:	912a                	add	sp,sp,a0
    80000016:	076000ef          	jal	ra,8000008c <start>

000000008000001a <spin>:
    8000001a:	a001                	j	8000001a <spin>

000000008000001c <timerinit>:
// at timervec in kernelvec.S,
// which turns them into software interrupts for
// devintr() in trap.c.
void
timerinit()
{
    8000001c:	1141                	addi	sp,sp,-16
    8000001e:	e422                	sd	s0,8(sp)
    80000020:	0800                	addi	s0,sp,16
// which hart (core) is this?
static inline uint64
r_mhartid()
{
  uint64 x;
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    80000022:	f14027f3          	csrr	a5,mhartid
  // each CPU has a separate source of timer interrupts.
  int id = r_mhartid();
    80000026:	0007859b          	sext.w	a1,a5

  // ask the CLINT for a timer interrupt.
  int interval = 1000000; // cycles; about 1/10th second in qemu.
  *(uint64*)CLINT_MTIMECMP(id) = *(uint64*)CLINT_MTIME + interval;
    8000002a:	0037979b          	slliw	a5,a5,0x3
    8000002e:	02004737          	lui	a4,0x2004
    80000032:	97ba                	add	a5,a5,a4
    80000034:	0200c737          	lui	a4,0x200c
    80000038:	ff873703          	ld	a4,-8(a4) # 200bff8 <_entry-0x7dff4008>
    8000003c:	000f4637          	lui	a2,0xf4
    80000040:	24060613          	addi	a2,a2,576 # f4240 <_entry-0x7ff0bdc0>
    80000044:	9732                	add	a4,a4,a2
    80000046:	e398                	sd	a4,0(a5)

  // prepare information in scratch[] for timervec.
  // scratch[0..2] : space for timervec to save registers.
  // scratch[3] : address of CLINT MTIMECMP register.
  // scratch[4] : desired interval (in cycles) between timer interrupts.
  uint64 *scratch = &timer_scratch[id][0];
    80000048:	00259693          	slli	a3,a1,0x2
    8000004c:	96ae                	add	a3,a3,a1
    8000004e:	068e                	slli	a3,a3,0x3
    80000050:	00009717          	auipc	a4,0x9
    80000054:	92070713          	addi	a4,a4,-1760 # 80008970 <timer_scratch>
    80000058:	9736                	add	a4,a4,a3
  scratch[3] = CLINT_MTIMECMP(id);
    8000005a:	ef1c                	sd	a5,24(a4)
  scratch[4] = interval;
    8000005c:	f310                	sd	a2,32(a4)
}

static inline void 
w_mscratch(uint64 x)
{
  asm volatile("csrw mscratch, %0" : : "r" (x));
    8000005e:	34071073          	csrw	mscratch,a4
  asm volatile("csrw mtvec, %0" : : "r" (x));
    80000062:	00006797          	auipc	a5,0x6
    80000066:	e2e78793          	addi	a5,a5,-466 # 80005e90 <timervec>
    8000006a:	30579073          	csrw	mtvec,a5
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    8000006e:	300027f3          	csrr	a5,mstatus

  // set the machine-mode trap handler.
  w_mtvec((uint64)timervec);

  // enable machine-mode interrupts.
  w_mstatus(r_mstatus() | MSTATUS_MIE);
    80000072:	0087e793          	ori	a5,a5,8
  asm volatile("csrw mstatus, %0" : : "r" (x));
    80000076:	30079073          	csrw	mstatus,a5
  asm volatile("csrr %0, mie" : "=r" (x) );
    8000007a:	304027f3          	csrr	a5,mie

  // enable machine-mode timer interrupts.
  w_mie(r_mie() | MIE_MTIE);
    8000007e:	0807e793          	ori	a5,a5,128
  asm volatile("csrw mie, %0" : : "r" (x));
    80000082:	30479073          	csrw	mie,a5
}
    80000086:	6422                	ld	s0,8(sp)
    80000088:	0141                	addi	sp,sp,16
    8000008a:	8082                	ret

000000008000008c <start>:
{
    8000008c:	1141                	addi	sp,sp,-16
    8000008e:	e406                	sd	ra,8(sp)
    80000090:	e022                	sd	s0,0(sp)
    80000092:	0800                	addi	s0,sp,16
  asm volatile("csrr %0, mstatus" : "=r" (x) );
    80000094:	300027f3          	csrr	a5,mstatus
  x &= ~MSTATUS_MPP_MASK;
    80000098:	7779                	lui	a4,0xffffe
    8000009a:	7ff70713          	addi	a4,a4,2047 # ffffffffffffe7ff <end+0xffffffff7ffdca1f>
    8000009e:	8ff9                	and	a5,a5,a4
  x |= MSTATUS_MPP_S;
    800000a0:	6705                	lui	a4,0x1
    800000a2:	80070713          	addi	a4,a4,-2048 # 800 <_entry-0x7ffff800>
    800000a6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw mstatus, %0" : : "r" (x));
    800000a8:	30079073          	csrw	mstatus,a5
  asm volatile("csrw mepc, %0" : : "r" (x));
    800000ac:	00001797          	auipc	a5,0x1
    800000b0:	dcc78793          	addi	a5,a5,-564 # 80000e78 <main>
    800000b4:	34179073          	csrw	mepc,a5
  asm volatile("csrw satp, %0" : : "r" (x));
    800000b8:	4781                	li	a5,0
    800000ba:	18079073          	csrw	satp,a5
  asm volatile("csrw medeleg, %0" : : "r" (x));
    800000be:	67c1                	lui	a5,0x10
    800000c0:	17fd                	addi	a5,a5,-1 # ffff <_entry-0x7fff0001>
    800000c2:	30279073          	csrw	medeleg,a5
  asm volatile("csrw mideleg, %0" : : "r" (x));
    800000c6:	30379073          	csrw	mideleg,a5
  asm volatile("csrr %0, sie" : "=r" (x) );
    800000ca:	104027f3          	csrr	a5,sie
  w_sie(r_sie() | SIE_SEIE | SIE_STIE | SIE_SSIE);
    800000ce:	2227e793          	ori	a5,a5,546
  asm volatile("csrw sie, %0" : : "r" (x));
    800000d2:	10479073          	csrw	sie,a5
  asm volatile("csrw pmpaddr0, %0" : : "r" (x));
    800000d6:	57fd                	li	a5,-1
    800000d8:	83a9                	srli	a5,a5,0xa
    800000da:	3b079073          	csrw	pmpaddr0,a5
  asm volatile("csrw pmpcfg0, %0" : : "r" (x));
    800000de:	47bd                	li	a5,15
    800000e0:	3a079073          	csrw	pmpcfg0,a5
  timerinit();
    800000e4:	00000097          	auipc	ra,0x0
    800000e8:	f38080e7          	jalr	-200(ra) # 8000001c <timerinit>
  asm volatile("csrr %0, mhartid" : "=r" (x) );
    800000ec:	f14027f3          	csrr	a5,mhartid
  w_tp(id);
    800000f0:	2781                	sext.w	a5,a5
}

static inline void 
w_tp(uint64 x)
{
  asm volatile("mv tp, %0" : : "r" (x));
    800000f2:	823e                	mv	tp,a5
  asm volatile("mret");
    800000f4:	30200073          	mret
}
    800000f8:	60a2                	ld	ra,8(sp)
    800000fa:	6402                	ld	s0,0(sp)
    800000fc:	0141                	addi	sp,sp,16
    800000fe:	8082                	ret

0000000080000100 <consolewrite>:
//
// user write()s to the console go here.
//
int
consolewrite(int user_src, uint64 src, int n)
{
    80000100:	715d                	addi	sp,sp,-80
    80000102:	e486                	sd	ra,72(sp)
    80000104:	e0a2                	sd	s0,64(sp)
    80000106:	fc26                	sd	s1,56(sp)
    80000108:	f84a                	sd	s2,48(sp)
    8000010a:	f44e                	sd	s3,40(sp)
    8000010c:	f052                	sd	s4,32(sp)
    8000010e:	ec56                	sd	s5,24(sp)
    80000110:	0880                	addi	s0,sp,80
  int i;

  for(i = 0; i < n; i++){
    80000112:	04c05763          	blez	a2,80000160 <consolewrite+0x60>
    80000116:	8a2a                	mv	s4,a0
    80000118:	84ae                	mv	s1,a1
    8000011a:	89b2                	mv	s3,a2
    8000011c:	4901                	li	s2,0
    char c;
    if(either_copyin(&c, user_src, src+i, 1) == -1)
    8000011e:	5afd                	li	s5,-1
    80000120:	4685                	li	a3,1
    80000122:	8626                	mv	a2,s1
    80000124:	85d2                	mv	a1,s4
    80000126:	fbf40513          	addi	a0,s0,-65
    8000012a:	00002097          	auipc	ra,0x2
    8000012e:	4d6080e7          	jalr	1238(ra) # 80002600 <either_copyin>
    80000132:	01550d63          	beq	a0,s5,8000014c <consolewrite+0x4c>
      break;
    uartputc(c);
    80000136:	fbf44503          	lbu	a0,-65(s0)
    8000013a:	00000097          	auipc	ra,0x0
    8000013e:	784080e7          	jalr	1924(ra) # 800008be <uartputc>
  for(i = 0; i < n; i++){
    80000142:	2905                	addiw	s2,s2,1
    80000144:	0485                	addi	s1,s1,1
    80000146:	fd299de3          	bne	s3,s2,80000120 <consolewrite+0x20>
    8000014a:	894e                	mv	s2,s3
  }

  return i;
}
    8000014c:	854a                	mv	a0,s2
    8000014e:	60a6                	ld	ra,72(sp)
    80000150:	6406                	ld	s0,64(sp)
    80000152:	74e2                	ld	s1,56(sp)
    80000154:	7942                	ld	s2,48(sp)
    80000156:	79a2                	ld	s3,40(sp)
    80000158:	7a02                	ld	s4,32(sp)
    8000015a:	6ae2                	ld	s5,24(sp)
    8000015c:	6161                	addi	sp,sp,80
    8000015e:	8082                	ret
  for(i = 0; i < n; i++){
    80000160:	4901                	li	s2,0
    80000162:	b7ed                	j	8000014c <consolewrite+0x4c>

0000000080000164 <consoleread>:
// user_dist indicates whether dst is a user
// or kernel address.
//
int
consoleread(int user_dst, uint64 dst, int n)
{
    80000164:	7159                	addi	sp,sp,-112
    80000166:	f486                	sd	ra,104(sp)
    80000168:	f0a2                	sd	s0,96(sp)
    8000016a:	eca6                	sd	s1,88(sp)
    8000016c:	e8ca                	sd	s2,80(sp)
    8000016e:	e4ce                	sd	s3,72(sp)
    80000170:	e0d2                	sd	s4,64(sp)
    80000172:	fc56                	sd	s5,56(sp)
    80000174:	f85a                	sd	s6,48(sp)
    80000176:	f45e                	sd	s7,40(sp)
    80000178:	f062                	sd	s8,32(sp)
    8000017a:	ec66                	sd	s9,24(sp)
    8000017c:	e86a                	sd	s10,16(sp)
    8000017e:	1880                	addi	s0,sp,112
    80000180:	8aaa                	mv	s5,a0
    80000182:	8a2e                	mv	s4,a1
    80000184:	89b2                	mv	s3,a2
  uint target;
  int c;
  char cbuf;

  target = n;
    80000186:	00060b1b          	sext.w	s6,a2
  acquire(&cons.lock);
    8000018a:	00011517          	auipc	a0,0x11
    8000018e:	92650513          	addi	a0,a0,-1754 # 80010ab0 <cons>
    80000192:	00001097          	auipc	ra,0x1
    80000196:	a44080e7          	jalr	-1468(ra) # 80000bd6 <acquire>
  while(n > 0){
    // wait until interrupt handler has put some
    // input into cons.buffer.
    while(cons.r == cons.w){
    8000019a:	00011497          	auipc	s1,0x11
    8000019e:	91648493          	addi	s1,s1,-1770 # 80010ab0 <cons>
      if(killed(myproc())){
        release(&cons.lock);
        return -1;
      }
      sleep(&cons.r, &cons.lock);
    800001a2:	00011917          	auipc	s2,0x11
    800001a6:	9a690913          	addi	s2,s2,-1626 # 80010b48 <cons+0x98>
    }

    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];

    if(c == C('D')){  // end-of-file
    800001aa:	4b91                	li	s7,4
      break;
    }

    // copy the input byte to the user-space buffer.
    cbuf = c;
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    800001ac:	5c7d                	li	s8,-1
      break;

    dst++;
    --n;

    if(c == '\n'){
    800001ae:	4ca9                	li	s9,10
  while(n > 0){
    800001b0:	07305b63          	blez	s3,80000226 <consoleread+0xc2>
    while(cons.r == cons.w){
    800001b4:	0984a783          	lw	a5,152(s1)
    800001b8:	09c4a703          	lw	a4,156(s1)
    800001bc:	02f71763          	bne	a4,a5,800001ea <consoleread+0x86>
      if(killed(myproc())){
    800001c0:	00002097          	auipc	ra,0x2
    800001c4:	93a080e7          	jalr	-1734(ra) # 80001afa <myproc>
    800001c8:	00002097          	auipc	ra,0x2
    800001cc:	282080e7          	jalr	642(ra) # 8000244a <killed>
    800001d0:	e535                	bnez	a0,8000023c <consoleread+0xd8>
      sleep(&cons.r, &cons.lock);
    800001d2:	85a6                	mv	a1,s1
    800001d4:	854a                	mv	a0,s2
    800001d6:	00002097          	auipc	ra,0x2
    800001da:	fcc080e7          	jalr	-52(ra) # 800021a2 <sleep>
    while(cons.r == cons.w){
    800001de:	0984a783          	lw	a5,152(s1)
    800001e2:	09c4a703          	lw	a4,156(s1)
    800001e6:	fcf70de3          	beq	a4,a5,800001c0 <consoleread+0x5c>
    c = cons.buf[cons.r++ % INPUT_BUF_SIZE];
    800001ea:	0017871b          	addiw	a4,a5,1
    800001ee:	08e4ac23          	sw	a4,152(s1)
    800001f2:	07f7f713          	andi	a4,a5,127
    800001f6:	9726                	add	a4,a4,s1
    800001f8:	01874703          	lbu	a4,24(a4)
    800001fc:	00070d1b          	sext.w	s10,a4
    if(c == C('D')){  // end-of-file
    80000200:	077d0563          	beq	s10,s7,8000026a <consoleread+0x106>
    cbuf = c;
    80000204:	f8e40fa3          	sb	a4,-97(s0)
    if(either_copyout(user_dst, dst, &cbuf, 1) == -1)
    80000208:	4685                	li	a3,1
    8000020a:	f9f40613          	addi	a2,s0,-97
    8000020e:	85d2                	mv	a1,s4
    80000210:	8556                	mv	a0,s5
    80000212:	00002097          	auipc	ra,0x2
    80000216:	398080e7          	jalr	920(ra) # 800025aa <either_copyout>
    8000021a:	01850663          	beq	a0,s8,80000226 <consoleread+0xc2>
    dst++;
    8000021e:	0a05                	addi	s4,s4,1
    --n;
    80000220:	39fd                	addiw	s3,s3,-1
    if(c == '\n'){
    80000222:	f99d17e3          	bne	s10,s9,800001b0 <consoleread+0x4c>
      // a whole line has arrived, return to
      // the user-level read().
      break;
    }
  }
  release(&cons.lock);
    80000226:	00011517          	auipc	a0,0x11
    8000022a:	88a50513          	addi	a0,a0,-1910 # 80010ab0 <cons>
    8000022e:	00001097          	auipc	ra,0x1
    80000232:	a5c080e7          	jalr	-1444(ra) # 80000c8a <release>

  return target - n;
    80000236:	413b053b          	subw	a0,s6,s3
    8000023a:	a811                	j	8000024e <consoleread+0xea>
        release(&cons.lock);
    8000023c:	00011517          	auipc	a0,0x11
    80000240:	87450513          	addi	a0,a0,-1932 # 80010ab0 <cons>
    80000244:	00001097          	auipc	ra,0x1
    80000248:	a46080e7          	jalr	-1466(ra) # 80000c8a <release>
        return -1;
    8000024c:	557d                	li	a0,-1
}
    8000024e:	70a6                	ld	ra,104(sp)
    80000250:	7406                	ld	s0,96(sp)
    80000252:	64e6                	ld	s1,88(sp)
    80000254:	6946                	ld	s2,80(sp)
    80000256:	69a6                	ld	s3,72(sp)
    80000258:	6a06                	ld	s4,64(sp)
    8000025a:	7ae2                	ld	s5,56(sp)
    8000025c:	7b42                	ld	s6,48(sp)
    8000025e:	7ba2                	ld	s7,40(sp)
    80000260:	7c02                	ld	s8,32(sp)
    80000262:	6ce2                	ld	s9,24(sp)
    80000264:	6d42                	ld	s10,16(sp)
    80000266:	6165                	addi	sp,sp,112
    80000268:	8082                	ret
      if(n < target){
    8000026a:	0009871b          	sext.w	a4,s3
    8000026e:	fb677ce3          	bgeu	a4,s6,80000226 <consoleread+0xc2>
        cons.r--;
    80000272:	00011717          	auipc	a4,0x11
    80000276:	8cf72b23          	sw	a5,-1834(a4) # 80010b48 <cons+0x98>
    8000027a:	b775                	j	80000226 <consoleread+0xc2>

000000008000027c <consputc>:
{
    8000027c:	1141                	addi	sp,sp,-16
    8000027e:	e406                	sd	ra,8(sp)
    80000280:	e022                	sd	s0,0(sp)
    80000282:	0800                	addi	s0,sp,16
  if(c == BACKSPACE){
    80000284:	10000793          	li	a5,256
    80000288:	00f50a63          	beq	a0,a5,8000029c <consputc+0x20>
    uartputc_sync(c);
    8000028c:	00000097          	auipc	ra,0x0
    80000290:	560080e7          	jalr	1376(ra) # 800007ec <uartputc_sync>
}
    80000294:	60a2                	ld	ra,8(sp)
    80000296:	6402                	ld	s0,0(sp)
    80000298:	0141                	addi	sp,sp,16
    8000029a:	8082                	ret
    uartputc_sync('\b'); uartputc_sync(' '); uartputc_sync('\b');
    8000029c:	4521                	li	a0,8
    8000029e:	00000097          	auipc	ra,0x0
    800002a2:	54e080e7          	jalr	1358(ra) # 800007ec <uartputc_sync>
    800002a6:	02000513          	li	a0,32
    800002aa:	00000097          	auipc	ra,0x0
    800002ae:	542080e7          	jalr	1346(ra) # 800007ec <uartputc_sync>
    800002b2:	4521                	li	a0,8
    800002b4:	00000097          	auipc	ra,0x0
    800002b8:	538080e7          	jalr	1336(ra) # 800007ec <uartputc_sync>
    800002bc:	bfe1                	j	80000294 <consputc+0x18>

00000000800002be <consoleintr>:
// do erase/kill processing, append to cons.buf,
// wake up consoleread() if a whole line has arrived.
//
void
consoleintr(int c)
{
    800002be:	1101                	addi	sp,sp,-32
    800002c0:	ec06                	sd	ra,24(sp)
    800002c2:	e822                	sd	s0,16(sp)
    800002c4:	e426                	sd	s1,8(sp)
    800002c6:	e04a                	sd	s2,0(sp)
    800002c8:	1000                	addi	s0,sp,32
    800002ca:	84aa                	mv	s1,a0
  acquire(&cons.lock);
    800002cc:	00010517          	auipc	a0,0x10
    800002d0:	7e450513          	addi	a0,a0,2020 # 80010ab0 <cons>
    800002d4:	00001097          	auipc	ra,0x1
    800002d8:	902080e7          	jalr	-1790(ra) # 80000bd6 <acquire>

  switch(c){
    800002dc:	47d5                	li	a5,21
    800002de:	0af48663          	beq	s1,a5,8000038a <consoleintr+0xcc>
    800002e2:	0297ca63          	blt	a5,s1,80000316 <consoleintr+0x58>
    800002e6:	47a1                	li	a5,8
    800002e8:	0ef48763          	beq	s1,a5,800003d6 <consoleintr+0x118>
    800002ec:	47c1                	li	a5,16
    800002ee:	10f49a63          	bne	s1,a5,80000402 <consoleintr+0x144>
  case C('P'):  // Print process list.
    procdump();
    800002f2:	00002097          	auipc	ra,0x2
    800002f6:	364080e7          	jalr	868(ra) # 80002656 <procdump>
      }
    }
    break;
  }
  
  release(&cons.lock);
    800002fa:	00010517          	auipc	a0,0x10
    800002fe:	7b650513          	addi	a0,a0,1974 # 80010ab0 <cons>
    80000302:	00001097          	auipc	ra,0x1
    80000306:	988080e7          	jalr	-1656(ra) # 80000c8a <release>
}
    8000030a:	60e2                	ld	ra,24(sp)
    8000030c:	6442                	ld	s0,16(sp)
    8000030e:	64a2                	ld	s1,8(sp)
    80000310:	6902                	ld	s2,0(sp)
    80000312:	6105                	addi	sp,sp,32
    80000314:	8082                	ret
  switch(c){
    80000316:	07f00793          	li	a5,127
    8000031a:	0af48e63          	beq	s1,a5,800003d6 <consoleintr+0x118>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    8000031e:	00010717          	auipc	a4,0x10
    80000322:	79270713          	addi	a4,a4,1938 # 80010ab0 <cons>
    80000326:	0a072783          	lw	a5,160(a4)
    8000032a:	09872703          	lw	a4,152(a4)
    8000032e:	9f99                	subw	a5,a5,a4
    80000330:	07f00713          	li	a4,127
    80000334:	fcf763e3          	bltu	a4,a5,800002fa <consoleintr+0x3c>
      c = (c == '\r') ? '\n' : c;
    80000338:	47b5                	li	a5,13
    8000033a:	0cf48763          	beq	s1,a5,80000408 <consoleintr+0x14a>
      consputc(c);
    8000033e:	8526                	mv	a0,s1
    80000340:	00000097          	auipc	ra,0x0
    80000344:	f3c080e7          	jalr	-196(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000348:	00010797          	auipc	a5,0x10
    8000034c:	76878793          	addi	a5,a5,1896 # 80010ab0 <cons>
    80000350:	0a07a683          	lw	a3,160(a5)
    80000354:	0016871b          	addiw	a4,a3,1
    80000358:	0007061b          	sext.w	a2,a4
    8000035c:	0ae7a023          	sw	a4,160(a5)
    80000360:	07f6f693          	andi	a3,a3,127
    80000364:	97b6                	add	a5,a5,a3
    80000366:	00978c23          	sb	s1,24(a5)
      if(c == '\n' || c == C('D') || cons.e-cons.r == INPUT_BUF_SIZE){
    8000036a:	47a9                	li	a5,10
    8000036c:	0cf48563          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000370:	4791                	li	a5,4
    80000372:	0cf48263          	beq	s1,a5,80000436 <consoleintr+0x178>
    80000376:	00010797          	auipc	a5,0x10
    8000037a:	7d27a783          	lw	a5,2002(a5) # 80010b48 <cons+0x98>
    8000037e:	9f1d                	subw	a4,a4,a5
    80000380:	08000793          	li	a5,128
    80000384:	f6f71be3          	bne	a4,a5,800002fa <consoleintr+0x3c>
    80000388:	a07d                	j	80000436 <consoleintr+0x178>
    while(cons.e != cons.w &&
    8000038a:	00010717          	auipc	a4,0x10
    8000038e:	72670713          	addi	a4,a4,1830 # 80010ab0 <cons>
    80000392:	0a072783          	lw	a5,160(a4)
    80000396:	09c72703          	lw	a4,156(a4)
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    8000039a:	00010497          	auipc	s1,0x10
    8000039e:	71648493          	addi	s1,s1,1814 # 80010ab0 <cons>
    while(cons.e != cons.w &&
    800003a2:	4929                	li	s2,10
    800003a4:	f4f70be3          	beq	a4,a5,800002fa <consoleintr+0x3c>
          cons.buf[(cons.e-1) % INPUT_BUF_SIZE] != '\n'){
    800003a8:	37fd                	addiw	a5,a5,-1
    800003aa:	07f7f713          	andi	a4,a5,127
    800003ae:	9726                	add	a4,a4,s1
    while(cons.e != cons.w &&
    800003b0:	01874703          	lbu	a4,24(a4)
    800003b4:	f52703e3          	beq	a4,s2,800002fa <consoleintr+0x3c>
      cons.e--;
    800003b8:	0af4a023          	sw	a5,160(s1)
      consputc(BACKSPACE);
    800003bc:	10000513          	li	a0,256
    800003c0:	00000097          	auipc	ra,0x0
    800003c4:	ebc080e7          	jalr	-324(ra) # 8000027c <consputc>
    while(cons.e != cons.w &&
    800003c8:	0a04a783          	lw	a5,160(s1)
    800003cc:	09c4a703          	lw	a4,156(s1)
    800003d0:	fcf71ce3          	bne	a4,a5,800003a8 <consoleintr+0xea>
    800003d4:	b71d                	j	800002fa <consoleintr+0x3c>
    if(cons.e != cons.w){
    800003d6:	00010717          	auipc	a4,0x10
    800003da:	6da70713          	addi	a4,a4,1754 # 80010ab0 <cons>
    800003de:	0a072783          	lw	a5,160(a4)
    800003e2:	09c72703          	lw	a4,156(a4)
    800003e6:	f0f70ae3          	beq	a4,a5,800002fa <consoleintr+0x3c>
      cons.e--;
    800003ea:	37fd                	addiw	a5,a5,-1
    800003ec:	00010717          	auipc	a4,0x10
    800003f0:	76f72223          	sw	a5,1892(a4) # 80010b50 <cons+0xa0>
      consputc(BACKSPACE);
    800003f4:	10000513          	li	a0,256
    800003f8:	00000097          	auipc	ra,0x0
    800003fc:	e84080e7          	jalr	-380(ra) # 8000027c <consputc>
    80000400:	bded                	j	800002fa <consoleintr+0x3c>
    if(c != 0 && cons.e-cons.r < INPUT_BUF_SIZE){
    80000402:	ee048ce3          	beqz	s1,800002fa <consoleintr+0x3c>
    80000406:	bf21                	j	8000031e <consoleintr+0x60>
      consputc(c);
    80000408:	4529                	li	a0,10
    8000040a:	00000097          	auipc	ra,0x0
    8000040e:	e72080e7          	jalr	-398(ra) # 8000027c <consputc>
      cons.buf[cons.e++ % INPUT_BUF_SIZE] = c;
    80000412:	00010797          	auipc	a5,0x10
    80000416:	69e78793          	addi	a5,a5,1694 # 80010ab0 <cons>
    8000041a:	0a07a703          	lw	a4,160(a5)
    8000041e:	0017069b          	addiw	a3,a4,1
    80000422:	0006861b          	sext.w	a2,a3
    80000426:	0ad7a023          	sw	a3,160(a5)
    8000042a:	07f77713          	andi	a4,a4,127
    8000042e:	97ba                	add	a5,a5,a4
    80000430:	4729                	li	a4,10
    80000432:	00e78c23          	sb	a4,24(a5)
        cons.w = cons.e;
    80000436:	00010797          	auipc	a5,0x10
    8000043a:	70c7ab23          	sw	a2,1814(a5) # 80010b4c <cons+0x9c>
        wakeup(&cons.r);
    8000043e:	00010517          	auipc	a0,0x10
    80000442:	70a50513          	addi	a0,a0,1802 # 80010b48 <cons+0x98>
    80000446:	00002097          	auipc	ra,0x2
    8000044a:	dc0080e7          	jalr	-576(ra) # 80002206 <wakeup>
    8000044e:	b575                	j	800002fa <consoleintr+0x3c>

0000000080000450 <consoleinit>:

void
consoleinit(void)
{
    80000450:	1141                	addi	sp,sp,-16
    80000452:	e406                	sd	ra,8(sp)
    80000454:	e022                	sd	s0,0(sp)
    80000456:	0800                	addi	s0,sp,16
  initlock(&cons.lock, "cons");
    80000458:	00008597          	auipc	a1,0x8
    8000045c:	bb858593          	addi	a1,a1,-1096 # 80008010 <etext+0x10>
    80000460:	00010517          	auipc	a0,0x10
    80000464:	65050513          	addi	a0,a0,1616 # 80010ab0 <cons>
    80000468:	00000097          	auipc	ra,0x0
    8000046c:	6de080e7          	jalr	1758(ra) # 80000b46 <initlock>

  uartinit();
    80000470:	00000097          	auipc	ra,0x0
    80000474:	32c080e7          	jalr	812(ra) # 8000079c <uartinit>

  // connect read and write system calls
  // to consoleread and consolewrite.
  devsw[CONSOLE].read = consoleread;
    80000478:	00020797          	auipc	a5,0x20
    8000047c:	7d078793          	addi	a5,a5,2000 # 80020c48 <devsw>
    80000480:	00000717          	auipc	a4,0x0
    80000484:	ce470713          	addi	a4,a4,-796 # 80000164 <consoleread>
    80000488:	eb98                	sd	a4,16(a5)
  devsw[CONSOLE].write = consolewrite;
    8000048a:	00000717          	auipc	a4,0x0
    8000048e:	c7670713          	addi	a4,a4,-906 # 80000100 <consolewrite>
    80000492:	ef98                	sd	a4,24(a5)
}
    80000494:	60a2                	ld	ra,8(sp)
    80000496:	6402                	ld	s0,0(sp)
    80000498:	0141                	addi	sp,sp,16
    8000049a:	8082                	ret

000000008000049c <printint>:

static char digits[] = "0123456789abcdef";

static void
printint(int xx, int base, int sign)
{
    8000049c:	7179                	addi	sp,sp,-48
    8000049e:	f406                	sd	ra,40(sp)
    800004a0:	f022                	sd	s0,32(sp)
    800004a2:	ec26                	sd	s1,24(sp)
    800004a4:	e84a                	sd	s2,16(sp)
    800004a6:	1800                	addi	s0,sp,48
  char buf[16];
  int i;
  uint x;

  if(sign && (sign = xx < 0))
    800004a8:	c219                	beqz	a2,800004ae <printint+0x12>
    800004aa:	08054763          	bltz	a0,80000538 <printint+0x9c>
    x = -xx;
  else
    x = xx;
    800004ae:	2501                	sext.w	a0,a0
    800004b0:	4881                	li	a7,0
    800004b2:	fd040693          	addi	a3,s0,-48

  i = 0;
    800004b6:	4701                	li	a4,0
  do {
    buf[i++] = digits[x % base];
    800004b8:	2581                	sext.w	a1,a1
    800004ba:	00008617          	auipc	a2,0x8
    800004be:	b8660613          	addi	a2,a2,-1146 # 80008040 <digits>
    800004c2:	883a                	mv	a6,a4
    800004c4:	2705                	addiw	a4,a4,1
    800004c6:	02b577bb          	remuw	a5,a0,a1
    800004ca:	1782                	slli	a5,a5,0x20
    800004cc:	9381                	srli	a5,a5,0x20
    800004ce:	97b2                	add	a5,a5,a2
    800004d0:	0007c783          	lbu	a5,0(a5)
    800004d4:	00f68023          	sb	a5,0(a3)
  } while((x /= base) != 0);
    800004d8:	0005079b          	sext.w	a5,a0
    800004dc:	02b5553b          	divuw	a0,a0,a1
    800004e0:	0685                	addi	a3,a3,1
    800004e2:	feb7f0e3          	bgeu	a5,a1,800004c2 <printint+0x26>

  if(sign)
    800004e6:	00088c63          	beqz	a7,800004fe <printint+0x62>
    buf[i++] = '-';
    800004ea:	fe070793          	addi	a5,a4,-32
    800004ee:	00878733          	add	a4,a5,s0
    800004f2:	02d00793          	li	a5,45
    800004f6:	fef70823          	sb	a5,-16(a4)
    800004fa:	0028071b          	addiw	a4,a6,2

  while(--i >= 0)
    800004fe:	02e05763          	blez	a4,8000052c <printint+0x90>
    80000502:	fd040793          	addi	a5,s0,-48
    80000506:	00e784b3          	add	s1,a5,a4
    8000050a:	fff78913          	addi	s2,a5,-1
    8000050e:	993a                	add	s2,s2,a4
    80000510:	377d                	addiw	a4,a4,-1
    80000512:	1702                	slli	a4,a4,0x20
    80000514:	9301                	srli	a4,a4,0x20
    80000516:	40e90933          	sub	s2,s2,a4
    consputc(buf[i]);
    8000051a:	fff4c503          	lbu	a0,-1(s1)
    8000051e:	00000097          	auipc	ra,0x0
    80000522:	d5e080e7          	jalr	-674(ra) # 8000027c <consputc>
  while(--i >= 0)
    80000526:	14fd                	addi	s1,s1,-1
    80000528:	ff2499e3          	bne	s1,s2,8000051a <printint+0x7e>
}
    8000052c:	70a2                	ld	ra,40(sp)
    8000052e:	7402                	ld	s0,32(sp)
    80000530:	64e2                	ld	s1,24(sp)
    80000532:	6942                	ld	s2,16(sp)
    80000534:	6145                	addi	sp,sp,48
    80000536:	8082                	ret
    x = -xx;
    80000538:	40a0053b          	negw	a0,a0
  if(sign && (sign = xx < 0))
    8000053c:	4885                	li	a7,1
    x = -xx;
    8000053e:	bf95                	j	800004b2 <printint+0x16>

0000000080000540 <panic>:
    release(&pr.lock);
}

void
panic(char *s)
{
    80000540:	1101                	addi	sp,sp,-32
    80000542:	ec06                	sd	ra,24(sp)
    80000544:	e822                	sd	s0,16(sp)
    80000546:	e426                	sd	s1,8(sp)
    80000548:	1000                	addi	s0,sp,32
    8000054a:	84aa                	mv	s1,a0
  pr.locking = 0;
    8000054c:	00010797          	auipc	a5,0x10
    80000550:	6207a223          	sw	zero,1572(a5) # 80010b70 <pr+0x18>
  printf("panic: ");
    80000554:	00008517          	auipc	a0,0x8
    80000558:	ac450513          	addi	a0,a0,-1340 # 80008018 <etext+0x18>
    8000055c:	00000097          	auipc	ra,0x0
    80000560:	02e080e7          	jalr	46(ra) # 8000058a <printf>
  printf(s);
    80000564:	8526                	mv	a0,s1
    80000566:	00000097          	auipc	ra,0x0
    8000056a:	024080e7          	jalr	36(ra) # 8000058a <printf>
  printf("\n");
    8000056e:	00008517          	auipc	a0,0x8
    80000572:	b5a50513          	addi	a0,a0,-1190 # 800080c8 <digits+0x88>
    80000576:	00000097          	auipc	ra,0x0
    8000057a:	014080e7          	jalr	20(ra) # 8000058a <printf>
  panicked = 1; // freeze uart output from other CPUs
    8000057e:	4785                	li	a5,1
    80000580:	00008717          	auipc	a4,0x8
    80000584:	3af72823          	sw	a5,944(a4) # 80008930 <panicked>
  for(;;)
    80000588:	a001                	j	80000588 <panic+0x48>

000000008000058a <printf>:
{
    8000058a:	7131                	addi	sp,sp,-192
    8000058c:	fc86                	sd	ra,120(sp)
    8000058e:	f8a2                	sd	s0,112(sp)
    80000590:	f4a6                	sd	s1,104(sp)
    80000592:	f0ca                	sd	s2,96(sp)
    80000594:	ecce                	sd	s3,88(sp)
    80000596:	e8d2                	sd	s4,80(sp)
    80000598:	e4d6                	sd	s5,72(sp)
    8000059a:	e0da                	sd	s6,64(sp)
    8000059c:	fc5e                	sd	s7,56(sp)
    8000059e:	f862                	sd	s8,48(sp)
    800005a0:	f466                	sd	s9,40(sp)
    800005a2:	f06a                	sd	s10,32(sp)
    800005a4:	ec6e                	sd	s11,24(sp)
    800005a6:	0100                	addi	s0,sp,128
    800005a8:	8a2a                	mv	s4,a0
    800005aa:	e40c                	sd	a1,8(s0)
    800005ac:	e810                	sd	a2,16(s0)
    800005ae:	ec14                	sd	a3,24(s0)
    800005b0:	f018                	sd	a4,32(s0)
    800005b2:	f41c                	sd	a5,40(s0)
    800005b4:	03043823          	sd	a6,48(s0)
    800005b8:	03143c23          	sd	a7,56(s0)
  locking = pr.locking;
    800005bc:	00010d97          	auipc	s11,0x10
    800005c0:	5b4dad83          	lw	s11,1460(s11) # 80010b70 <pr+0x18>
  if(locking)
    800005c4:	020d9b63          	bnez	s11,800005fa <printf+0x70>
  if (fmt == 0)
    800005c8:	040a0263          	beqz	s4,8000060c <printf+0x82>
  va_start(ap, fmt);
    800005cc:	00840793          	addi	a5,s0,8
    800005d0:	f8f43423          	sd	a5,-120(s0)
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    800005d4:	000a4503          	lbu	a0,0(s4)
    800005d8:	14050f63          	beqz	a0,80000736 <printf+0x1ac>
    800005dc:	4981                	li	s3,0
    if(c != '%'){
    800005de:	02500a93          	li	s5,37
    switch(c){
    800005e2:	07000b93          	li	s7,112
  consputc('x');
    800005e6:	4d41                	li	s10,16
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800005e8:	00008b17          	auipc	s6,0x8
    800005ec:	a58b0b13          	addi	s6,s6,-1448 # 80008040 <digits>
    switch(c){
    800005f0:	07300c93          	li	s9,115
    800005f4:	06400c13          	li	s8,100
    800005f8:	a82d                	j	80000632 <printf+0xa8>
    acquire(&pr.lock);
    800005fa:	00010517          	auipc	a0,0x10
    800005fe:	55e50513          	addi	a0,a0,1374 # 80010b58 <pr>
    80000602:	00000097          	auipc	ra,0x0
    80000606:	5d4080e7          	jalr	1492(ra) # 80000bd6 <acquire>
    8000060a:	bf7d                	j	800005c8 <printf+0x3e>
    panic("null fmt");
    8000060c:	00008517          	auipc	a0,0x8
    80000610:	a1c50513          	addi	a0,a0,-1508 # 80008028 <etext+0x28>
    80000614:	00000097          	auipc	ra,0x0
    80000618:	f2c080e7          	jalr	-212(ra) # 80000540 <panic>
      consputc(c);
    8000061c:	00000097          	auipc	ra,0x0
    80000620:	c60080e7          	jalr	-928(ra) # 8000027c <consputc>
  for(i = 0; (c = fmt[i] & 0xff) != 0; i++){
    80000624:	2985                	addiw	s3,s3,1
    80000626:	013a07b3          	add	a5,s4,s3
    8000062a:	0007c503          	lbu	a0,0(a5)
    8000062e:	10050463          	beqz	a0,80000736 <printf+0x1ac>
    if(c != '%'){
    80000632:	ff5515e3          	bne	a0,s5,8000061c <printf+0x92>
    c = fmt[++i] & 0xff;
    80000636:	2985                	addiw	s3,s3,1
    80000638:	013a07b3          	add	a5,s4,s3
    8000063c:	0007c783          	lbu	a5,0(a5)
    80000640:	0007849b          	sext.w	s1,a5
    if(c == 0)
    80000644:	cbed                	beqz	a5,80000736 <printf+0x1ac>
    switch(c){
    80000646:	05778a63          	beq	a5,s7,8000069a <printf+0x110>
    8000064a:	02fbf663          	bgeu	s7,a5,80000676 <printf+0xec>
    8000064e:	09978863          	beq	a5,s9,800006de <printf+0x154>
    80000652:	07800713          	li	a4,120
    80000656:	0ce79563          	bne	a5,a4,80000720 <printf+0x196>
      printint(va_arg(ap, int), 16, 1);
    8000065a:	f8843783          	ld	a5,-120(s0)
    8000065e:	00878713          	addi	a4,a5,8
    80000662:	f8e43423          	sd	a4,-120(s0)
    80000666:	4605                	li	a2,1
    80000668:	85ea                	mv	a1,s10
    8000066a:	4388                	lw	a0,0(a5)
    8000066c:	00000097          	auipc	ra,0x0
    80000670:	e30080e7          	jalr	-464(ra) # 8000049c <printint>
      break;
    80000674:	bf45                	j	80000624 <printf+0x9a>
    switch(c){
    80000676:	09578f63          	beq	a5,s5,80000714 <printf+0x18a>
    8000067a:	0b879363          	bne	a5,s8,80000720 <printf+0x196>
      printint(va_arg(ap, int), 10, 1);
    8000067e:	f8843783          	ld	a5,-120(s0)
    80000682:	00878713          	addi	a4,a5,8
    80000686:	f8e43423          	sd	a4,-120(s0)
    8000068a:	4605                	li	a2,1
    8000068c:	45a9                	li	a1,10
    8000068e:	4388                	lw	a0,0(a5)
    80000690:	00000097          	auipc	ra,0x0
    80000694:	e0c080e7          	jalr	-500(ra) # 8000049c <printint>
      break;
    80000698:	b771                	j	80000624 <printf+0x9a>
      printptr(va_arg(ap, uint64));
    8000069a:	f8843783          	ld	a5,-120(s0)
    8000069e:	00878713          	addi	a4,a5,8
    800006a2:	f8e43423          	sd	a4,-120(s0)
    800006a6:	0007b903          	ld	s2,0(a5)
  consputc('0');
    800006aa:	03000513          	li	a0,48
    800006ae:	00000097          	auipc	ra,0x0
    800006b2:	bce080e7          	jalr	-1074(ra) # 8000027c <consputc>
  consputc('x');
    800006b6:	07800513          	li	a0,120
    800006ba:	00000097          	auipc	ra,0x0
    800006be:	bc2080e7          	jalr	-1086(ra) # 8000027c <consputc>
    800006c2:	84ea                	mv	s1,s10
    consputc(digits[x >> (sizeof(uint64) * 8 - 4)]);
    800006c4:	03c95793          	srli	a5,s2,0x3c
    800006c8:	97da                	add	a5,a5,s6
    800006ca:	0007c503          	lbu	a0,0(a5)
    800006ce:	00000097          	auipc	ra,0x0
    800006d2:	bae080e7          	jalr	-1106(ra) # 8000027c <consputc>
  for (i = 0; i < (sizeof(uint64) * 2); i++, x <<= 4)
    800006d6:	0912                	slli	s2,s2,0x4
    800006d8:	34fd                	addiw	s1,s1,-1
    800006da:	f4ed                	bnez	s1,800006c4 <printf+0x13a>
    800006dc:	b7a1                	j	80000624 <printf+0x9a>
      if((s = va_arg(ap, char*)) == 0)
    800006de:	f8843783          	ld	a5,-120(s0)
    800006e2:	00878713          	addi	a4,a5,8
    800006e6:	f8e43423          	sd	a4,-120(s0)
    800006ea:	6384                	ld	s1,0(a5)
    800006ec:	cc89                	beqz	s1,80000706 <printf+0x17c>
      for(; *s; s++)
    800006ee:	0004c503          	lbu	a0,0(s1)
    800006f2:	d90d                	beqz	a0,80000624 <printf+0x9a>
        consputc(*s);
    800006f4:	00000097          	auipc	ra,0x0
    800006f8:	b88080e7          	jalr	-1144(ra) # 8000027c <consputc>
      for(; *s; s++)
    800006fc:	0485                	addi	s1,s1,1
    800006fe:	0004c503          	lbu	a0,0(s1)
    80000702:	f96d                	bnez	a0,800006f4 <printf+0x16a>
    80000704:	b705                	j	80000624 <printf+0x9a>
        s = "(null)";
    80000706:	00008497          	auipc	s1,0x8
    8000070a:	91a48493          	addi	s1,s1,-1766 # 80008020 <etext+0x20>
      for(; *s; s++)
    8000070e:	02800513          	li	a0,40
    80000712:	b7cd                	j	800006f4 <printf+0x16a>
      consputc('%');
    80000714:	8556                	mv	a0,s5
    80000716:	00000097          	auipc	ra,0x0
    8000071a:	b66080e7          	jalr	-1178(ra) # 8000027c <consputc>
      break;
    8000071e:	b719                	j	80000624 <printf+0x9a>
      consputc('%');
    80000720:	8556                	mv	a0,s5
    80000722:	00000097          	auipc	ra,0x0
    80000726:	b5a080e7          	jalr	-1190(ra) # 8000027c <consputc>
      consputc(c);
    8000072a:	8526                	mv	a0,s1
    8000072c:	00000097          	auipc	ra,0x0
    80000730:	b50080e7          	jalr	-1200(ra) # 8000027c <consputc>
      break;
    80000734:	bdc5                	j	80000624 <printf+0x9a>
  if(locking)
    80000736:	020d9163          	bnez	s11,80000758 <printf+0x1ce>
}
    8000073a:	70e6                	ld	ra,120(sp)
    8000073c:	7446                	ld	s0,112(sp)
    8000073e:	74a6                	ld	s1,104(sp)
    80000740:	7906                	ld	s2,96(sp)
    80000742:	69e6                	ld	s3,88(sp)
    80000744:	6a46                	ld	s4,80(sp)
    80000746:	6aa6                	ld	s5,72(sp)
    80000748:	6b06                	ld	s6,64(sp)
    8000074a:	7be2                	ld	s7,56(sp)
    8000074c:	7c42                	ld	s8,48(sp)
    8000074e:	7ca2                	ld	s9,40(sp)
    80000750:	7d02                	ld	s10,32(sp)
    80000752:	6de2                	ld	s11,24(sp)
    80000754:	6129                	addi	sp,sp,192
    80000756:	8082                	ret
    release(&pr.lock);
    80000758:	00010517          	auipc	a0,0x10
    8000075c:	40050513          	addi	a0,a0,1024 # 80010b58 <pr>
    80000760:	00000097          	auipc	ra,0x0
    80000764:	52a080e7          	jalr	1322(ra) # 80000c8a <release>
}
    80000768:	bfc9                	j	8000073a <printf+0x1b0>

000000008000076a <printfinit>:
    ;
}

void
printfinit(void)
{
    8000076a:	1101                	addi	sp,sp,-32
    8000076c:	ec06                	sd	ra,24(sp)
    8000076e:	e822                	sd	s0,16(sp)
    80000770:	e426                	sd	s1,8(sp)
    80000772:	1000                	addi	s0,sp,32
  initlock(&pr.lock, "pr");
    80000774:	00010497          	auipc	s1,0x10
    80000778:	3e448493          	addi	s1,s1,996 # 80010b58 <pr>
    8000077c:	00008597          	auipc	a1,0x8
    80000780:	8bc58593          	addi	a1,a1,-1860 # 80008038 <etext+0x38>
    80000784:	8526                	mv	a0,s1
    80000786:	00000097          	auipc	ra,0x0
    8000078a:	3c0080e7          	jalr	960(ra) # 80000b46 <initlock>
  pr.locking = 1;
    8000078e:	4785                	li	a5,1
    80000790:	cc9c                	sw	a5,24(s1)
}
    80000792:	60e2                	ld	ra,24(sp)
    80000794:	6442                	ld	s0,16(sp)
    80000796:	64a2                	ld	s1,8(sp)
    80000798:	6105                	addi	sp,sp,32
    8000079a:	8082                	ret

000000008000079c <uartinit>:

void uartstart();

void
uartinit(void)
{
    8000079c:	1141                	addi	sp,sp,-16
    8000079e:	e406                	sd	ra,8(sp)
    800007a0:	e022                	sd	s0,0(sp)
    800007a2:	0800                	addi	s0,sp,16
  // disable interrupts.
  WriteReg(IER, 0x00);
    800007a4:	100007b7          	lui	a5,0x10000
    800007a8:	000780a3          	sb	zero,1(a5) # 10000001 <_entry-0x6fffffff>

  // special mode to set baud rate.
  WriteReg(LCR, LCR_BAUD_LATCH);
    800007ac:	f8000713          	li	a4,-128
    800007b0:	00e781a3          	sb	a4,3(a5)

  // LSB for baud rate of 38.4K.
  WriteReg(0, 0x03);
    800007b4:	470d                	li	a4,3
    800007b6:	00e78023          	sb	a4,0(a5)

  // MSB for baud rate of 38.4K.
  WriteReg(1, 0x00);
    800007ba:	000780a3          	sb	zero,1(a5)

  // leave set-baud mode,
  // and set word length to 8 bits, no parity.
  WriteReg(LCR, LCR_EIGHT_BITS);
    800007be:	00e781a3          	sb	a4,3(a5)

  // reset and enable FIFOs.
  WriteReg(FCR, FCR_FIFO_ENABLE | FCR_FIFO_CLEAR);
    800007c2:	469d                	li	a3,7
    800007c4:	00d78123          	sb	a3,2(a5)

  // enable transmit and receive interrupts.
  WriteReg(IER, IER_TX_ENABLE | IER_RX_ENABLE);
    800007c8:	00e780a3          	sb	a4,1(a5)

  initlock(&uart_tx_lock, "uart");
    800007cc:	00008597          	auipc	a1,0x8
    800007d0:	88c58593          	addi	a1,a1,-1908 # 80008058 <digits+0x18>
    800007d4:	00010517          	auipc	a0,0x10
    800007d8:	3a450513          	addi	a0,a0,932 # 80010b78 <uart_tx_lock>
    800007dc:	00000097          	auipc	ra,0x0
    800007e0:	36a080e7          	jalr	874(ra) # 80000b46 <initlock>
}
    800007e4:	60a2                	ld	ra,8(sp)
    800007e6:	6402                	ld	s0,0(sp)
    800007e8:	0141                	addi	sp,sp,16
    800007ea:	8082                	ret

00000000800007ec <uartputc_sync>:
// use interrupts, for use by kernel printf() and
// to echo characters. it spins waiting for the uart's
// output register to be empty.
void
uartputc_sync(int c)
{
    800007ec:	1101                	addi	sp,sp,-32
    800007ee:	ec06                	sd	ra,24(sp)
    800007f0:	e822                	sd	s0,16(sp)
    800007f2:	e426                	sd	s1,8(sp)
    800007f4:	1000                	addi	s0,sp,32
    800007f6:	84aa                	mv	s1,a0
  push_off();
    800007f8:	00000097          	auipc	ra,0x0
    800007fc:	392080e7          	jalr	914(ra) # 80000b8a <push_off>

  if(panicked){
    80000800:	00008797          	auipc	a5,0x8
    80000804:	1307a783          	lw	a5,304(a5) # 80008930 <panicked>
    for(;;)
      ;
  }

  // wait for Transmit Holding Empty to be set in LSR.
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000808:	10000737          	lui	a4,0x10000
  if(panicked){
    8000080c:	c391                	beqz	a5,80000810 <uartputc_sync+0x24>
    for(;;)
    8000080e:	a001                	j	8000080e <uartputc_sync+0x22>
  while((ReadReg(LSR) & LSR_TX_IDLE) == 0)
    80000810:	00574783          	lbu	a5,5(a4) # 10000005 <_entry-0x6ffffffb>
    80000814:	0207f793          	andi	a5,a5,32
    80000818:	dfe5                	beqz	a5,80000810 <uartputc_sync+0x24>
    ;
  WriteReg(THR, c);
    8000081a:	0ff4f513          	zext.b	a0,s1
    8000081e:	100007b7          	lui	a5,0x10000
    80000822:	00a78023          	sb	a0,0(a5) # 10000000 <_entry-0x70000000>

  pop_off();
    80000826:	00000097          	auipc	ra,0x0
    8000082a:	404080e7          	jalr	1028(ra) # 80000c2a <pop_off>
}
    8000082e:	60e2                	ld	ra,24(sp)
    80000830:	6442                	ld	s0,16(sp)
    80000832:	64a2                	ld	s1,8(sp)
    80000834:	6105                	addi	sp,sp,32
    80000836:	8082                	ret

0000000080000838 <uartstart>:
// called from both the top- and bottom-half.
void
uartstart()
{
  while(1){
    if(uart_tx_w == uart_tx_r){
    80000838:	00008797          	auipc	a5,0x8
    8000083c:	1007b783          	ld	a5,256(a5) # 80008938 <uart_tx_r>
    80000840:	00008717          	auipc	a4,0x8
    80000844:	10073703          	ld	a4,256(a4) # 80008940 <uart_tx_w>
    80000848:	06f70a63          	beq	a4,a5,800008bc <uartstart+0x84>
{
    8000084c:	7139                	addi	sp,sp,-64
    8000084e:	fc06                	sd	ra,56(sp)
    80000850:	f822                	sd	s0,48(sp)
    80000852:	f426                	sd	s1,40(sp)
    80000854:	f04a                	sd	s2,32(sp)
    80000856:	ec4e                	sd	s3,24(sp)
    80000858:	e852                	sd	s4,16(sp)
    8000085a:	e456                	sd	s5,8(sp)
    8000085c:	0080                	addi	s0,sp,64
      // transmit buffer is empty.
      return;
    }
    
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000085e:	10000937          	lui	s2,0x10000
      // so we cannot give it another byte.
      // it will interrupt when it's ready for a new byte.
      return;
    }
    
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000862:	00010a17          	auipc	s4,0x10
    80000866:	316a0a13          	addi	s4,s4,790 # 80010b78 <uart_tx_lock>
    uart_tx_r += 1;
    8000086a:	00008497          	auipc	s1,0x8
    8000086e:	0ce48493          	addi	s1,s1,206 # 80008938 <uart_tx_r>
    if(uart_tx_w == uart_tx_r){
    80000872:	00008997          	auipc	s3,0x8
    80000876:	0ce98993          	addi	s3,s3,206 # 80008940 <uart_tx_w>
    if((ReadReg(LSR) & LSR_TX_IDLE) == 0){
    8000087a:	00594703          	lbu	a4,5(s2) # 10000005 <_entry-0x6ffffffb>
    8000087e:	02077713          	andi	a4,a4,32
    80000882:	c705                	beqz	a4,800008aa <uartstart+0x72>
    int c = uart_tx_buf[uart_tx_r % UART_TX_BUF_SIZE];
    80000884:	01f7f713          	andi	a4,a5,31
    80000888:	9752                	add	a4,a4,s4
    8000088a:	01874a83          	lbu	s5,24(a4)
    uart_tx_r += 1;
    8000088e:	0785                	addi	a5,a5,1
    80000890:	e09c                	sd	a5,0(s1)
    
    // maybe uartputc() is waiting for space in the buffer.
    wakeup(&uart_tx_r);
    80000892:	8526                	mv	a0,s1
    80000894:	00002097          	auipc	ra,0x2
    80000898:	972080e7          	jalr	-1678(ra) # 80002206 <wakeup>
    
    WriteReg(THR, c);
    8000089c:	01590023          	sb	s5,0(s2)
    if(uart_tx_w == uart_tx_r){
    800008a0:	609c                	ld	a5,0(s1)
    800008a2:	0009b703          	ld	a4,0(s3)
    800008a6:	fcf71ae3          	bne	a4,a5,8000087a <uartstart+0x42>
  }
}
    800008aa:	70e2                	ld	ra,56(sp)
    800008ac:	7442                	ld	s0,48(sp)
    800008ae:	74a2                	ld	s1,40(sp)
    800008b0:	7902                	ld	s2,32(sp)
    800008b2:	69e2                	ld	s3,24(sp)
    800008b4:	6a42                	ld	s4,16(sp)
    800008b6:	6aa2                	ld	s5,8(sp)
    800008b8:	6121                	addi	sp,sp,64
    800008ba:	8082                	ret
    800008bc:	8082                	ret

00000000800008be <uartputc>:
{
    800008be:	7179                	addi	sp,sp,-48
    800008c0:	f406                	sd	ra,40(sp)
    800008c2:	f022                	sd	s0,32(sp)
    800008c4:	ec26                	sd	s1,24(sp)
    800008c6:	e84a                	sd	s2,16(sp)
    800008c8:	e44e                	sd	s3,8(sp)
    800008ca:	e052                	sd	s4,0(sp)
    800008cc:	1800                	addi	s0,sp,48
    800008ce:	8a2a                	mv	s4,a0
  acquire(&uart_tx_lock);
    800008d0:	00010517          	auipc	a0,0x10
    800008d4:	2a850513          	addi	a0,a0,680 # 80010b78 <uart_tx_lock>
    800008d8:	00000097          	auipc	ra,0x0
    800008dc:	2fe080e7          	jalr	766(ra) # 80000bd6 <acquire>
  if(panicked){
    800008e0:	00008797          	auipc	a5,0x8
    800008e4:	0507a783          	lw	a5,80(a5) # 80008930 <panicked>
    800008e8:	e7c9                	bnez	a5,80000972 <uartputc+0xb4>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    800008ea:	00008717          	auipc	a4,0x8
    800008ee:	05673703          	ld	a4,86(a4) # 80008940 <uart_tx_w>
    800008f2:	00008797          	auipc	a5,0x8
    800008f6:	0467b783          	ld	a5,70(a5) # 80008938 <uart_tx_r>
    800008fa:	02078793          	addi	a5,a5,32
    sleep(&uart_tx_r, &uart_tx_lock);
    800008fe:	00010997          	auipc	s3,0x10
    80000902:	27a98993          	addi	s3,s3,634 # 80010b78 <uart_tx_lock>
    80000906:	00008497          	auipc	s1,0x8
    8000090a:	03248493          	addi	s1,s1,50 # 80008938 <uart_tx_r>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    8000090e:	00008917          	auipc	s2,0x8
    80000912:	03290913          	addi	s2,s2,50 # 80008940 <uart_tx_w>
    80000916:	00e79f63          	bne	a5,a4,80000934 <uartputc+0x76>
    sleep(&uart_tx_r, &uart_tx_lock);
    8000091a:	85ce                	mv	a1,s3
    8000091c:	8526                	mv	a0,s1
    8000091e:	00002097          	auipc	ra,0x2
    80000922:	884080e7          	jalr	-1916(ra) # 800021a2 <sleep>
  while(uart_tx_w == uart_tx_r + UART_TX_BUF_SIZE){
    80000926:	00093703          	ld	a4,0(s2)
    8000092a:	609c                	ld	a5,0(s1)
    8000092c:	02078793          	addi	a5,a5,32
    80000930:	fee785e3          	beq	a5,a4,8000091a <uartputc+0x5c>
  uart_tx_buf[uart_tx_w % UART_TX_BUF_SIZE] = c;
    80000934:	00010497          	auipc	s1,0x10
    80000938:	24448493          	addi	s1,s1,580 # 80010b78 <uart_tx_lock>
    8000093c:	01f77793          	andi	a5,a4,31
    80000940:	97a6                	add	a5,a5,s1
    80000942:	01478c23          	sb	s4,24(a5)
  uart_tx_w += 1;
    80000946:	0705                	addi	a4,a4,1
    80000948:	00008797          	auipc	a5,0x8
    8000094c:	fee7bc23          	sd	a4,-8(a5) # 80008940 <uart_tx_w>
  uartstart();
    80000950:	00000097          	auipc	ra,0x0
    80000954:	ee8080e7          	jalr	-280(ra) # 80000838 <uartstart>
  release(&uart_tx_lock);
    80000958:	8526                	mv	a0,s1
    8000095a:	00000097          	auipc	ra,0x0
    8000095e:	330080e7          	jalr	816(ra) # 80000c8a <release>
}
    80000962:	70a2                	ld	ra,40(sp)
    80000964:	7402                	ld	s0,32(sp)
    80000966:	64e2                	ld	s1,24(sp)
    80000968:	6942                	ld	s2,16(sp)
    8000096a:	69a2                	ld	s3,8(sp)
    8000096c:	6a02                	ld	s4,0(sp)
    8000096e:	6145                	addi	sp,sp,48
    80000970:	8082                	ret
    for(;;)
    80000972:	a001                	j	80000972 <uartputc+0xb4>

0000000080000974 <uartgetc>:

// read one input character from the UART.
// return -1 if none is waiting.
int
uartgetc(void)
{
    80000974:	1141                	addi	sp,sp,-16
    80000976:	e422                	sd	s0,8(sp)
    80000978:	0800                	addi	s0,sp,16
  if(ReadReg(LSR) & 0x01){
    8000097a:	100007b7          	lui	a5,0x10000
    8000097e:	0057c783          	lbu	a5,5(a5) # 10000005 <_entry-0x6ffffffb>
    80000982:	8b85                	andi	a5,a5,1
    80000984:	cb81                	beqz	a5,80000994 <uartgetc+0x20>
    // input data is ready.
    return ReadReg(RHR);
    80000986:	100007b7          	lui	a5,0x10000
    8000098a:	0007c503          	lbu	a0,0(a5) # 10000000 <_entry-0x70000000>
  } else {
    return -1;
  }
}
    8000098e:	6422                	ld	s0,8(sp)
    80000990:	0141                	addi	sp,sp,16
    80000992:	8082                	ret
    return -1;
    80000994:	557d                	li	a0,-1
    80000996:	bfe5                	j	8000098e <uartgetc+0x1a>

0000000080000998 <uartintr>:
// handle a uart interrupt, raised because input has
// arrived, or the uart is ready for more output, or
// both. called from devintr().
void
uartintr(void)
{
    80000998:	1101                	addi	sp,sp,-32
    8000099a:	ec06                	sd	ra,24(sp)
    8000099c:	e822                	sd	s0,16(sp)
    8000099e:	e426                	sd	s1,8(sp)
    800009a0:	1000                	addi	s0,sp,32
  // read and process incoming characters.
  while(1){
    int c = uartgetc();
    if(c == -1)
    800009a2:	54fd                	li	s1,-1
    800009a4:	a029                	j	800009ae <uartintr+0x16>
      break;
    consoleintr(c);
    800009a6:	00000097          	auipc	ra,0x0
    800009aa:	918080e7          	jalr	-1768(ra) # 800002be <consoleintr>
    int c = uartgetc();
    800009ae:	00000097          	auipc	ra,0x0
    800009b2:	fc6080e7          	jalr	-58(ra) # 80000974 <uartgetc>
    if(c == -1)
    800009b6:	fe9518e3          	bne	a0,s1,800009a6 <uartintr+0xe>
  }

  // send buffered characters.
  acquire(&uart_tx_lock);
    800009ba:	00010497          	auipc	s1,0x10
    800009be:	1be48493          	addi	s1,s1,446 # 80010b78 <uart_tx_lock>
    800009c2:	8526                	mv	a0,s1
    800009c4:	00000097          	auipc	ra,0x0
    800009c8:	212080e7          	jalr	530(ra) # 80000bd6 <acquire>
  uartstart();
    800009cc:	00000097          	auipc	ra,0x0
    800009d0:	e6c080e7          	jalr	-404(ra) # 80000838 <uartstart>
  release(&uart_tx_lock);
    800009d4:	8526                	mv	a0,s1
    800009d6:	00000097          	auipc	ra,0x0
    800009da:	2b4080e7          	jalr	692(ra) # 80000c8a <release>
}
    800009de:	60e2                	ld	ra,24(sp)
    800009e0:	6442                	ld	s0,16(sp)
    800009e2:	64a2                	ld	s1,8(sp)
    800009e4:	6105                	addi	sp,sp,32
    800009e6:	8082                	ret

00000000800009e8 <kfree>:
// which normally should have been returned by a
// call to kalloc().  (The exception is when
// initializing the allocator; see kinit above.)
void
kfree(void *pa)
{
    800009e8:	1101                	addi	sp,sp,-32
    800009ea:	ec06                	sd	ra,24(sp)
    800009ec:	e822                	sd	s0,16(sp)
    800009ee:	e426                	sd	s1,8(sp)
    800009f0:	e04a                	sd	s2,0(sp)
    800009f2:	1000                	addi	s0,sp,32
  struct run *r;

  if(((uint64)pa % PGSIZE) != 0 || (char*)pa < end || (uint64)pa >= PHYSTOP)
    800009f4:	03451793          	slli	a5,a0,0x34
    800009f8:	ebb9                	bnez	a5,80000a4e <kfree+0x66>
    800009fa:	84aa                	mv	s1,a0
    800009fc:	00021797          	auipc	a5,0x21
    80000a00:	3e478793          	addi	a5,a5,996 # 80021de0 <end>
    80000a04:	04f56563          	bltu	a0,a5,80000a4e <kfree+0x66>
    80000a08:	47c5                	li	a5,17
    80000a0a:	07ee                	slli	a5,a5,0x1b
    80000a0c:	04f57163          	bgeu	a0,a5,80000a4e <kfree+0x66>
    panic("kfree");

  // Fill with junk to catch dangling refs.
  memset(pa, 1, PGSIZE);
    80000a10:	6605                	lui	a2,0x1
    80000a12:	4585                	li	a1,1
    80000a14:	00000097          	auipc	ra,0x0
    80000a18:	2be080e7          	jalr	702(ra) # 80000cd2 <memset>

  r = (struct run*)pa;

  acquire(&kmem.lock);
    80000a1c:	00010917          	auipc	s2,0x10
    80000a20:	19490913          	addi	s2,s2,404 # 80010bb0 <kmem>
    80000a24:	854a                	mv	a0,s2
    80000a26:	00000097          	auipc	ra,0x0
    80000a2a:	1b0080e7          	jalr	432(ra) # 80000bd6 <acquire>
  r->next = kmem.freelist;
    80000a2e:	01893783          	ld	a5,24(s2)
    80000a32:	e09c                	sd	a5,0(s1)
  kmem.freelist = r;
    80000a34:	00993c23          	sd	s1,24(s2)
  release(&kmem.lock);
    80000a38:	854a                	mv	a0,s2
    80000a3a:	00000097          	auipc	ra,0x0
    80000a3e:	250080e7          	jalr	592(ra) # 80000c8a <release>
}
    80000a42:	60e2                	ld	ra,24(sp)
    80000a44:	6442                	ld	s0,16(sp)
    80000a46:	64a2                	ld	s1,8(sp)
    80000a48:	6902                	ld	s2,0(sp)
    80000a4a:	6105                	addi	sp,sp,32
    80000a4c:	8082                	ret
    panic("kfree");
    80000a4e:	00007517          	auipc	a0,0x7
    80000a52:	61250513          	addi	a0,a0,1554 # 80008060 <digits+0x20>
    80000a56:	00000097          	auipc	ra,0x0
    80000a5a:	aea080e7          	jalr	-1302(ra) # 80000540 <panic>

0000000080000a5e <freerange>:
{
    80000a5e:	7179                	addi	sp,sp,-48
    80000a60:	f406                	sd	ra,40(sp)
    80000a62:	f022                	sd	s0,32(sp)
    80000a64:	ec26                	sd	s1,24(sp)
    80000a66:	e84a                	sd	s2,16(sp)
    80000a68:	e44e                	sd	s3,8(sp)
    80000a6a:	e052                	sd	s4,0(sp)
    80000a6c:	1800                	addi	s0,sp,48
  p = (char*)PGROUNDUP((uint64)pa_start);
    80000a6e:	6785                	lui	a5,0x1
    80000a70:	fff78713          	addi	a4,a5,-1 # fff <_entry-0x7ffff001>
    80000a74:	00e504b3          	add	s1,a0,a4
    80000a78:	777d                	lui	a4,0xfffff
    80000a7a:	8cf9                	and	s1,s1,a4
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a7c:	94be                	add	s1,s1,a5
    80000a7e:	0095ee63          	bltu	a1,s1,80000a9a <freerange+0x3c>
    80000a82:	892e                	mv	s2,a1
    kfree(p);
    80000a84:	7a7d                	lui	s4,0xfffff
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a86:	6985                	lui	s3,0x1
    kfree(p);
    80000a88:	01448533          	add	a0,s1,s4
    80000a8c:	00000097          	auipc	ra,0x0
    80000a90:	f5c080e7          	jalr	-164(ra) # 800009e8 <kfree>
  for(; p + PGSIZE <= (char*)pa_end; p += PGSIZE)
    80000a94:	94ce                	add	s1,s1,s3
    80000a96:	fe9979e3          	bgeu	s2,s1,80000a88 <freerange+0x2a>
}
    80000a9a:	70a2                	ld	ra,40(sp)
    80000a9c:	7402                	ld	s0,32(sp)
    80000a9e:	64e2                	ld	s1,24(sp)
    80000aa0:	6942                	ld	s2,16(sp)
    80000aa2:	69a2                	ld	s3,8(sp)
    80000aa4:	6a02                	ld	s4,0(sp)
    80000aa6:	6145                	addi	sp,sp,48
    80000aa8:	8082                	ret

0000000080000aaa <kinit>:
{
    80000aaa:	1141                	addi	sp,sp,-16
    80000aac:	e406                	sd	ra,8(sp)
    80000aae:	e022                	sd	s0,0(sp)
    80000ab0:	0800                	addi	s0,sp,16
  initlock(&kmem.lock, "kmem");
    80000ab2:	00007597          	auipc	a1,0x7
    80000ab6:	5b658593          	addi	a1,a1,1462 # 80008068 <digits+0x28>
    80000aba:	00010517          	auipc	a0,0x10
    80000abe:	0f650513          	addi	a0,a0,246 # 80010bb0 <kmem>
    80000ac2:	00000097          	auipc	ra,0x0
    80000ac6:	084080e7          	jalr	132(ra) # 80000b46 <initlock>
  freerange(end, (void*)PHYSTOP);
    80000aca:	45c5                	li	a1,17
    80000acc:	05ee                	slli	a1,a1,0x1b
    80000ace:	00021517          	auipc	a0,0x21
    80000ad2:	31250513          	addi	a0,a0,786 # 80021de0 <end>
    80000ad6:	00000097          	auipc	ra,0x0
    80000ada:	f88080e7          	jalr	-120(ra) # 80000a5e <freerange>
}
    80000ade:	60a2                	ld	ra,8(sp)
    80000ae0:	6402                	ld	s0,0(sp)
    80000ae2:	0141                	addi	sp,sp,16
    80000ae4:	8082                	ret

0000000080000ae6 <kalloc>:
// Allocate one 4096-byte page of physical memory.
// Returns a pointer that the kernel can use.
// Returns 0 if the memory cannot be allocated.
void *
kalloc(void)
{
    80000ae6:	1101                	addi	sp,sp,-32
    80000ae8:	ec06                	sd	ra,24(sp)
    80000aea:	e822                	sd	s0,16(sp)
    80000aec:	e426                	sd	s1,8(sp)
    80000aee:	1000                	addi	s0,sp,32
  struct run *r;

  acquire(&kmem.lock);
    80000af0:	00010497          	auipc	s1,0x10
    80000af4:	0c048493          	addi	s1,s1,192 # 80010bb0 <kmem>
    80000af8:	8526                	mv	a0,s1
    80000afa:	00000097          	auipc	ra,0x0
    80000afe:	0dc080e7          	jalr	220(ra) # 80000bd6 <acquire>
  r = kmem.freelist;
    80000b02:	6c84                	ld	s1,24(s1)
  if(r)
    80000b04:	c885                	beqz	s1,80000b34 <kalloc+0x4e>
    kmem.freelist = r->next;
    80000b06:	609c                	ld	a5,0(s1)
    80000b08:	00010517          	auipc	a0,0x10
    80000b0c:	0a850513          	addi	a0,a0,168 # 80010bb0 <kmem>
    80000b10:	ed1c                	sd	a5,24(a0)
  release(&kmem.lock);
    80000b12:	00000097          	auipc	ra,0x0
    80000b16:	178080e7          	jalr	376(ra) # 80000c8a <release>

  if(r)
    memset((char*)r, 5, PGSIZE); // fill with junk
    80000b1a:	6605                	lui	a2,0x1
    80000b1c:	4595                	li	a1,5
    80000b1e:	8526                	mv	a0,s1
    80000b20:	00000097          	auipc	ra,0x0
    80000b24:	1b2080e7          	jalr	434(ra) # 80000cd2 <memset>
  return (void*)r;
}
    80000b28:	8526                	mv	a0,s1
    80000b2a:	60e2                	ld	ra,24(sp)
    80000b2c:	6442                	ld	s0,16(sp)
    80000b2e:	64a2                	ld	s1,8(sp)
    80000b30:	6105                	addi	sp,sp,32
    80000b32:	8082                	ret
  release(&kmem.lock);
    80000b34:	00010517          	auipc	a0,0x10
    80000b38:	07c50513          	addi	a0,a0,124 # 80010bb0 <kmem>
    80000b3c:	00000097          	auipc	ra,0x0
    80000b40:	14e080e7          	jalr	334(ra) # 80000c8a <release>
  if(r)
    80000b44:	b7d5                	j	80000b28 <kalloc+0x42>

0000000080000b46 <initlock>:
#include "proc.h"
#include "defs.h"

void
initlock(struct spinlock *lk, char *name)
{
    80000b46:	1141                	addi	sp,sp,-16
    80000b48:	e422                	sd	s0,8(sp)
    80000b4a:	0800                	addi	s0,sp,16
  lk->name = name;
    80000b4c:	e50c                	sd	a1,8(a0)
  lk->locked = 0;
    80000b4e:	00052023          	sw	zero,0(a0)
  lk->cpu = 0;
    80000b52:	00053823          	sd	zero,16(a0)
}
    80000b56:	6422                	ld	s0,8(sp)
    80000b58:	0141                	addi	sp,sp,16
    80000b5a:	8082                	ret

0000000080000b5c <holding>:
// Interrupts must be off.
int
holding(struct spinlock *lk)
{
  int r;
  r = (lk->locked && lk->cpu == mycpu());
    80000b5c:	411c                	lw	a5,0(a0)
    80000b5e:	e399                	bnez	a5,80000b64 <holding+0x8>
    80000b60:	4501                	li	a0,0
  return r;
}
    80000b62:	8082                	ret
{
    80000b64:	1101                	addi	sp,sp,-32
    80000b66:	ec06                	sd	ra,24(sp)
    80000b68:	e822                	sd	s0,16(sp)
    80000b6a:	e426                	sd	s1,8(sp)
    80000b6c:	1000                	addi	s0,sp,32
  r = (lk->locked && lk->cpu == mycpu());
    80000b6e:	6904                	ld	s1,16(a0)
    80000b70:	00001097          	auipc	ra,0x1
    80000b74:	f6e080e7          	jalr	-146(ra) # 80001ade <mycpu>
    80000b78:	40a48533          	sub	a0,s1,a0
    80000b7c:	00153513          	seqz	a0,a0
}
    80000b80:	60e2                	ld	ra,24(sp)
    80000b82:	6442                	ld	s0,16(sp)
    80000b84:	64a2                	ld	s1,8(sp)
    80000b86:	6105                	addi	sp,sp,32
    80000b88:	8082                	ret

0000000080000b8a <push_off>:
// it takes two pop_off()s to undo two push_off()s.  Also, if interrupts
// are initially off, then push_off, pop_off leaves them off.

void
push_off(void)
{
    80000b8a:	1101                	addi	sp,sp,-32
    80000b8c:	ec06                	sd	ra,24(sp)
    80000b8e:	e822                	sd	s0,16(sp)
    80000b90:	e426                	sd	s1,8(sp)
    80000b92:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000b94:	100024f3          	csrr	s1,sstatus
    80000b98:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    80000b9c:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000b9e:	10079073          	csrw	sstatus,a5
  int old = intr_get();

  intr_off();
  if(mycpu()->noff == 0)
    80000ba2:	00001097          	auipc	ra,0x1
    80000ba6:	f3c080e7          	jalr	-196(ra) # 80001ade <mycpu>
    80000baa:	5d3c                	lw	a5,120(a0)
    80000bac:	cf89                	beqz	a5,80000bc6 <push_off+0x3c>
    mycpu()->intena = old;
  mycpu()->noff += 1;
    80000bae:	00001097          	auipc	ra,0x1
    80000bb2:	f30080e7          	jalr	-208(ra) # 80001ade <mycpu>
    80000bb6:	5d3c                	lw	a5,120(a0)
    80000bb8:	2785                	addiw	a5,a5,1
    80000bba:	dd3c                	sw	a5,120(a0)
}
    80000bbc:	60e2                	ld	ra,24(sp)
    80000bbe:	6442                	ld	s0,16(sp)
    80000bc0:	64a2                	ld	s1,8(sp)
    80000bc2:	6105                	addi	sp,sp,32
    80000bc4:	8082                	ret
    mycpu()->intena = old;
    80000bc6:	00001097          	auipc	ra,0x1
    80000bca:	f18080e7          	jalr	-232(ra) # 80001ade <mycpu>
  return (x & SSTATUS_SIE) != 0;
    80000bce:	8085                	srli	s1,s1,0x1
    80000bd0:	8885                	andi	s1,s1,1
    80000bd2:	dd64                	sw	s1,124(a0)
    80000bd4:	bfe9                	j	80000bae <push_off+0x24>

0000000080000bd6 <acquire>:
{
    80000bd6:	1101                	addi	sp,sp,-32
    80000bd8:	ec06                	sd	ra,24(sp)
    80000bda:	e822                	sd	s0,16(sp)
    80000bdc:	e426                	sd	s1,8(sp)
    80000bde:	1000                	addi	s0,sp,32
    80000be0:	84aa                	mv	s1,a0
  push_off(); // disable interrupts to avoid deadlock.
    80000be2:	00000097          	auipc	ra,0x0
    80000be6:	fa8080e7          	jalr	-88(ra) # 80000b8a <push_off>
  if(holding(lk))
    80000bea:	8526                	mv	a0,s1
    80000bec:	00000097          	auipc	ra,0x0
    80000bf0:	f70080e7          	jalr	-144(ra) # 80000b5c <holding>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf4:	4705                	li	a4,1
  if(holding(lk))
    80000bf6:	e115                	bnez	a0,80000c1a <acquire+0x44>
  while(__sync_lock_test_and_set(&lk->locked, 1) != 0)
    80000bf8:	87ba                	mv	a5,a4
    80000bfa:	0cf4a7af          	amoswap.w.aq	a5,a5,(s1)
    80000bfe:	2781                	sext.w	a5,a5
    80000c00:	ffe5                	bnez	a5,80000bf8 <acquire+0x22>
  __sync_synchronize();
    80000c02:	0ff0000f          	fence
  lk->cpu = mycpu();
    80000c06:	00001097          	auipc	ra,0x1
    80000c0a:	ed8080e7          	jalr	-296(ra) # 80001ade <mycpu>
    80000c0e:	e888                	sd	a0,16(s1)
}
    80000c10:	60e2                	ld	ra,24(sp)
    80000c12:	6442                	ld	s0,16(sp)
    80000c14:	64a2                	ld	s1,8(sp)
    80000c16:	6105                	addi	sp,sp,32
    80000c18:	8082                	ret
    panic("acquire");
    80000c1a:	00007517          	auipc	a0,0x7
    80000c1e:	45650513          	addi	a0,a0,1110 # 80008070 <digits+0x30>
    80000c22:	00000097          	auipc	ra,0x0
    80000c26:	91e080e7          	jalr	-1762(ra) # 80000540 <panic>

0000000080000c2a <pop_off>:

void
pop_off(void)
{
    80000c2a:	1141                	addi	sp,sp,-16
    80000c2c:	e406                	sd	ra,8(sp)
    80000c2e:	e022                	sd	s0,0(sp)
    80000c30:	0800                	addi	s0,sp,16
  struct cpu *c = mycpu();
    80000c32:	00001097          	auipc	ra,0x1
    80000c36:	eac080e7          	jalr	-340(ra) # 80001ade <mycpu>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c3a:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80000c3e:	8b89                	andi	a5,a5,2
  if(intr_get())
    80000c40:	e78d                	bnez	a5,80000c6a <pop_off+0x40>
    panic("pop_off - interruptible");
  if(c->noff < 1)
    80000c42:	5d3c                	lw	a5,120(a0)
    80000c44:	02f05b63          	blez	a5,80000c7a <pop_off+0x50>
    panic("pop_off");
  c->noff -= 1;
    80000c48:	37fd                	addiw	a5,a5,-1
    80000c4a:	0007871b          	sext.w	a4,a5
    80000c4e:	dd3c                	sw	a5,120(a0)
  if(c->noff == 0 && c->intena)
    80000c50:	eb09                	bnez	a4,80000c62 <pop_off+0x38>
    80000c52:	5d7c                	lw	a5,124(a0)
    80000c54:	c799                	beqz	a5,80000c62 <pop_off+0x38>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80000c56:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80000c5a:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80000c5e:	10079073          	csrw	sstatus,a5
    intr_on();
}
    80000c62:	60a2                	ld	ra,8(sp)
    80000c64:	6402                	ld	s0,0(sp)
    80000c66:	0141                	addi	sp,sp,16
    80000c68:	8082                	ret
    panic("pop_off - interruptible");
    80000c6a:	00007517          	auipc	a0,0x7
    80000c6e:	40e50513          	addi	a0,a0,1038 # 80008078 <digits+0x38>
    80000c72:	00000097          	auipc	ra,0x0
    80000c76:	8ce080e7          	jalr	-1842(ra) # 80000540 <panic>
    panic("pop_off");
    80000c7a:	00007517          	auipc	a0,0x7
    80000c7e:	41650513          	addi	a0,a0,1046 # 80008090 <digits+0x50>
    80000c82:	00000097          	auipc	ra,0x0
    80000c86:	8be080e7          	jalr	-1858(ra) # 80000540 <panic>

0000000080000c8a <release>:
{
    80000c8a:	1101                	addi	sp,sp,-32
    80000c8c:	ec06                	sd	ra,24(sp)
    80000c8e:	e822                	sd	s0,16(sp)
    80000c90:	e426                	sd	s1,8(sp)
    80000c92:	1000                	addi	s0,sp,32
    80000c94:	84aa                	mv	s1,a0
  if(!holding(lk))
    80000c96:	00000097          	auipc	ra,0x0
    80000c9a:	ec6080e7          	jalr	-314(ra) # 80000b5c <holding>
    80000c9e:	c115                	beqz	a0,80000cc2 <release+0x38>
  lk->cpu = 0;
    80000ca0:	0004b823          	sd	zero,16(s1)
  __sync_synchronize();
    80000ca4:	0ff0000f          	fence
  __sync_lock_release(&lk->locked);
    80000ca8:	0f50000f          	fence	iorw,ow
    80000cac:	0804a02f          	amoswap.w	zero,zero,(s1)
  pop_off();
    80000cb0:	00000097          	auipc	ra,0x0
    80000cb4:	f7a080e7          	jalr	-134(ra) # 80000c2a <pop_off>
}
    80000cb8:	60e2                	ld	ra,24(sp)
    80000cba:	6442                	ld	s0,16(sp)
    80000cbc:	64a2                	ld	s1,8(sp)
    80000cbe:	6105                	addi	sp,sp,32
    80000cc0:	8082                	ret
    panic("release");
    80000cc2:	00007517          	auipc	a0,0x7
    80000cc6:	3d650513          	addi	a0,a0,982 # 80008098 <digits+0x58>
    80000cca:	00000097          	auipc	ra,0x0
    80000cce:	876080e7          	jalr	-1930(ra) # 80000540 <panic>

0000000080000cd2 <memset>:
#include "types.h"

void*
memset(void *dst, int c, uint n)
{
    80000cd2:	1141                	addi	sp,sp,-16
    80000cd4:	e422                	sd	s0,8(sp)
    80000cd6:	0800                	addi	s0,sp,16
  char *cdst = (char *) dst;
  int i;
  for(i = 0; i < n; i++){
    80000cd8:	ca19                	beqz	a2,80000cee <memset+0x1c>
    80000cda:	87aa                	mv	a5,a0
    80000cdc:	1602                	slli	a2,a2,0x20
    80000cde:	9201                	srli	a2,a2,0x20
    80000ce0:	00a60733          	add	a4,a2,a0
    cdst[i] = c;
    80000ce4:	00b78023          	sb	a1,0(a5)
  for(i = 0; i < n; i++){
    80000ce8:	0785                	addi	a5,a5,1
    80000cea:	fee79de3          	bne	a5,a4,80000ce4 <memset+0x12>
  }
  return dst;
}
    80000cee:	6422                	ld	s0,8(sp)
    80000cf0:	0141                	addi	sp,sp,16
    80000cf2:	8082                	ret

0000000080000cf4 <memcmp>:

int
memcmp(const void *v1, const void *v2, uint n)
{
    80000cf4:	1141                	addi	sp,sp,-16
    80000cf6:	e422                	sd	s0,8(sp)
    80000cf8:	0800                	addi	s0,sp,16
  const uchar *s1, *s2;

  s1 = v1;
  s2 = v2;
  while(n-- > 0){
    80000cfa:	ca05                	beqz	a2,80000d2a <memcmp+0x36>
    80000cfc:	fff6069b          	addiw	a3,a2,-1 # fff <_entry-0x7ffff001>
    80000d00:	1682                	slli	a3,a3,0x20
    80000d02:	9281                	srli	a3,a3,0x20
    80000d04:	0685                	addi	a3,a3,1
    80000d06:	96aa                	add	a3,a3,a0
    if(*s1 != *s2)
    80000d08:	00054783          	lbu	a5,0(a0)
    80000d0c:	0005c703          	lbu	a4,0(a1)
    80000d10:	00e79863          	bne	a5,a4,80000d20 <memcmp+0x2c>
      return *s1 - *s2;
    s1++, s2++;
    80000d14:	0505                	addi	a0,a0,1
    80000d16:	0585                	addi	a1,a1,1
  while(n-- > 0){
    80000d18:	fed518e3          	bne	a0,a3,80000d08 <memcmp+0x14>
  }

  return 0;
    80000d1c:	4501                	li	a0,0
    80000d1e:	a019                	j	80000d24 <memcmp+0x30>
      return *s1 - *s2;
    80000d20:	40e7853b          	subw	a0,a5,a4
}
    80000d24:	6422                	ld	s0,8(sp)
    80000d26:	0141                	addi	sp,sp,16
    80000d28:	8082                	ret
  return 0;
    80000d2a:	4501                	li	a0,0
    80000d2c:	bfe5                	j	80000d24 <memcmp+0x30>

0000000080000d2e <memmove>:

void*
memmove(void *dst, const void *src, uint n)
{
    80000d2e:	1141                	addi	sp,sp,-16
    80000d30:	e422                	sd	s0,8(sp)
    80000d32:	0800                	addi	s0,sp,16
  const char *s;
  char *d;

  if(n == 0)
    80000d34:	c205                	beqz	a2,80000d54 <memmove+0x26>
    return dst;
  
  s = src;
  d = dst;
  if(s < d && s + n > d){
    80000d36:	02a5e263          	bltu	a1,a0,80000d5a <memmove+0x2c>
    s += n;
    d += n;
    while(n-- > 0)
      *--d = *--s;
  } else
    while(n-- > 0)
    80000d3a:	1602                	slli	a2,a2,0x20
    80000d3c:	9201                	srli	a2,a2,0x20
    80000d3e:	00c587b3          	add	a5,a1,a2
{
    80000d42:	872a                	mv	a4,a0
      *d++ = *s++;
    80000d44:	0585                	addi	a1,a1,1
    80000d46:	0705                	addi	a4,a4,1 # fffffffffffff001 <end+0xffffffff7ffdd221>
    80000d48:	fff5c683          	lbu	a3,-1(a1)
    80000d4c:	fed70fa3          	sb	a3,-1(a4)
    while(n-- > 0)
    80000d50:	fef59ae3          	bne	a1,a5,80000d44 <memmove+0x16>

  return dst;
}
    80000d54:	6422                	ld	s0,8(sp)
    80000d56:	0141                	addi	sp,sp,16
    80000d58:	8082                	ret
  if(s < d && s + n > d){
    80000d5a:	02061693          	slli	a3,a2,0x20
    80000d5e:	9281                	srli	a3,a3,0x20
    80000d60:	00d58733          	add	a4,a1,a3
    80000d64:	fce57be3          	bgeu	a0,a4,80000d3a <memmove+0xc>
    d += n;
    80000d68:	96aa                	add	a3,a3,a0
    while(n-- > 0)
    80000d6a:	fff6079b          	addiw	a5,a2,-1
    80000d6e:	1782                	slli	a5,a5,0x20
    80000d70:	9381                	srli	a5,a5,0x20
    80000d72:	fff7c793          	not	a5,a5
    80000d76:	97ba                	add	a5,a5,a4
      *--d = *--s;
    80000d78:	177d                	addi	a4,a4,-1
    80000d7a:	16fd                	addi	a3,a3,-1
    80000d7c:	00074603          	lbu	a2,0(a4)
    80000d80:	00c68023          	sb	a2,0(a3)
    while(n-- > 0)
    80000d84:	fee79ae3          	bne	a5,a4,80000d78 <memmove+0x4a>
    80000d88:	b7f1                	j	80000d54 <memmove+0x26>

0000000080000d8a <memcpy>:

// memcpy exists to placate GCC.  Use memmove.
void*
memcpy(void *dst, const void *src, uint n)
{
    80000d8a:	1141                	addi	sp,sp,-16
    80000d8c:	e406                	sd	ra,8(sp)
    80000d8e:	e022                	sd	s0,0(sp)
    80000d90:	0800                	addi	s0,sp,16
  return memmove(dst, src, n);
    80000d92:	00000097          	auipc	ra,0x0
    80000d96:	f9c080e7          	jalr	-100(ra) # 80000d2e <memmove>
}
    80000d9a:	60a2                	ld	ra,8(sp)
    80000d9c:	6402                	ld	s0,0(sp)
    80000d9e:	0141                	addi	sp,sp,16
    80000da0:	8082                	ret

0000000080000da2 <strncmp>:

int
strncmp(const char *p, const char *q, uint n)
{
    80000da2:	1141                	addi	sp,sp,-16
    80000da4:	e422                	sd	s0,8(sp)
    80000da6:	0800                	addi	s0,sp,16
  while(n > 0 && *p && *p == *q)
    80000da8:	ce11                	beqz	a2,80000dc4 <strncmp+0x22>
    80000daa:	00054783          	lbu	a5,0(a0)
    80000dae:	cf89                	beqz	a5,80000dc8 <strncmp+0x26>
    80000db0:	0005c703          	lbu	a4,0(a1)
    80000db4:	00f71a63          	bne	a4,a5,80000dc8 <strncmp+0x26>
    n--, p++, q++;
    80000db8:	367d                	addiw	a2,a2,-1
    80000dba:	0505                	addi	a0,a0,1
    80000dbc:	0585                	addi	a1,a1,1
  while(n > 0 && *p && *p == *q)
    80000dbe:	f675                	bnez	a2,80000daa <strncmp+0x8>
  if(n == 0)
    return 0;
    80000dc0:	4501                	li	a0,0
    80000dc2:	a809                	j	80000dd4 <strncmp+0x32>
    80000dc4:	4501                	li	a0,0
    80000dc6:	a039                	j	80000dd4 <strncmp+0x32>
  if(n == 0)
    80000dc8:	ca09                	beqz	a2,80000dda <strncmp+0x38>
  return (uchar)*p - (uchar)*q;
    80000dca:	00054503          	lbu	a0,0(a0)
    80000dce:	0005c783          	lbu	a5,0(a1)
    80000dd2:	9d1d                	subw	a0,a0,a5
}
    80000dd4:	6422                	ld	s0,8(sp)
    80000dd6:	0141                	addi	sp,sp,16
    80000dd8:	8082                	ret
    return 0;
    80000dda:	4501                	li	a0,0
    80000ddc:	bfe5                	j	80000dd4 <strncmp+0x32>

0000000080000dde <strncpy>:

char*
strncpy(char *s, const char *t, int n)
{
    80000dde:	1141                	addi	sp,sp,-16
    80000de0:	e422                	sd	s0,8(sp)
    80000de2:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  while(n-- > 0 && (*s++ = *t++) != 0)
    80000de4:	872a                	mv	a4,a0
    80000de6:	8832                	mv	a6,a2
    80000de8:	367d                	addiw	a2,a2,-1
    80000dea:	01005963          	blez	a6,80000dfc <strncpy+0x1e>
    80000dee:	0705                	addi	a4,a4,1
    80000df0:	0005c783          	lbu	a5,0(a1)
    80000df4:	fef70fa3          	sb	a5,-1(a4)
    80000df8:	0585                	addi	a1,a1,1
    80000dfa:	f7f5                	bnez	a5,80000de6 <strncpy+0x8>
    ;
  while(n-- > 0)
    80000dfc:	86ba                	mv	a3,a4
    80000dfe:	00c05c63          	blez	a2,80000e16 <strncpy+0x38>
    *s++ = 0;
    80000e02:	0685                	addi	a3,a3,1
    80000e04:	fe068fa3          	sb	zero,-1(a3)
  while(n-- > 0)
    80000e08:	40d707bb          	subw	a5,a4,a3
    80000e0c:	37fd                	addiw	a5,a5,-1
    80000e0e:	010787bb          	addw	a5,a5,a6
    80000e12:	fef048e3          	bgtz	a5,80000e02 <strncpy+0x24>
  return os;
}
    80000e16:	6422                	ld	s0,8(sp)
    80000e18:	0141                	addi	sp,sp,16
    80000e1a:	8082                	ret

0000000080000e1c <safestrcpy>:

// Like strncpy but guaranteed to NUL-terminate.
char*
safestrcpy(char *s, const char *t, int n)
{
    80000e1c:	1141                	addi	sp,sp,-16
    80000e1e:	e422                	sd	s0,8(sp)
    80000e20:	0800                	addi	s0,sp,16
  char *os;

  os = s;
  if(n <= 0)
    80000e22:	02c05363          	blez	a2,80000e48 <safestrcpy+0x2c>
    80000e26:	fff6069b          	addiw	a3,a2,-1
    80000e2a:	1682                	slli	a3,a3,0x20
    80000e2c:	9281                	srli	a3,a3,0x20
    80000e2e:	96ae                	add	a3,a3,a1
    80000e30:	87aa                	mv	a5,a0
    return os;
  while(--n > 0 && (*s++ = *t++) != 0)
    80000e32:	00d58963          	beq	a1,a3,80000e44 <safestrcpy+0x28>
    80000e36:	0585                	addi	a1,a1,1
    80000e38:	0785                	addi	a5,a5,1
    80000e3a:	fff5c703          	lbu	a4,-1(a1)
    80000e3e:	fee78fa3          	sb	a4,-1(a5)
    80000e42:	fb65                	bnez	a4,80000e32 <safestrcpy+0x16>
    ;
  *s = 0;
    80000e44:	00078023          	sb	zero,0(a5)
  return os;
}
    80000e48:	6422                	ld	s0,8(sp)
    80000e4a:	0141                	addi	sp,sp,16
    80000e4c:	8082                	ret

0000000080000e4e <strlen>:

int
strlen(const char *s)
{
    80000e4e:	1141                	addi	sp,sp,-16
    80000e50:	e422                	sd	s0,8(sp)
    80000e52:	0800                	addi	s0,sp,16
  int n;

  for(n = 0; s[n]; n++)
    80000e54:	00054783          	lbu	a5,0(a0)
    80000e58:	cf91                	beqz	a5,80000e74 <strlen+0x26>
    80000e5a:	0505                	addi	a0,a0,1
    80000e5c:	87aa                	mv	a5,a0
    80000e5e:	4685                	li	a3,1
    80000e60:	9e89                	subw	a3,a3,a0
    80000e62:	00f6853b          	addw	a0,a3,a5
    80000e66:	0785                	addi	a5,a5,1
    80000e68:	fff7c703          	lbu	a4,-1(a5)
    80000e6c:	fb7d                	bnez	a4,80000e62 <strlen+0x14>
    ;
  return n;
}
    80000e6e:	6422                	ld	s0,8(sp)
    80000e70:	0141                	addi	sp,sp,16
    80000e72:	8082                	ret
  for(n = 0; s[n]; n++)
    80000e74:	4501                	li	a0,0
    80000e76:	bfe5                	j	80000e6e <strlen+0x20>

0000000080000e78 <main>:
volatile static int started = 0;

// start() jumps here in supervisor mode on all CPUs.
void
main()
{
    80000e78:	1141                	addi	sp,sp,-16
    80000e7a:	e406                	sd	ra,8(sp)
    80000e7c:	e022                	sd	s0,0(sp)
    80000e7e:	0800                	addi	s0,sp,16
  if(cpuid() == 0){
    80000e80:	00001097          	auipc	ra,0x1
    80000e84:	c4e080e7          	jalr	-946(ra) # 80001ace <cpuid>
    virtio_disk_init(); // emulated hard disk
    userinit();      // first user process
    __sync_synchronize();
    started = 1;
  } else {
    while(started == 0)
    80000e88:	00008717          	auipc	a4,0x8
    80000e8c:	ac070713          	addi	a4,a4,-1344 # 80008948 <started>
  if(cpuid() == 0){
    80000e90:	c139                	beqz	a0,80000ed6 <main+0x5e>
    while(started == 0)
    80000e92:	431c                	lw	a5,0(a4)
    80000e94:	2781                	sext.w	a5,a5
    80000e96:	dff5                	beqz	a5,80000e92 <main+0x1a>
      ;
    __sync_synchronize();
    80000e98:	0ff0000f          	fence
    printf("hart %d starting\n", cpuid());
    80000e9c:	00001097          	auipc	ra,0x1
    80000ea0:	c32080e7          	jalr	-974(ra) # 80001ace <cpuid>
    80000ea4:	85aa                	mv	a1,a0
    80000ea6:	00007517          	auipc	a0,0x7
    80000eaa:	21250513          	addi	a0,a0,530 # 800080b8 <digits+0x78>
    80000eae:	fffff097          	auipc	ra,0xfffff
    80000eb2:	6dc080e7          	jalr	1756(ra) # 8000058a <printf>
    kvminithart();    // turn on paging
    80000eb6:	00000097          	auipc	ra,0x0
    80000eba:	0d8080e7          	jalr	216(ra) # 80000f8e <kvminithart>
    trapinithart();   // install kernel trap vector
    80000ebe:	00002097          	auipc	ra,0x2
    80000ec2:	8da080e7          	jalr	-1830(ra) # 80002798 <trapinithart>
    plicinithart();   // ask PLIC for device interrupts
    80000ec6:	00005097          	auipc	ra,0x5
    80000eca:	00a080e7          	jalr	10(ra) # 80005ed0 <plicinithart>
  }

  scheduler();        
    80000ece:	00001097          	auipc	ra,0x1
    80000ed2:	122080e7          	jalr	290(ra) # 80001ff0 <scheduler>
    consoleinit();
    80000ed6:	fffff097          	auipc	ra,0xfffff
    80000eda:	57a080e7          	jalr	1402(ra) # 80000450 <consoleinit>
    printfinit();
    80000ede:	00000097          	auipc	ra,0x0
    80000ee2:	88c080e7          	jalr	-1908(ra) # 8000076a <printfinit>
    printf("\n");
    80000ee6:	00007517          	auipc	a0,0x7
    80000eea:	1e250513          	addi	a0,a0,482 # 800080c8 <digits+0x88>
    80000eee:	fffff097          	auipc	ra,0xfffff
    80000ef2:	69c080e7          	jalr	1692(ra) # 8000058a <printf>
    printf("xv6 kernel is booting\n");
    80000ef6:	00007517          	auipc	a0,0x7
    80000efa:	1aa50513          	addi	a0,a0,426 # 800080a0 <digits+0x60>
    80000efe:	fffff097          	auipc	ra,0xfffff
    80000f02:	68c080e7          	jalr	1676(ra) # 8000058a <printf>
    printf("\n");
    80000f06:	00007517          	auipc	a0,0x7
    80000f0a:	1c250513          	addi	a0,a0,450 # 800080c8 <digits+0x88>
    80000f0e:	fffff097          	auipc	ra,0xfffff
    80000f12:	67c080e7          	jalr	1660(ra) # 8000058a <printf>
    kinit();         // physical page allocator
    80000f16:	00000097          	auipc	ra,0x0
    80000f1a:	b94080e7          	jalr	-1132(ra) # 80000aaa <kinit>
    kvminit();       // create kernel page table
    80000f1e:	00000097          	auipc	ra,0x0
    80000f22:	326080e7          	jalr	806(ra) # 80001244 <kvminit>
    kvminithart();   // turn on paging
    80000f26:	00000097          	auipc	ra,0x0
    80000f2a:	068080e7          	jalr	104(ra) # 80000f8e <kvminithart>
    procinit();      // process table
    80000f2e:	00001097          	auipc	ra,0x1
    80000f32:	99e080e7          	jalr	-1634(ra) # 800018cc <procinit>
    trapinit();      // trap vectors
    80000f36:	00002097          	auipc	ra,0x2
    80000f3a:	83a080e7          	jalr	-1990(ra) # 80002770 <trapinit>
    trapinithart();  // install kernel trap vector
    80000f3e:	00002097          	auipc	ra,0x2
    80000f42:	85a080e7          	jalr	-1958(ra) # 80002798 <trapinithart>
    plicinit();      // set up interrupt controller
    80000f46:	00005097          	auipc	ra,0x5
    80000f4a:	f74080e7          	jalr	-140(ra) # 80005eba <plicinit>
    plicinithart();  // ask PLIC for device interrupts
    80000f4e:	00005097          	auipc	ra,0x5
    80000f52:	f82080e7          	jalr	-126(ra) # 80005ed0 <plicinithart>
    binit();         // buffer cache
    80000f56:	00002097          	auipc	ra,0x2
    80000f5a:	122080e7          	jalr	290(ra) # 80003078 <binit>
    iinit();         // inode table
    80000f5e:	00002097          	auipc	ra,0x2
    80000f62:	7c2080e7          	jalr	1986(ra) # 80003720 <iinit>
    fileinit();      // file table
    80000f66:	00003097          	auipc	ra,0x3
    80000f6a:	768080e7          	jalr	1896(ra) # 800046ce <fileinit>
    virtio_disk_init(); // emulated hard disk
    80000f6e:	00005097          	auipc	ra,0x5
    80000f72:	06a080e7          	jalr	106(ra) # 80005fd8 <virtio_disk_init>
    userinit();      // first user process
    80000f76:	00001097          	auipc	ra,0x1
    80000f7a:	e5c080e7          	jalr	-420(ra) # 80001dd2 <userinit>
    __sync_synchronize();
    80000f7e:	0ff0000f          	fence
    started = 1;
    80000f82:	4785                	li	a5,1
    80000f84:	00008717          	auipc	a4,0x8
    80000f88:	9cf72223          	sw	a5,-1596(a4) # 80008948 <started>
    80000f8c:	b789                	j	80000ece <main+0x56>

0000000080000f8e <kvminithart>:

// Switch h/w page table register to the kernel's page table,
// and enable paging.
void
kvminithart()
{
    80000f8e:	1141                	addi	sp,sp,-16
    80000f90:	e422                	sd	s0,8(sp)
    80000f92:	0800                	addi	s0,sp,16
// flush the TLB.
static inline void
sfence_vma()
{
  // the zero, zero means flush all TLB entries.
  asm volatile("sfence.vma zero, zero");
    80000f94:	12000073          	sfence.vma
  // wait for any previous writes to the page table memory to finish.
  sfence_vma();

  w_satp(MAKE_SATP(kernel_pagetable));
    80000f98:	00008797          	auipc	a5,0x8
    80000f9c:	9b87b783          	ld	a5,-1608(a5) # 80008950 <kernel_pagetable>
    80000fa0:	83b1                	srli	a5,a5,0xc
    80000fa2:	577d                	li	a4,-1
    80000fa4:	177e                	slli	a4,a4,0x3f
    80000fa6:	8fd9                	or	a5,a5,a4
  asm volatile("csrw satp, %0" : : "r" (x));
    80000fa8:	18079073          	csrw	satp,a5
  asm volatile("sfence.vma zero, zero");
    80000fac:	12000073          	sfence.vma

  // flush stale entries from the TLB.
  sfence_vma();
}
    80000fb0:	6422                	ld	s0,8(sp)
    80000fb2:	0141                	addi	sp,sp,16
    80000fb4:	8082                	ret

0000000080000fb6 <walk>:
//   21..29 -- 9 bits of level-1 index.
//   12..20 -- 9 bits of level-0 index.
//    0..11 -- 12 bits of byte offset within the page.
pte_t *
walk(pagetable_t pagetable, uint64 va, int alloc)
{
    80000fb6:	7139                	addi	sp,sp,-64
    80000fb8:	fc06                	sd	ra,56(sp)
    80000fba:	f822                	sd	s0,48(sp)
    80000fbc:	f426                	sd	s1,40(sp)
    80000fbe:	f04a                	sd	s2,32(sp)
    80000fc0:	ec4e                	sd	s3,24(sp)
    80000fc2:	e852                	sd	s4,16(sp)
    80000fc4:	e456                	sd	s5,8(sp)
    80000fc6:	e05a                	sd	s6,0(sp)
    80000fc8:	0080                	addi	s0,sp,64
    80000fca:	84aa                	mv	s1,a0
    80000fcc:	89ae                	mv	s3,a1
    80000fce:	8ab2                	mv	s5,a2
  if(va >= MAXVA)
    80000fd0:	57fd                	li	a5,-1
    80000fd2:	83e9                	srli	a5,a5,0x1a
    80000fd4:	4a79                	li	s4,30
    panic("walk");

  for(int level = 2; level > 0; level--) {
    80000fd6:	4b31                	li	s6,12
  if(va >= MAXVA)
    80000fd8:	04b7f263          	bgeu	a5,a1,8000101c <walk+0x66>
    panic("walk");
    80000fdc:	00007517          	auipc	a0,0x7
    80000fe0:	0f450513          	addi	a0,a0,244 # 800080d0 <digits+0x90>
    80000fe4:	fffff097          	auipc	ra,0xfffff
    80000fe8:	55c080e7          	jalr	1372(ra) # 80000540 <panic>
    pte_t *pte = &pagetable[PX(level, va)];
    if(*pte & PTE_V) {
      pagetable = (pagetable_t)PTE2PA(*pte);
    } else {
      if(!alloc || (pagetable = (pde_t*)kalloc()) == 0)
    80000fec:	060a8663          	beqz	s5,80001058 <walk+0xa2>
    80000ff0:	00000097          	auipc	ra,0x0
    80000ff4:	af6080e7          	jalr	-1290(ra) # 80000ae6 <kalloc>
    80000ff8:	84aa                	mv	s1,a0
    80000ffa:	c529                	beqz	a0,80001044 <walk+0x8e>
        return 0;
      memset(pagetable, 0, PGSIZE);
    80000ffc:	6605                	lui	a2,0x1
    80000ffe:	4581                	li	a1,0
    80001000:	00000097          	auipc	ra,0x0
    80001004:	cd2080e7          	jalr	-814(ra) # 80000cd2 <memset>
      *pte = PA2PTE(pagetable) | PTE_V;
    80001008:	00c4d793          	srli	a5,s1,0xc
    8000100c:	07aa                	slli	a5,a5,0xa
    8000100e:	0017e793          	ori	a5,a5,1
    80001012:	00f93023          	sd	a5,0(s2)
  for(int level = 2; level > 0; level--) {
    80001016:	3a5d                	addiw	s4,s4,-9 # ffffffffffffeff7 <end+0xffffffff7ffdd217>
    80001018:	036a0063          	beq	s4,s6,80001038 <walk+0x82>
    pte_t *pte = &pagetable[PX(level, va)];
    8000101c:	0149d933          	srl	s2,s3,s4
    80001020:	1ff97913          	andi	s2,s2,511
    80001024:	090e                	slli	s2,s2,0x3
    80001026:	9926                	add	s2,s2,s1
    if(*pte & PTE_V) {
    80001028:	00093483          	ld	s1,0(s2)
    8000102c:	0014f793          	andi	a5,s1,1
    80001030:	dfd5                	beqz	a5,80000fec <walk+0x36>
      pagetable = (pagetable_t)PTE2PA(*pte);
    80001032:	80a9                	srli	s1,s1,0xa
    80001034:	04b2                	slli	s1,s1,0xc
    80001036:	b7c5                	j	80001016 <walk+0x60>
    }
  }
  return &pagetable[PX(0, va)];
    80001038:	00c9d513          	srli	a0,s3,0xc
    8000103c:	1ff57513          	andi	a0,a0,511
    80001040:	050e                	slli	a0,a0,0x3
    80001042:	9526                	add	a0,a0,s1
}
    80001044:	70e2                	ld	ra,56(sp)
    80001046:	7442                	ld	s0,48(sp)
    80001048:	74a2                	ld	s1,40(sp)
    8000104a:	7902                	ld	s2,32(sp)
    8000104c:	69e2                	ld	s3,24(sp)
    8000104e:	6a42                	ld	s4,16(sp)
    80001050:	6aa2                	ld	s5,8(sp)
    80001052:	6b02                	ld	s6,0(sp)
    80001054:	6121                	addi	sp,sp,64
    80001056:	8082                	ret
        return 0;
    80001058:	4501                	li	a0,0
    8000105a:	b7ed                	j	80001044 <walk+0x8e>

000000008000105c <walkaddr>:
walkaddr(pagetable_t pagetable, uint64 va)
{
  pte_t *pte;
  uint64 pa;

  if(va >= MAXVA)
    8000105c:	57fd                	li	a5,-1
    8000105e:	83e9                	srli	a5,a5,0x1a
    80001060:	00b7f463          	bgeu	a5,a1,80001068 <walkaddr+0xc>
    return 0;
    80001064:	4501                	li	a0,0
    return 0;
  if((*pte & PTE_U) == 0)
    return 0;
  pa = PTE2PA(*pte);
  return pa;
}
    80001066:	8082                	ret
{
    80001068:	1141                	addi	sp,sp,-16
    8000106a:	e406                	sd	ra,8(sp)
    8000106c:	e022                	sd	s0,0(sp)
    8000106e:	0800                	addi	s0,sp,16
  pte = walk(pagetable, va, 0);
    80001070:	4601                	li	a2,0
    80001072:	00000097          	auipc	ra,0x0
    80001076:	f44080e7          	jalr	-188(ra) # 80000fb6 <walk>
  if(pte == 0)
    8000107a:	c105                	beqz	a0,8000109a <walkaddr+0x3e>
  if((*pte & PTE_V) == 0)
    8000107c:	611c                	ld	a5,0(a0)
  if((*pte & PTE_U) == 0)
    8000107e:	0117f693          	andi	a3,a5,17
    80001082:	4745                	li	a4,17
    return 0;
    80001084:	4501                	li	a0,0
  if((*pte & PTE_U) == 0)
    80001086:	00e68663          	beq	a3,a4,80001092 <walkaddr+0x36>
}
    8000108a:	60a2                	ld	ra,8(sp)
    8000108c:	6402                	ld	s0,0(sp)
    8000108e:	0141                	addi	sp,sp,16
    80001090:	8082                	ret
  pa = PTE2PA(*pte);
    80001092:	83a9                	srli	a5,a5,0xa
    80001094:	00c79513          	slli	a0,a5,0xc
  return pa;
    80001098:	bfcd                	j	8000108a <walkaddr+0x2e>
    return 0;
    8000109a:	4501                	li	a0,0
    8000109c:	b7fd                	j	8000108a <walkaddr+0x2e>

000000008000109e <mappages>:
// physical addresses starting at pa. va and size might not
// be page-aligned. Returns 0 on success, -1 if walk() couldn't
// allocate a needed page-table page.
int
mappages(pagetable_t pagetable, uint64 va, uint64 size, uint64 pa, int perm)
{
    8000109e:	715d                	addi	sp,sp,-80
    800010a0:	e486                	sd	ra,72(sp)
    800010a2:	e0a2                	sd	s0,64(sp)
    800010a4:	fc26                	sd	s1,56(sp)
    800010a6:	f84a                	sd	s2,48(sp)
    800010a8:	f44e                	sd	s3,40(sp)
    800010aa:	f052                	sd	s4,32(sp)
    800010ac:	ec56                	sd	s5,24(sp)
    800010ae:	e85a                	sd	s6,16(sp)
    800010b0:	e45e                	sd	s7,8(sp)
    800010b2:	0880                	addi	s0,sp,80
  uint64 a, last;
  pte_t *pte;

  if(size == 0)
    800010b4:	c639                	beqz	a2,80001102 <mappages+0x64>
    800010b6:	8aaa                	mv	s5,a0
    800010b8:	8b3a                	mv	s6,a4
    panic("mappages: size");
  
  a = PGROUNDDOWN(va);
    800010ba:	777d                	lui	a4,0xfffff
    800010bc:	00e5f7b3          	and	a5,a1,a4
  last = PGROUNDDOWN(va + size - 1);
    800010c0:	fff58993          	addi	s3,a1,-1
    800010c4:	99b2                	add	s3,s3,a2
    800010c6:	00e9f9b3          	and	s3,s3,a4
  a = PGROUNDDOWN(va);
    800010ca:	893e                	mv	s2,a5
    800010cc:	40f68a33          	sub	s4,a3,a5
    if(*pte & PTE_V)
      panic("mappages: remap");
    *pte = PA2PTE(pa) | perm | PTE_V;
    if(a == last)
      break;
    a += PGSIZE;
    800010d0:	6b85                	lui	s7,0x1
    800010d2:	012a04b3          	add	s1,s4,s2
    if((pte = walk(pagetable, a, 1)) == 0)
    800010d6:	4605                	li	a2,1
    800010d8:	85ca                	mv	a1,s2
    800010da:	8556                	mv	a0,s5
    800010dc:	00000097          	auipc	ra,0x0
    800010e0:	eda080e7          	jalr	-294(ra) # 80000fb6 <walk>
    800010e4:	cd1d                	beqz	a0,80001122 <mappages+0x84>
    if(*pte & PTE_V)
    800010e6:	611c                	ld	a5,0(a0)
    800010e8:	8b85                	andi	a5,a5,1
    800010ea:	e785                	bnez	a5,80001112 <mappages+0x74>
    *pte = PA2PTE(pa) | perm | PTE_V;
    800010ec:	80b1                	srli	s1,s1,0xc
    800010ee:	04aa                	slli	s1,s1,0xa
    800010f0:	0164e4b3          	or	s1,s1,s6
    800010f4:	0014e493          	ori	s1,s1,1
    800010f8:	e104                	sd	s1,0(a0)
    if(a == last)
    800010fa:	05390063          	beq	s2,s3,8000113a <mappages+0x9c>
    a += PGSIZE;
    800010fe:	995e                	add	s2,s2,s7
    if((pte = walk(pagetable, a, 1)) == 0)
    80001100:	bfc9                	j	800010d2 <mappages+0x34>
    panic("mappages: size");
    80001102:	00007517          	auipc	a0,0x7
    80001106:	fd650513          	addi	a0,a0,-42 # 800080d8 <digits+0x98>
    8000110a:	fffff097          	auipc	ra,0xfffff
    8000110e:	436080e7          	jalr	1078(ra) # 80000540 <panic>
      panic("mappages: remap");
    80001112:	00007517          	auipc	a0,0x7
    80001116:	fd650513          	addi	a0,a0,-42 # 800080e8 <digits+0xa8>
    8000111a:	fffff097          	auipc	ra,0xfffff
    8000111e:	426080e7          	jalr	1062(ra) # 80000540 <panic>
      return -1;
    80001122:	557d                	li	a0,-1
    pa += PGSIZE;
  }
  return 0;
}
    80001124:	60a6                	ld	ra,72(sp)
    80001126:	6406                	ld	s0,64(sp)
    80001128:	74e2                	ld	s1,56(sp)
    8000112a:	7942                	ld	s2,48(sp)
    8000112c:	79a2                	ld	s3,40(sp)
    8000112e:	7a02                	ld	s4,32(sp)
    80001130:	6ae2                	ld	s5,24(sp)
    80001132:	6b42                	ld	s6,16(sp)
    80001134:	6ba2                	ld	s7,8(sp)
    80001136:	6161                	addi	sp,sp,80
    80001138:	8082                	ret
  return 0;
    8000113a:	4501                	li	a0,0
    8000113c:	b7e5                	j	80001124 <mappages+0x86>

000000008000113e <kvmmap>:
{
    8000113e:	1141                	addi	sp,sp,-16
    80001140:	e406                	sd	ra,8(sp)
    80001142:	e022                	sd	s0,0(sp)
    80001144:	0800                	addi	s0,sp,16
    80001146:	87b6                	mv	a5,a3
  if(mappages(kpgtbl, va, sz, pa, perm) != 0)
    80001148:	86b2                	mv	a3,a2
    8000114a:	863e                	mv	a2,a5
    8000114c:	00000097          	auipc	ra,0x0
    80001150:	f52080e7          	jalr	-174(ra) # 8000109e <mappages>
    80001154:	e509                	bnez	a0,8000115e <kvmmap+0x20>
}
    80001156:	60a2                	ld	ra,8(sp)
    80001158:	6402                	ld	s0,0(sp)
    8000115a:	0141                	addi	sp,sp,16
    8000115c:	8082                	ret
    panic("kvmmap");
    8000115e:	00007517          	auipc	a0,0x7
    80001162:	f9a50513          	addi	a0,a0,-102 # 800080f8 <digits+0xb8>
    80001166:	fffff097          	auipc	ra,0xfffff
    8000116a:	3da080e7          	jalr	986(ra) # 80000540 <panic>

000000008000116e <kvmmake>:
{
    8000116e:	1101                	addi	sp,sp,-32
    80001170:	ec06                	sd	ra,24(sp)
    80001172:	e822                	sd	s0,16(sp)
    80001174:	e426                	sd	s1,8(sp)
    80001176:	e04a                	sd	s2,0(sp)
    80001178:	1000                	addi	s0,sp,32
  kpgtbl = (pagetable_t) kalloc();
    8000117a:	00000097          	auipc	ra,0x0
    8000117e:	96c080e7          	jalr	-1684(ra) # 80000ae6 <kalloc>
    80001182:	84aa                	mv	s1,a0
  memset(kpgtbl, 0, PGSIZE);
    80001184:	6605                	lui	a2,0x1
    80001186:	4581                	li	a1,0
    80001188:	00000097          	auipc	ra,0x0
    8000118c:	b4a080e7          	jalr	-1206(ra) # 80000cd2 <memset>
  kvmmap(kpgtbl, UART0, UART0, PGSIZE, PTE_R | PTE_W);
    80001190:	4719                	li	a4,6
    80001192:	6685                	lui	a3,0x1
    80001194:	10000637          	lui	a2,0x10000
    80001198:	100005b7          	lui	a1,0x10000
    8000119c:	8526                	mv	a0,s1
    8000119e:	00000097          	auipc	ra,0x0
    800011a2:	fa0080e7          	jalr	-96(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, VIRTIO0, VIRTIO0, PGSIZE, PTE_R | PTE_W);
    800011a6:	4719                	li	a4,6
    800011a8:	6685                	lui	a3,0x1
    800011aa:	10001637          	lui	a2,0x10001
    800011ae:	100015b7          	lui	a1,0x10001
    800011b2:	8526                	mv	a0,s1
    800011b4:	00000097          	auipc	ra,0x0
    800011b8:	f8a080e7          	jalr	-118(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, PLIC, PLIC, 0x400000, PTE_R | PTE_W);
    800011bc:	4719                	li	a4,6
    800011be:	004006b7          	lui	a3,0x400
    800011c2:	0c000637          	lui	a2,0xc000
    800011c6:	0c0005b7          	lui	a1,0xc000
    800011ca:	8526                	mv	a0,s1
    800011cc:	00000097          	auipc	ra,0x0
    800011d0:	f72080e7          	jalr	-142(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, KERNBASE, KERNBASE, (uint64)etext-KERNBASE, PTE_R | PTE_X);
    800011d4:	00007917          	auipc	s2,0x7
    800011d8:	e2c90913          	addi	s2,s2,-468 # 80008000 <etext>
    800011dc:	4729                	li	a4,10
    800011de:	80007697          	auipc	a3,0x80007
    800011e2:	e2268693          	addi	a3,a3,-478 # 8000 <_entry-0x7fff8000>
    800011e6:	4605                	li	a2,1
    800011e8:	067e                	slli	a2,a2,0x1f
    800011ea:	85b2                	mv	a1,a2
    800011ec:	8526                	mv	a0,s1
    800011ee:	00000097          	auipc	ra,0x0
    800011f2:	f50080e7          	jalr	-176(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, (uint64)etext, (uint64)etext, PHYSTOP-(uint64)etext, PTE_R | PTE_W);
    800011f6:	4719                	li	a4,6
    800011f8:	46c5                	li	a3,17
    800011fa:	06ee                	slli	a3,a3,0x1b
    800011fc:	412686b3          	sub	a3,a3,s2
    80001200:	864a                	mv	a2,s2
    80001202:	85ca                	mv	a1,s2
    80001204:	8526                	mv	a0,s1
    80001206:	00000097          	auipc	ra,0x0
    8000120a:	f38080e7          	jalr	-200(ra) # 8000113e <kvmmap>
  kvmmap(kpgtbl, TRAMPOLINE, (uint64)trampoline, PGSIZE, PTE_R | PTE_X);
    8000120e:	4729                	li	a4,10
    80001210:	6685                	lui	a3,0x1
    80001212:	00006617          	auipc	a2,0x6
    80001216:	dee60613          	addi	a2,a2,-530 # 80007000 <_trampoline>
    8000121a:	040005b7          	lui	a1,0x4000
    8000121e:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001220:	05b2                	slli	a1,a1,0xc
    80001222:	8526                	mv	a0,s1
    80001224:	00000097          	auipc	ra,0x0
    80001228:	f1a080e7          	jalr	-230(ra) # 8000113e <kvmmap>
  proc_mapstacks(kpgtbl);
    8000122c:	8526                	mv	a0,s1
    8000122e:	00000097          	auipc	ra,0x0
    80001232:	608080e7          	jalr	1544(ra) # 80001836 <proc_mapstacks>
}
    80001236:	8526                	mv	a0,s1
    80001238:	60e2                	ld	ra,24(sp)
    8000123a:	6442                	ld	s0,16(sp)
    8000123c:	64a2                	ld	s1,8(sp)
    8000123e:	6902                	ld	s2,0(sp)
    80001240:	6105                	addi	sp,sp,32
    80001242:	8082                	ret

0000000080001244 <kvminit>:
{
    80001244:	1141                	addi	sp,sp,-16
    80001246:	e406                	sd	ra,8(sp)
    80001248:	e022                	sd	s0,0(sp)
    8000124a:	0800                	addi	s0,sp,16
  kernel_pagetable = kvmmake();
    8000124c:	00000097          	auipc	ra,0x0
    80001250:	f22080e7          	jalr	-222(ra) # 8000116e <kvmmake>
    80001254:	00007797          	auipc	a5,0x7
    80001258:	6ea7be23          	sd	a0,1788(a5) # 80008950 <kernel_pagetable>
}
    8000125c:	60a2                	ld	ra,8(sp)
    8000125e:	6402                	ld	s0,0(sp)
    80001260:	0141                	addi	sp,sp,16
    80001262:	8082                	ret

0000000080001264 <uvmunmap>:
// Remove npages of mappings starting from va. va must be
// page-aligned. The mappings must exist.
// Optionally free the physical memory.
void
uvmunmap(pagetable_t pagetable, uint64 va, uint64 npages, int do_free)
{
    80001264:	715d                	addi	sp,sp,-80
    80001266:	e486                	sd	ra,72(sp)
    80001268:	e0a2                	sd	s0,64(sp)
    8000126a:	fc26                	sd	s1,56(sp)
    8000126c:	f84a                	sd	s2,48(sp)
    8000126e:	f44e                	sd	s3,40(sp)
    80001270:	f052                	sd	s4,32(sp)
    80001272:	ec56                	sd	s5,24(sp)
    80001274:	e85a                	sd	s6,16(sp)
    80001276:	e45e                	sd	s7,8(sp)
    80001278:	0880                	addi	s0,sp,80
  uint64 a;
  pte_t *pte;

  if((va % PGSIZE) != 0)
    8000127a:	03459793          	slli	a5,a1,0x34
    8000127e:	e795                	bnez	a5,800012aa <uvmunmap+0x46>
    80001280:	8a2a                	mv	s4,a0
    80001282:	892e                	mv	s2,a1
    80001284:	8ab6                	mv	s5,a3
    panic("uvmunmap: not aligned");

  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    80001286:	0632                	slli	a2,a2,0xc
    80001288:	00b609b3          	add	s3,a2,a1
    if((pte = walk(pagetable, a, 0)) == 0)
      panic("uvmunmap: walk");
    if((*pte & PTE_V) == 0)
      panic("uvmunmap: not mapped");
    if(PTE_FLAGS(*pte) == PTE_V)
    8000128c:	4b85                	li	s7,1
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    8000128e:	6b05                	lui	s6,0x1
    80001290:	0735e263          	bltu	a1,s3,800012f4 <uvmunmap+0x90>
      uint64 pa = PTE2PA(*pte);
      kfree((void*)pa);
    }
    *pte = 0;
  }
}
    80001294:	60a6                	ld	ra,72(sp)
    80001296:	6406                	ld	s0,64(sp)
    80001298:	74e2                	ld	s1,56(sp)
    8000129a:	7942                	ld	s2,48(sp)
    8000129c:	79a2                	ld	s3,40(sp)
    8000129e:	7a02                	ld	s4,32(sp)
    800012a0:	6ae2                	ld	s5,24(sp)
    800012a2:	6b42                	ld	s6,16(sp)
    800012a4:	6ba2                	ld	s7,8(sp)
    800012a6:	6161                	addi	sp,sp,80
    800012a8:	8082                	ret
    panic("uvmunmap: not aligned");
    800012aa:	00007517          	auipc	a0,0x7
    800012ae:	e5650513          	addi	a0,a0,-426 # 80008100 <digits+0xc0>
    800012b2:	fffff097          	auipc	ra,0xfffff
    800012b6:	28e080e7          	jalr	654(ra) # 80000540 <panic>
      panic("uvmunmap: walk");
    800012ba:	00007517          	auipc	a0,0x7
    800012be:	e5e50513          	addi	a0,a0,-418 # 80008118 <digits+0xd8>
    800012c2:	fffff097          	auipc	ra,0xfffff
    800012c6:	27e080e7          	jalr	638(ra) # 80000540 <panic>
      panic("uvmunmap: not mapped");
    800012ca:	00007517          	auipc	a0,0x7
    800012ce:	e5e50513          	addi	a0,a0,-418 # 80008128 <digits+0xe8>
    800012d2:	fffff097          	auipc	ra,0xfffff
    800012d6:	26e080e7          	jalr	622(ra) # 80000540 <panic>
      panic("uvmunmap: not a leaf");
    800012da:	00007517          	auipc	a0,0x7
    800012de:	e6650513          	addi	a0,a0,-410 # 80008140 <digits+0x100>
    800012e2:	fffff097          	auipc	ra,0xfffff
    800012e6:	25e080e7          	jalr	606(ra) # 80000540 <panic>
    *pte = 0;
    800012ea:	0004b023          	sd	zero,0(s1)
  for(a = va; a < va + npages*PGSIZE; a += PGSIZE){
    800012ee:	995a                	add	s2,s2,s6
    800012f0:	fb3972e3          	bgeu	s2,s3,80001294 <uvmunmap+0x30>
    if((pte = walk(pagetable, a, 0)) == 0)
    800012f4:	4601                	li	a2,0
    800012f6:	85ca                	mv	a1,s2
    800012f8:	8552                	mv	a0,s4
    800012fa:	00000097          	auipc	ra,0x0
    800012fe:	cbc080e7          	jalr	-836(ra) # 80000fb6 <walk>
    80001302:	84aa                	mv	s1,a0
    80001304:	d95d                	beqz	a0,800012ba <uvmunmap+0x56>
    if((*pte & PTE_V) == 0)
    80001306:	6108                	ld	a0,0(a0)
    80001308:	00157793          	andi	a5,a0,1
    8000130c:	dfdd                	beqz	a5,800012ca <uvmunmap+0x66>
    if(PTE_FLAGS(*pte) == PTE_V)
    8000130e:	3ff57793          	andi	a5,a0,1023
    80001312:	fd7784e3          	beq	a5,s7,800012da <uvmunmap+0x76>
    if(do_free){
    80001316:	fc0a8ae3          	beqz	s5,800012ea <uvmunmap+0x86>
      uint64 pa = PTE2PA(*pte);
    8000131a:	8129                	srli	a0,a0,0xa
      kfree((void*)pa);
    8000131c:	0532                	slli	a0,a0,0xc
    8000131e:	fffff097          	auipc	ra,0xfffff
    80001322:	6ca080e7          	jalr	1738(ra) # 800009e8 <kfree>
    80001326:	b7d1                	j	800012ea <uvmunmap+0x86>

0000000080001328 <uvmcreate>:

// create an empty user page table.
// returns 0 if out of memory.
pagetable_t
uvmcreate()
{
    80001328:	1101                	addi	sp,sp,-32
    8000132a:	ec06                	sd	ra,24(sp)
    8000132c:	e822                	sd	s0,16(sp)
    8000132e:	e426                	sd	s1,8(sp)
    80001330:	1000                	addi	s0,sp,32
  pagetable_t pagetable;
  pagetable = (pagetable_t) kalloc();
    80001332:	fffff097          	auipc	ra,0xfffff
    80001336:	7b4080e7          	jalr	1972(ra) # 80000ae6 <kalloc>
    8000133a:	84aa                	mv	s1,a0
  if(pagetable == 0)
    8000133c:	c519                	beqz	a0,8000134a <uvmcreate+0x22>
    return 0;
  memset(pagetable, 0, PGSIZE);
    8000133e:	6605                	lui	a2,0x1
    80001340:	4581                	li	a1,0
    80001342:	00000097          	auipc	ra,0x0
    80001346:	990080e7          	jalr	-1648(ra) # 80000cd2 <memset>
  return pagetable;
}
    8000134a:	8526                	mv	a0,s1
    8000134c:	60e2                	ld	ra,24(sp)
    8000134e:	6442                	ld	s0,16(sp)
    80001350:	64a2                	ld	s1,8(sp)
    80001352:	6105                	addi	sp,sp,32
    80001354:	8082                	ret

0000000080001356 <uvmfirst>:
// Load the user initcode into address 0 of pagetable,
// for the very first process.
// sz must be less than a page.
void
uvmfirst(pagetable_t pagetable, uchar *src, uint sz)
{
    80001356:	7179                	addi	sp,sp,-48
    80001358:	f406                	sd	ra,40(sp)
    8000135a:	f022                	sd	s0,32(sp)
    8000135c:	ec26                	sd	s1,24(sp)
    8000135e:	e84a                	sd	s2,16(sp)
    80001360:	e44e                	sd	s3,8(sp)
    80001362:	e052                	sd	s4,0(sp)
    80001364:	1800                	addi	s0,sp,48
  char *mem;

  if(sz >= PGSIZE)
    80001366:	6785                	lui	a5,0x1
    80001368:	04f67863          	bgeu	a2,a5,800013b8 <uvmfirst+0x62>
    8000136c:	8a2a                	mv	s4,a0
    8000136e:	89ae                	mv	s3,a1
    80001370:	84b2                	mv	s1,a2
    panic("uvmfirst: more than a page");
  mem = kalloc();
    80001372:	fffff097          	auipc	ra,0xfffff
    80001376:	774080e7          	jalr	1908(ra) # 80000ae6 <kalloc>
    8000137a:	892a                	mv	s2,a0
  memset(mem, 0, PGSIZE);
    8000137c:	6605                	lui	a2,0x1
    8000137e:	4581                	li	a1,0
    80001380:	00000097          	auipc	ra,0x0
    80001384:	952080e7          	jalr	-1710(ra) # 80000cd2 <memset>
  mappages(pagetable, 0, PGSIZE, (uint64)mem, PTE_W|PTE_R|PTE_X|PTE_U);
    80001388:	4779                	li	a4,30
    8000138a:	86ca                	mv	a3,s2
    8000138c:	6605                	lui	a2,0x1
    8000138e:	4581                	li	a1,0
    80001390:	8552                	mv	a0,s4
    80001392:	00000097          	auipc	ra,0x0
    80001396:	d0c080e7          	jalr	-756(ra) # 8000109e <mappages>
  memmove(mem, src, sz);
    8000139a:	8626                	mv	a2,s1
    8000139c:	85ce                	mv	a1,s3
    8000139e:	854a                	mv	a0,s2
    800013a0:	00000097          	auipc	ra,0x0
    800013a4:	98e080e7          	jalr	-1650(ra) # 80000d2e <memmove>
}
    800013a8:	70a2                	ld	ra,40(sp)
    800013aa:	7402                	ld	s0,32(sp)
    800013ac:	64e2                	ld	s1,24(sp)
    800013ae:	6942                	ld	s2,16(sp)
    800013b0:	69a2                	ld	s3,8(sp)
    800013b2:	6a02                	ld	s4,0(sp)
    800013b4:	6145                	addi	sp,sp,48
    800013b6:	8082                	ret
    panic("uvmfirst: more than a page");
    800013b8:	00007517          	auipc	a0,0x7
    800013bc:	da050513          	addi	a0,a0,-608 # 80008158 <digits+0x118>
    800013c0:	fffff097          	auipc	ra,0xfffff
    800013c4:	180080e7          	jalr	384(ra) # 80000540 <panic>

00000000800013c8 <uvmdealloc>:
// newsz.  oldsz and newsz need not be page-aligned, nor does newsz
// need to be less than oldsz.  oldsz can be larger than the actual
// process size.  Returns the new process size.
uint64
uvmdealloc(pagetable_t pagetable, uint64 oldsz, uint64 newsz)
{
    800013c8:	1101                	addi	sp,sp,-32
    800013ca:	ec06                	sd	ra,24(sp)
    800013cc:	e822                	sd	s0,16(sp)
    800013ce:	e426                	sd	s1,8(sp)
    800013d0:	1000                	addi	s0,sp,32
  if(newsz >= oldsz)
    return oldsz;
    800013d2:	84ae                	mv	s1,a1
  if(newsz >= oldsz)
    800013d4:	00b67d63          	bgeu	a2,a1,800013ee <uvmdealloc+0x26>
    800013d8:	84b2                	mv	s1,a2

  if(PGROUNDUP(newsz) < PGROUNDUP(oldsz)){
    800013da:	6785                	lui	a5,0x1
    800013dc:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    800013de:	00f60733          	add	a4,a2,a5
    800013e2:	76fd                	lui	a3,0xfffff
    800013e4:	8f75                	and	a4,a4,a3
    800013e6:	97ae                	add	a5,a5,a1
    800013e8:	8ff5                	and	a5,a5,a3
    800013ea:	00f76863          	bltu	a4,a5,800013fa <uvmdealloc+0x32>
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
  }

  return newsz;
}
    800013ee:	8526                	mv	a0,s1
    800013f0:	60e2                	ld	ra,24(sp)
    800013f2:	6442                	ld	s0,16(sp)
    800013f4:	64a2                	ld	s1,8(sp)
    800013f6:	6105                	addi	sp,sp,32
    800013f8:	8082                	ret
    int npages = (PGROUNDUP(oldsz) - PGROUNDUP(newsz)) / PGSIZE;
    800013fa:	8f99                	sub	a5,a5,a4
    800013fc:	83b1                	srli	a5,a5,0xc
    uvmunmap(pagetable, PGROUNDUP(newsz), npages, 1);
    800013fe:	4685                	li	a3,1
    80001400:	0007861b          	sext.w	a2,a5
    80001404:	85ba                	mv	a1,a4
    80001406:	00000097          	auipc	ra,0x0
    8000140a:	e5e080e7          	jalr	-418(ra) # 80001264 <uvmunmap>
    8000140e:	b7c5                	j	800013ee <uvmdealloc+0x26>

0000000080001410 <uvmalloc>:
  if(newsz < oldsz)
    80001410:	0ab66563          	bltu	a2,a1,800014ba <uvmalloc+0xaa>
{
    80001414:	7139                	addi	sp,sp,-64
    80001416:	fc06                	sd	ra,56(sp)
    80001418:	f822                	sd	s0,48(sp)
    8000141a:	f426                	sd	s1,40(sp)
    8000141c:	f04a                	sd	s2,32(sp)
    8000141e:	ec4e                	sd	s3,24(sp)
    80001420:	e852                	sd	s4,16(sp)
    80001422:	e456                	sd	s5,8(sp)
    80001424:	e05a                	sd	s6,0(sp)
    80001426:	0080                	addi	s0,sp,64
    80001428:	8aaa                	mv	s5,a0
    8000142a:	8a32                	mv	s4,a2
  oldsz = PGROUNDUP(oldsz);
    8000142c:	6785                	lui	a5,0x1
    8000142e:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001430:	95be                	add	a1,a1,a5
    80001432:	77fd                	lui	a5,0xfffff
    80001434:	00f5f9b3          	and	s3,a1,a5
  for(a = oldsz; a < newsz; a += PGSIZE){
    80001438:	08c9f363          	bgeu	s3,a2,800014be <uvmalloc+0xae>
    8000143c:	894e                	mv	s2,s3
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000143e:	0126eb13          	ori	s6,a3,18
    mem = kalloc();
    80001442:	fffff097          	auipc	ra,0xfffff
    80001446:	6a4080e7          	jalr	1700(ra) # 80000ae6 <kalloc>
    8000144a:	84aa                	mv	s1,a0
    if(mem == 0){
    8000144c:	c51d                	beqz	a0,8000147a <uvmalloc+0x6a>
    memset(mem, 0, PGSIZE);
    8000144e:	6605                	lui	a2,0x1
    80001450:	4581                	li	a1,0
    80001452:	00000097          	auipc	ra,0x0
    80001456:	880080e7          	jalr	-1920(ra) # 80000cd2 <memset>
    if(mappages(pagetable, a, PGSIZE, (uint64)mem, PTE_R|PTE_U|xperm) != 0){
    8000145a:	875a                	mv	a4,s6
    8000145c:	86a6                	mv	a3,s1
    8000145e:	6605                	lui	a2,0x1
    80001460:	85ca                	mv	a1,s2
    80001462:	8556                	mv	a0,s5
    80001464:	00000097          	auipc	ra,0x0
    80001468:	c3a080e7          	jalr	-966(ra) # 8000109e <mappages>
    8000146c:	e90d                	bnez	a0,8000149e <uvmalloc+0x8e>
  for(a = oldsz; a < newsz; a += PGSIZE){
    8000146e:	6785                	lui	a5,0x1
    80001470:	993e                	add	s2,s2,a5
    80001472:	fd4968e3          	bltu	s2,s4,80001442 <uvmalloc+0x32>
  return newsz;
    80001476:	8552                	mv	a0,s4
    80001478:	a809                	j	8000148a <uvmalloc+0x7a>
      uvmdealloc(pagetable, a, oldsz);
    8000147a:	864e                	mv	a2,s3
    8000147c:	85ca                	mv	a1,s2
    8000147e:	8556                	mv	a0,s5
    80001480:	00000097          	auipc	ra,0x0
    80001484:	f48080e7          	jalr	-184(ra) # 800013c8 <uvmdealloc>
      return 0;
    80001488:	4501                	li	a0,0
}
    8000148a:	70e2                	ld	ra,56(sp)
    8000148c:	7442                	ld	s0,48(sp)
    8000148e:	74a2                	ld	s1,40(sp)
    80001490:	7902                	ld	s2,32(sp)
    80001492:	69e2                	ld	s3,24(sp)
    80001494:	6a42                	ld	s4,16(sp)
    80001496:	6aa2                	ld	s5,8(sp)
    80001498:	6b02                	ld	s6,0(sp)
    8000149a:	6121                	addi	sp,sp,64
    8000149c:	8082                	ret
      kfree(mem);
    8000149e:	8526                	mv	a0,s1
    800014a0:	fffff097          	auipc	ra,0xfffff
    800014a4:	548080e7          	jalr	1352(ra) # 800009e8 <kfree>
      uvmdealloc(pagetable, a, oldsz);
    800014a8:	864e                	mv	a2,s3
    800014aa:	85ca                	mv	a1,s2
    800014ac:	8556                	mv	a0,s5
    800014ae:	00000097          	auipc	ra,0x0
    800014b2:	f1a080e7          	jalr	-230(ra) # 800013c8 <uvmdealloc>
      return 0;
    800014b6:	4501                	li	a0,0
    800014b8:	bfc9                	j	8000148a <uvmalloc+0x7a>
    return oldsz;
    800014ba:	852e                	mv	a0,a1
}
    800014bc:	8082                	ret
  return newsz;
    800014be:	8532                	mv	a0,a2
    800014c0:	b7e9                	j	8000148a <uvmalloc+0x7a>

00000000800014c2 <freewalk>:

// Recursively free page-table pages.
// All leaf mappings must already have been removed.
void
freewalk(pagetable_t pagetable)
{
    800014c2:	7179                	addi	sp,sp,-48
    800014c4:	f406                	sd	ra,40(sp)
    800014c6:	f022                	sd	s0,32(sp)
    800014c8:	ec26                	sd	s1,24(sp)
    800014ca:	e84a                	sd	s2,16(sp)
    800014cc:	e44e                	sd	s3,8(sp)
    800014ce:	e052                	sd	s4,0(sp)
    800014d0:	1800                	addi	s0,sp,48
    800014d2:	8a2a                	mv	s4,a0
  // there are 2^9 = 512 PTEs in a page table.
  for(int i = 0; i < 512; i++){
    800014d4:	84aa                	mv	s1,a0
    800014d6:	6905                	lui	s2,0x1
    800014d8:	992a                	add	s2,s2,a0
    pte_t pte = pagetable[i];
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014da:	4985                	li	s3,1
    800014dc:	a829                	j	800014f6 <freewalk+0x34>
      // this PTE points to a lower-level page table.
      uint64 child = PTE2PA(pte);
    800014de:	83a9                	srli	a5,a5,0xa
      freewalk((pagetable_t)child);
    800014e0:	00c79513          	slli	a0,a5,0xc
    800014e4:	00000097          	auipc	ra,0x0
    800014e8:	fde080e7          	jalr	-34(ra) # 800014c2 <freewalk>
      pagetable[i] = 0;
    800014ec:	0004b023          	sd	zero,0(s1)
  for(int i = 0; i < 512; i++){
    800014f0:	04a1                	addi	s1,s1,8
    800014f2:	03248163          	beq	s1,s2,80001514 <freewalk+0x52>
    pte_t pte = pagetable[i];
    800014f6:	609c                	ld	a5,0(s1)
    if((pte & PTE_V) && (pte & (PTE_R|PTE_W|PTE_X)) == 0){
    800014f8:	00f7f713          	andi	a4,a5,15
    800014fc:	ff3701e3          	beq	a4,s3,800014de <freewalk+0x1c>
    } else if(pte & PTE_V){
    80001500:	8b85                	andi	a5,a5,1
    80001502:	d7fd                	beqz	a5,800014f0 <freewalk+0x2e>
      panic("freewalk: leaf");
    80001504:	00007517          	auipc	a0,0x7
    80001508:	c7450513          	addi	a0,a0,-908 # 80008178 <digits+0x138>
    8000150c:	fffff097          	auipc	ra,0xfffff
    80001510:	034080e7          	jalr	52(ra) # 80000540 <panic>
    }
  }
  kfree((void*)pagetable);
    80001514:	8552                	mv	a0,s4
    80001516:	fffff097          	auipc	ra,0xfffff
    8000151a:	4d2080e7          	jalr	1234(ra) # 800009e8 <kfree>
}
    8000151e:	70a2                	ld	ra,40(sp)
    80001520:	7402                	ld	s0,32(sp)
    80001522:	64e2                	ld	s1,24(sp)
    80001524:	6942                	ld	s2,16(sp)
    80001526:	69a2                	ld	s3,8(sp)
    80001528:	6a02                	ld	s4,0(sp)
    8000152a:	6145                	addi	sp,sp,48
    8000152c:	8082                	ret

000000008000152e <uvmfree>:

// Free user memory pages,
// then free page-table pages.
void
uvmfree(pagetable_t pagetable, uint64 sz)
{
    8000152e:	1101                	addi	sp,sp,-32
    80001530:	ec06                	sd	ra,24(sp)
    80001532:	e822                	sd	s0,16(sp)
    80001534:	e426                	sd	s1,8(sp)
    80001536:	1000                	addi	s0,sp,32
    80001538:	84aa                	mv	s1,a0
  if(sz > 0)
    8000153a:	e999                	bnez	a1,80001550 <uvmfree+0x22>
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
  freewalk(pagetable);
    8000153c:	8526                	mv	a0,s1
    8000153e:	00000097          	auipc	ra,0x0
    80001542:	f84080e7          	jalr	-124(ra) # 800014c2 <freewalk>
}
    80001546:	60e2                	ld	ra,24(sp)
    80001548:	6442                	ld	s0,16(sp)
    8000154a:	64a2                	ld	s1,8(sp)
    8000154c:	6105                	addi	sp,sp,32
    8000154e:	8082                	ret
    uvmunmap(pagetable, 0, PGROUNDUP(sz)/PGSIZE, 1);
    80001550:	6785                	lui	a5,0x1
    80001552:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80001554:	95be                	add	a1,a1,a5
    80001556:	4685                	li	a3,1
    80001558:	00c5d613          	srli	a2,a1,0xc
    8000155c:	4581                	li	a1,0
    8000155e:	00000097          	auipc	ra,0x0
    80001562:	d06080e7          	jalr	-762(ra) # 80001264 <uvmunmap>
    80001566:	bfd9                	j	8000153c <uvmfree+0xe>

0000000080001568 <uvmcopy>:
  pte_t *pte;
  uint64 pa, i;
  uint flags;
  char *mem;

  for(i = 0; i < sz; i += PGSIZE){
    80001568:	c679                	beqz	a2,80001636 <uvmcopy+0xce>
{
    8000156a:	715d                	addi	sp,sp,-80
    8000156c:	e486                	sd	ra,72(sp)
    8000156e:	e0a2                	sd	s0,64(sp)
    80001570:	fc26                	sd	s1,56(sp)
    80001572:	f84a                	sd	s2,48(sp)
    80001574:	f44e                	sd	s3,40(sp)
    80001576:	f052                	sd	s4,32(sp)
    80001578:	ec56                	sd	s5,24(sp)
    8000157a:	e85a                	sd	s6,16(sp)
    8000157c:	e45e                	sd	s7,8(sp)
    8000157e:	0880                	addi	s0,sp,80
    80001580:	8b2a                	mv	s6,a0
    80001582:	8aae                	mv	s5,a1
    80001584:	8a32                	mv	s4,a2
  for(i = 0; i < sz; i += PGSIZE){
    80001586:	4981                	li	s3,0
    if((pte = walk(old, i, 0)) == 0)
    80001588:	4601                	li	a2,0
    8000158a:	85ce                	mv	a1,s3
    8000158c:	855a                	mv	a0,s6
    8000158e:	00000097          	auipc	ra,0x0
    80001592:	a28080e7          	jalr	-1496(ra) # 80000fb6 <walk>
    80001596:	c531                	beqz	a0,800015e2 <uvmcopy+0x7a>
      panic("uvmcopy: pte should exist");
    if((*pte & PTE_V) == 0)
    80001598:	6118                	ld	a4,0(a0)
    8000159a:	00177793          	andi	a5,a4,1
    8000159e:	cbb1                	beqz	a5,800015f2 <uvmcopy+0x8a>
      panic("uvmcopy: page not present");
    pa = PTE2PA(*pte);
    800015a0:	00a75593          	srli	a1,a4,0xa
    800015a4:	00c59b93          	slli	s7,a1,0xc
    flags = PTE_FLAGS(*pte);
    800015a8:	3ff77493          	andi	s1,a4,1023
    if((mem = kalloc()) == 0)
    800015ac:	fffff097          	auipc	ra,0xfffff
    800015b0:	53a080e7          	jalr	1338(ra) # 80000ae6 <kalloc>
    800015b4:	892a                	mv	s2,a0
    800015b6:	c939                	beqz	a0,8000160c <uvmcopy+0xa4>
      goto err;
    memmove(mem, (char*)pa, PGSIZE);
    800015b8:	6605                	lui	a2,0x1
    800015ba:	85de                	mv	a1,s7
    800015bc:	fffff097          	auipc	ra,0xfffff
    800015c0:	772080e7          	jalr	1906(ra) # 80000d2e <memmove>
    if(mappages(new, i, PGSIZE, (uint64)mem, flags) != 0){
    800015c4:	8726                	mv	a4,s1
    800015c6:	86ca                	mv	a3,s2
    800015c8:	6605                	lui	a2,0x1
    800015ca:	85ce                	mv	a1,s3
    800015cc:	8556                	mv	a0,s5
    800015ce:	00000097          	auipc	ra,0x0
    800015d2:	ad0080e7          	jalr	-1328(ra) # 8000109e <mappages>
    800015d6:	e515                	bnez	a0,80001602 <uvmcopy+0x9a>
  for(i = 0; i < sz; i += PGSIZE){
    800015d8:	6785                	lui	a5,0x1
    800015da:	99be                	add	s3,s3,a5
    800015dc:	fb49e6e3          	bltu	s3,s4,80001588 <uvmcopy+0x20>
    800015e0:	a081                	j	80001620 <uvmcopy+0xb8>
      panic("uvmcopy: pte should exist");
    800015e2:	00007517          	auipc	a0,0x7
    800015e6:	ba650513          	addi	a0,a0,-1114 # 80008188 <digits+0x148>
    800015ea:	fffff097          	auipc	ra,0xfffff
    800015ee:	f56080e7          	jalr	-170(ra) # 80000540 <panic>
      panic("uvmcopy: page not present");
    800015f2:	00007517          	auipc	a0,0x7
    800015f6:	bb650513          	addi	a0,a0,-1098 # 800081a8 <digits+0x168>
    800015fa:	fffff097          	auipc	ra,0xfffff
    800015fe:	f46080e7          	jalr	-186(ra) # 80000540 <panic>
      kfree(mem);
    80001602:	854a                	mv	a0,s2
    80001604:	fffff097          	auipc	ra,0xfffff
    80001608:	3e4080e7          	jalr	996(ra) # 800009e8 <kfree>
    }
  }
  return 0;

 err:
  uvmunmap(new, 0, i / PGSIZE, 1);
    8000160c:	4685                	li	a3,1
    8000160e:	00c9d613          	srli	a2,s3,0xc
    80001612:	4581                	li	a1,0
    80001614:	8556                	mv	a0,s5
    80001616:	00000097          	auipc	ra,0x0
    8000161a:	c4e080e7          	jalr	-946(ra) # 80001264 <uvmunmap>
  return -1;
    8000161e:	557d                	li	a0,-1
}
    80001620:	60a6                	ld	ra,72(sp)
    80001622:	6406                	ld	s0,64(sp)
    80001624:	74e2                	ld	s1,56(sp)
    80001626:	7942                	ld	s2,48(sp)
    80001628:	79a2                	ld	s3,40(sp)
    8000162a:	7a02                	ld	s4,32(sp)
    8000162c:	6ae2                	ld	s5,24(sp)
    8000162e:	6b42                	ld	s6,16(sp)
    80001630:	6ba2                	ld	s7,8(sp)
    80001632:	6161                	addi	sp,sp,80
    80001634:	8082                	ret
  return 0;
    80001636:	4501                	li	a0,0
}
    80001638:	8082                	ret

000000008000163a <uvmclear>:

// mark a PTE invalid for user access.
// used by exec for the user stack guard page.
void
uvmclear(pagetable_t pagetable, uint64 va)
{
    8000163a:	1141                	addi	sp,sp,-16
    8000163c:	e406                	sd	ra,8(sp)
    8000163e:	e022                	sd	s0,0(sp)
    80001640:	0800                	addi	s0,sp,16
  pte_t *pte;
  
  pte = walk(pagetable, va, 0);
    80001642:	4601                	li	a2,0
    80001644:	00000097          	auipc	ra,0x0
    80001648:	972080e7          	jalr	-1678(ra) # 80000fb6 <walk>
  if(pte == 0)
    8000164c:	c901                	beqz	a0,8000165c <uvmclear+0x22>
    panic("uvmclear");
  *pte &= ~PTE_U;
    8000164e:	611c                	ld	a5,0(a0)
    80001650:	9bbd                	andi	a5,a5,-17
    80001652:	e11c                	sd	a5,0(a0)
}
    80001654:	60a2                	ld	ra,8(sp)
    80001656:	6402                	ld	s0,0(sp)
    80001658:	0141                	addi	sp,sp,16
    8000165a:	8082                	ret
    panic("uvmclear");
    8000165c:	00007517          	auipc	a0,0x7
    80001660:	b6c50513          	addi	a0,a0,-1172 # 800081c8 <digits+0x188>
    80001664:	fffff097          	auipc	ra,0xfffff
    80001668:	edc080e7          	jalr	-292(ra) # 80000540 <panic>

000000008000166c <copyout>:
int
copyout(pagetable_t pagetable, uint64 dstva, char *src, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    8000166c:	c6bd                	beqz	a3,800016da <copyout+0x6e>
{
    8000166e:	715d                	addi	sp,sp,-80
    80001670:	e486                	sd	ra,72(sp)
    80001672:	e0a2                	sd	s0,64(sp)
    80001674:	fc26                	sd	s1,56(sp)
    80001676:	f84a                	sd	s2,48(sp)
    80001678:	f44e                	sd	s3,40(sp)
    8000167a:	f052                	sd	s4,32(sp)
    8000167c:	ec56                	sd	s5,24(sp)
    8000167e:	e85a                	sd	s6,16(sp)
    80001680:	e45e                	sd	s7,8(sp)
    80001682:	e062                	sd	s8,0(sp)
    80001684:	0880                	addi	s0,sp,80
    80001686:	8b2a                	mv	s6,a0
    80001688:	8c2e                	mv	s8,a1
    8000168a:	8a32                	mv	s4,a2
    8000168c:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(dstva);
    8000168e:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (dstva - va0);
    80001690:	6a85                	lui	s5,0x1
    80001692:	a015                	j	800016b6 <copyout+0x4a>
    if(n > len)
      n = len;
    memmove((void *)(pa0 + (dstva - va0)), src, n);
    80001694:	9562                	add	a0,a0,s8
    80001696:	0004861b          	sext.w	a2,s1
    8000169a:	85d2                	mv	a1,s4
    8000169c:	41250533          	sub	a0,a0,s2
    800016a0:	fffff097          	auipc	ra,0xfffff
    800016a4:	68e080e7          	jalr	1678(ra) # 80000d2e <memmove>

    len -= n;
    800016a8:	409989b3          	sub	s3,s3,s1
    src += n;
    800016ac:	9a26                	add	s4,s4,s1
    dstva = va0 + PGSIZE;
    800016ae:	01590c33          	add	s8,s2,s5
  while(len > 0){
    800016b2:	02098263          	beqz	s3,800016d6 <copyout+0x6a>
    va0 = PGROUNDDOWN(dstva);
    800016b6:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    800016ba:	85ca                	mv	a1,s2
    800016bc:	855a                	mv	a0,s6
    800016be:	00000097          	auipc	ra,0x0
    800016c2:	99e080e7          	jalr	-1634(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800016c6:	cd01                	beqz	a0,800016de <copyout+0x72>
    n = PGSIZE - (dstva - va0);
    800016c8:	418904b3          	sub	s1,s2,s8
    800016cc:	94d6                	add	s1,s1,s5
    800016ce:	fc99f3e3          	bgeu	s3,s1,80001694 <copyout+0x28>
    800016d2:	84ce                	mv	s1,s3
    800016d4:	b7c1                	j	80001694 <copyout+0x28>
  }
  return 0;
    800016d6:	4501                	li	a0,0
    800016d8:	a021                	j	800016e0 <copyout+0x74>
    800016da:	4501                	li	a0,0
}
    800016dc:	8082                	ret
      return -1;
    800016de:	557d                	li	a0,-1
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
    800016f2:	6c02                	ld	s8,0(sp)
    800016f4:	6161                	addi	sp,sp,80
    800016f6:	8082                	ret

00000000800016f8 <copyin>:
int
copyin(pagetable_t pagetable, char *dst, uint64 srcva, uint64 len)
{
  uint64 n, va0, pa0;

  while(len > 0){
    800016f8:	caa5                	beqz	a3,80001768 <copyin+0x70>
{
    800016fa:	715d                	addi	sp,sp,-80
    800016fc:	e486                	sd	ra,72(sp)
    800016fe:	e0a2                	sd	s0,64(sp)
    80001700:	fc26                	sd	s1,56(sp)
    80001702:	f84a                	sd	s2,48(sp)
    80001704:	f44e                	sd	s3,40(sp)
    80001706:	f052                	sd	s4,32(sp)
    80001708:	ec56                	sd	s5,24(sp)
    8000170a:	e85a                	sd	s6,16(sp)
    8000170c:	e45e                	sd	s7,8(sp)
    8000170e:	e062                	sd	s8,0(sp)
    80001710:	0880                	addi	s0,sp,80
    80001712:	8b2a                	mv	s6,a0
    80001714:	8a2e                	mv	s4,a1
    80001716:	8c32                	mv	s8,a2
    80001718:	89b6                	mv	s3,a3
    va0 = PGROUNDDOWN(srcva);
    8000171a:	7bfd                	lui	s7,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    8000171c:	6a85                	lui	s5,0x1
    8000171e:	a01d                	j	80001744 <copyin+0x4c>
    if(n > len)
      n = len;
    memmove(dst, (void *)(pa0 + (srcva - va0)), n);
    80001720:	018505b3          	add	a1,a0,s8
    80001724:	0004861b          	sext.w	a2,s1
    80001728:	412585b3          	sub	a1,a1,s2
    8000172c:	8552                	mv	a0,s4
    8000172e:	fffff097          	auipc	ra,0xfffff
    80001732:	600080e7          	jalr	1536(ra) # 80000d2e <memmove>

    len -= n;
    80001736:	409989b3          	sub	s3,s3,s1
    dst += n;
    8000173a:	9a26                	add	s4,s4,s1
    srcva = va0 + PGSIZE;
    8000173c:	01590c33          	add	s8,s2,s5
  while(len > 0){
    80001740:	02098263          	beqz	s3,80001764 <copyin+0x6c>
    va0 = PGROUNDDOWN(srcva);
    80001744:	017c7933          	and	s2,s8,s7
    pa0 = walkaddr(pagetable, va0);
    80001748:	85ca                	mv	a1,s2
    8000174a:	855a                	mv	a0,s6
    8000174c:	00000097          	auipc	ra,0x0
    80001750:	910080e7          	jalr	-1776(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    80001754:	cd01                	beqz	a0,8000176c <copyin+0x74>
    n = PGSIZE - (srcva - va0);
    80001756:	418904b3          	sub	s1,s2,s8
    8000175a:	94d6                	add	s1,s1,s5
    8000175c:	fc99f2e3          	bgeu	s3,s1,80001720 <copyin+0x28>
    80001760:	84ce                	mv	s1,s3
    80001762:	bf7d                	j	80001720 <copyin+0x28>
  }
  return 0;
    80001764:	4501                	li	a0,0
    80001766:	a021                	j	8000176e <copyin+0x76>
    80001768:	4501                	li	a0,0
}
    8000176a:	8082                	ret
      return -1;
    8000176c:	557d                	li	a0,-1
}
    8000176e:	60a6                	ld	ra,72(sp)
    80001770:	6406                	ld	s0,64(sp)
    80001772:	74e2                	ld	s1,56(sp)
    80001774:	7942                	ld	s2,48(sp)
    80001776:	79a2                	ld	s3,40(sp)
    80001778:	7a02                	ld	s4,32(sp)
    8000177a:	6ae2                	ld	s5,24(sp)
    8000177c:	6b42                	ld	s6,16(sp)
    8000177e:	6ba2                	ld	s7,8(sp)
    80001780:	6c02                	ld	s8,0(sp)
    80001782:	6161                	addi	sp,sp,80
    80001784:	8082                	ret

0000000080001786 <copyinstr>:
copyinstr(pagetable_t pagetable, char *dst, uint64 srcva, uint64 max)
{
  uint64 n, va0, pa0;
  int got_null = 0;

  while(got_null == 0 && max > 0){
    80001786:	c2dd                	beqz	a3,8000182c <copyinstr+0xa6>
{
    80001788:	715d                	addi	sp,sp,-80
    8000178a:	e486                	sd	ra,72(sp)
    8000178c:	e0a2                	sd	s0,64(sp)
    8000178e:	fc26                	sd	s1,56(sp)
    80001790:	f84a                	sd	s2,48(sp)
    80001792:	f44e                	sd	s3,40(sp)
    80001794:	f052                	sd	s4,32(sp)
    80001796:	ec56                	sd	s5,24(sp)
    80001798:	e85a                	sd	s6,16(sp)
    8000179a:	e45e                	sd	s7,8(sp)
    8000179c:	0880                	addi	s0,sp,80
    8000179e:	8a2a                	mv	s4,a0
    800017a0:	8b2e                	mv	s6,a1
    800017a2:	8bb2                	mv	s7,a2
    800017a4:	84b6                	mv	s1,a3
    va0 = PGROUNDDOWN(srcva);
    800017a6:	7afd                	lui	s5,0xfffff
    pa0 = walkaddr(pagetable, va0);
    if(pa0 == 0)
      return -1;
    n = PGSIZE - (srcva - va0);
    800017a8:	6985                	lui	s3,0x1
    800017aa:	a02d                	j	800017d4 <copyinstr+0x4e>
      n = max;

    char *p = (char *) (pa0 + (srcva - va0));
    while(n > 0){
      if(*p == '\0'){
        *dst = '\0';
    800017ac:	00078023          	sb	zero,0(a5) # 1000 <_entry-0x7ffff000>
    800017b0:	4785                	li	a5,1
      dst++;
    }

    srcva = va0 + PGSIZE;
  }
  if(got_null){
    800017b2:	37fd                	addiw	a5,a5,-1
    800017b4:	0007851b          	sext.w	a0,a5
    return 0;
  } else {
    return -1;
  }
}
    800017b8:	60a6                	ld	ra,72(sp)
    800017ba:	6406                	ld	s0,64(sp)
    800017bc:	74e2                	ld	s1,56(sp)
    800017be:	7942                	ld	s2,48(sp)
    800017c0:	79a2                	ld	s3,40(sp)
    800017c2:	7a02                	ld	s4,32(sp)
    800017c4:	6ae2                	ld	s5,24(sp)
    800017c6:	6b42                	ld	s6,16(sp)
    800017c8:	6ba2                	ld	s7,8(sp)
    800017ca:	6161                	addi	sp,sp,80
    800017cc:	8082                	ret
    srcva = va0 + PGSIZE;
    800017ce:	01390bb3          	add	s7,s2,s3
  while(got_null == 0 && max > 0){
    800017d2:	c8a9                	beqz	s1,80001824 <copyinstr+0x9e>
    va0 = PGROUNDDOWN(srcva);
    800017d4:	015bf933          	and	s2,s7,s5
    pa0 = walkaddr(pagetable, va0);
    800017d8:	85ca                	mv	a1,s2
    800017da:	8552                	mv	a0,s4
    800017dc:	00000097          	auipc	ra,0x0
    800017e0:	880080e7          	jalr	-1920(ra) # 8000105c <walkaddr>
    if(pa0 == 0)
    800017e4:	c131                	beqz	a0,80001828 <copyinstr+0xa2>
    n = PGSIZE - (srcva - va0);
    800017e6:	417906b3          	sub	a3,s2,s7
    800017ea:	96ce                	add	a3,a3,s3
    800017ec:	00d4f363          	bgeu	s1,a3,800017f2 <copyinstr+0x6c>
    800017f0:	86a6                	mv	a3,s1
    char *p = (char *) (pa0 + (srcva - va0));
    800017f2:	955e                	add	a0,a0,s7
    800017f4:	41250533          	sub	a0,a0,s2
    while(n > 0){
    800017f8:	daf9                	beqz	a3,800017ce <copyinstr+0x48>
    800017fa:	87da                	mv	a5,s6
      if(*p == '\0'){
    800017fc:	41650633          	sub	a2,a0,s6
    80001800:	fff48593          	addi	a1,s1,-1
    80001804:	95da                	add	a1,a1,s6
    while(n > 0){
    80001806:	96da                	add	a3,a3,s6
      if(*p == '\0'){
    80001808:	00f60733          	add	a4,a2,a5
    8000180c:	00074703          	lbu	a4,0(a4) # fffffffffffff000 <end+0xffffffff7ffdd220>
    80001810:	df51                	beqz	a4,800017ac <copyinstr+0x26>
        *dst = *p;
    80001812:	00e78023          	sb	a4,0(a5)
      --max;
    80001816:	40f584b3          	sub	s1,a1,a5
      dst++;
    8000181a:	0785                	addi	a5,a5,1
    while(n > 0){
    8000181c:	fed796e3          	bne	a5,a3,80001808 <copyinstr+0x82>
      dst++;
    80001820:	8b3e                	mv	s6,a5
    80001822:	b775                	j	800017ce <copyinstr+0x48>
    80001824:	4781                	li	a5,0
    80001826:	b771                	j	800017b2 <copyinstr+0x2c>
      return -1;
    80001828:	557d                	li	a0,-1
    8000182a:	b779                	j	800017b8 <copyinstr+0x32>
  int got_null = 0;
    8000182c:	4781                	li	a5,0
  if(got_null){
    8000182e:	37fd                	addiw	a5,a5,-1
    80001830:	0007851b          	sext.w	a0,a5
}
    80001834:	8082                	ret

0000000080001836 <proc_mapstacks>:
// Allocate a page for each process's kernel stack.
// Map it high in memory, followed by an invalid
// guard page.
void
proc_mapstacks(pagetable_t kpgtbl)
{
    80001836:	7139                	addi	sp,sp,-64
    80001838:	fc06                	sd	ra,56(sp)
    8000183a:	f822                	sd	s0,48(sp)
    8000183c:	f426                	sd	s1,40(sp)
    8000183e:	f04a                	sd	s2,32(sp)
    80001840:	ec4e                	sd	s3,24(sp)
    80001842:	e852                	sd	s4,16(sp)
    80001844:	e456                	sd	s5,8(sp)
    80001846:	e05a                	sd	s6,0(sp)
    80001848:	0080                	addi	s0,sp,64
    8000184a:	89aa                	mv	s3,a0
  struct proc *p;
  
  for(p = proc; p < &proc[NPROC]; p++) {
    8000184c:	0000f497          	auipc	s1,0xf
    80001850:	7b448493          	addi	s1,s1,1972 # 80011000 <proc>
    char *pa = kalloc();
    if(pa == 0)
      panic("kalloc");
    uint64 va = KSTACK((int) (p - proc));
    80001854:	8b26                	mv	s6,s1
    80001856:	00006a97          	auipc	s5,0x6
    8000185a:	7aaa8a93          	addi	s5,s5,1962 # 80008000 <etext>
    8000185e:	04000937          	lui	s2,0x4000
    80001862:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001864:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001866:	00015a17          	auipc	s4,0x15
    8000186a:	19aa0a13          	addi	s4,s4,410 # 80016a00 <tickslock>
    char *pa = kalloc();
    8000186e:	fffff097          	auipc	ra,0xfffff
    80001872:	278080e7          	jalr	632(ra) # 80000ae6 <kalloc>
    80001876:	862a                	mv	a2,a0
    if(pa == 0)
    80001878:	c131                	beqz	a0,800018bc <proc_mapstacks+0x86>
    uint64 va = KSTACK((int) (p - proc));
    8000187a:	416485b3          	sub	a1,s1,s6
    8000187e:	858d                	srai	a1,a1,0x3
    80001880:	000ab783          	ld	a5,0(s5)
    80001884:	02f585b3          	mul	a1,a1,a5
    80001888:	2585                	addiw	a1,a1,1
    8000188a:	00d5959b          	slliw	a1,a1,0xd
    kvmmap(kpgtbl, va, (uint64)pa, PGSIZE, PTE_R | PTE_W);
    8000188e:	4719                	li	a4,6
    80001890:	6685                	lui	a3,0x1
    80001892:	40b905b3          	sub	a1,s2,a1
    80001896:	854e                	mv	a0,s3
    80001898:	00000097          	auipc	ra,0x0
    8000189c:	8a6080e7          	jalr	-1882(ra) # 8000113e <kvmmap>
  for(p = proc; p < &proc[NPROC]; p++) {
    800018a0:	16848493          	addi	s1,s1,360
    800018a4:	fd4495e3          	bne	s1,s4,8000186e <proc_mapstacks+0x38>
  }
}
    800018a8:	70e2                	ld	ra,56(sp)
    800018aa:	7442                	ld	s0,48(sp)
    800018ac:	74a2                	ld	s1,40(sp)
    800018ae:	7902                	ld	s2,32(sp)
    800018b0:	69e2                	ld	s3,24(sp)
    800018b2:	6a42                	ld	s4,16(sp)
    800018b4:	6aa2                	ld	s5,8(sp)
    800018b6:	6b02                	ld	s6,0(sp)
    800018b8:	6121                	addi	sp,sp,64
    800018ba:	8082                	ret
      panic("kalloc");
    800018bc:	00007517          	auipc	a0,0x7
    800018c0:	91c50513          	addi	a0,a0,-1764 # 800081d8 <digits+0x198>
    800018c4:	fffff097          	auipc	ra,0xfffff
    800018c8:	c7c080e7          	jalr	-900(ra) # 80000540 <panic>

00000000800018cc <procinit>:

// initialize the proc table.
void
procinit(void)
{
    800018cc:	7139                	addi	sp,sp,-64
    800018ce:	fc06                	sd	ra,56(sp)
    800018d0:	f822                	sd	s0,48(sp)
    800018d2:	f426                	sd	s1,40(sp)
    800018d4:	f04a                	sd	s2,32(sp)
    800018d6:	ec4e                	sd	s3,24(sp)
    800018d8:	e852                	sd	s4,16(sp)
    800018da:	e456                	sd	s5,8(sp)
    800018dc:	e05a                	sd	s6,0(sp)
    800018de:	0080                	addi	s0,sp,64
  struct proc *p;
  
  initlock(&pid_lock, "nextpid");
    800018e0:	00007597          	auipc	a1,0x7
    800018e4:	90058593          	addi	a1,a1,-1792 # 800081e0 <digits+0x1a0>
    800018e8:	0000f517          	auipc	a0,0xf
    800018ec:	2e850513          	addi	a0,a0,744 # 80010bd0 <pid_lock>
    800018f0:	fffff097          	auipc	ra,0xfffff
    800018f4:	256080e7          	jalr	598(ra) # 80000b46 <initlock>
  initlock(&wait_lock, "wait_lock");
    800018f8:	00007597          	auipc	a1,0x7
    800018fc:	8f058593          	addi	a1,a1,-1808 # 800081e8 <digits+0x1a8>
    80001900:	0000f517          	auipc	a0,0xf
    80001904:	2e850513          	addi	a0,a0,744 # 80010be8 <wait_lock>
    80001908:	fffff097          	auipc	ra,0xfffff
    8000190c:	23e080e7          	jalr	574(ra) # 80000b46 <initlock>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001910:	0000f497          	auipc	s1,0xf
    80001914:	6f048493          	addi	s1,s1,1776 # 80011000 <proc>
      initlock(&p->lock, "proc");
    80001918:	00007b17          	auipc	s6,0x7
    8000191c:	8e0b0b13          	addi	s6,s6,-1824 # 800081f8 <digits+0x1b8>
      p->state = UNUSED;
      p->kstack = KSTACK((int) (p - proc));
    80001920:	8aa6                	mv	s5,s1
    80001922:	00006a17          	auipc	s4,0x6
    80001926:	6dea0a13          	addi	s4,s4,1758 # 80008000 <etext>
    8000192a:	04000937          	lui	s2,0x4000
    8000192e:	197d                	addi	s2,s2,-1 # 3ffffff <_entry-0x7c000001>
    80001930:	0932                	slli	s2,s2,0xc
  for(p = proc; p < &proc[NPROC]; p++) {
    80001932:	00015997          	auipc	s3,0x15
    80001936:	0ce98993          	addi	s3,s3,206 # 80016a00 <tickslock>
      initlock(&p->lock, "proc");
    8000193a:	85da                	mv	a1,s6
    8000193c:	8526                	mv	a0,s1
    8000193e:	fffff097          	auipc	ra,0xfffff
    80001942:	208080e7          	jalr	520(ra) # 80000b46 <initlock>
      p->state = UNUSED;
    80001946:	0004ac23          	sw	zero,24(s1)
      p->kstack = KSTACK((int) (p - proc));
    8000194a:	415487b3          	sub	a5,s1,s5
    8000194e:	878d                	srai	a5,a5,0x3
    80001950:	000a3703          	ld	a4,0(s4)
    80001954:	02e787b3          	mul	a5,a5,a4
    80001958:	2785                	addiw	a5,a5,1
    8000195a:	00d7979b          	slliw	a5,a5,0xd
    8000195e:	40f907b3          	sub	a5,s2,a5
    80001962:	e0bc                	sd	a5,64(s1)
  for(p = proc; p < &proc[NPROC]; p++) {
    80001964:	16848493          	addi	s1,s1,360
    80001968:	fd3499e3          	bne	s1,s3,8000193a <procinit+0x6e>
  }
}
    8000196c:	70e2                	ld	ra,56(sp)
    8000196e:	7442                	ld	s0,48(sp)
    80001970:	74a2                	ld	s1,40(sp)
    80001972:	7902                	ld	s2,32(sp)
    80001974:	69e2                	ld	s3,24(sp)
    80001976:	6a42                	ld	s4,16(sp)
    80001978:	6aa2                	ld	s5,8(sp)
    8000197a:	6b02                	ld	s6,0(sp)
    8000197c:	6121                	addi	sp,sp,64
    8000197e:	8082                	ret

0000000080001980 <name>:

char*
name(int pid)
{
    80001980:	1101                	addi	sp,sp,-32
    80001982:	ec06                	sd	ra,24(sp)
    80001984:	e822                	sd	s0,16(sp)
    80001986:	e426                	sd	s1,8(sp)
    80001988:	e04a                	sd	s2,0(sp)
    8000198a:	1000                	addi	s0,sp,32
    8000198c:	892a                	mv	s2,a0
  //Rough copy of wait, but instead of returning pid, it returns name
  //Get the address of thr process table
  struct proc *pp;
  //struct proc *p = myproc();

  acquire(&wait_lock);
    8000198e:	0000f517          	auipc	a0,0xf
    80001992:	25a50513          	addi	a0,a0,602 # 80010be8 <wait_lock>
    80001996:	fffff097          	auipc	ra,0xfffff
    8000199a:	240080e7          	jalr	576(ra) # 80000bd6 <acquire>

  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000199e:	0000f497          	auipc	s1,0xf
    800019a2:	66248493          	addi	s1,s1,1634 # 80011000 <proc>
    800019a6:	00015717          	auipc	a4,0x15
    800019aa:	05a70713          	addi	a4,a4,90 # 80016a00 <tickslock>
      if(pp->pid == pid){
    800019ae:	589c                	lw	a5,48(s1)
    800019b0:	03278063          	beq	a5,s2,800019d0 <name+0x50>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    800019b4:	16848493          	addi	s1,s1,360
    800019b8:	fee49be3          	bne	s1,a4,800019ae <name+0x2e>
        release(&wait_lock);
        //return a pointer to the name
        return pp->name;
      }
    }
    release(&wait_lock);
    800019bc:	0000f517          	auipc	a0,0xf
    800019c0:	22c50513          	addi	a0,a0,556 # 80010be8 <wait_lock>
    800019c4:	fffff097          	auipc	ra,0xfffff
    800019c8:	2c6080e7          	jalr	710(ra) # 80000c8a <release>
    return 0;
    800019cc:	4501                	li	a0,0
    800019ce:	a819                	j	800019e4 <name+0x64>
        release(&wait_lock);
    800019d0:	0000f517          	auipc	a0,0xf
    800019d4:	21850513          	addi	a0,a0,536 # 80010be8 <wait_lock>
    800019d8:	fffff097          	auipc	ra,0xfffff
    800019dc:	2b2080e7          	jalr	690(ra) # 80000c8a <release>
        return pp->name;
    800019e0:	15848513          	addi	a0,s1,344
}
    800019e4:	60e2                	ld	ra,24(sp)
    800019e6:	6442                	ld	s0,16(sp)
    800019e8:	64a2                	ld	s1,8(sp)
    800019ea:	6902                	ld	s2,0(sp)
    800019ec:	6105                	addi	sp,sp,32
    800019ee:	8082                	ret

00000000800019f0 <procstate2str>:

char*
procstate2str(enum procstate state)
{
    800019f0:	1141                	addi	sp,sp,-16
    800019f2:	e422                	sd	s0,8(sp)
    800019f4:	0800                	addi	s0,sp,16
  switch(state){
    800019f6:	4795                	li	a5,5
    800019f8:	04a7e663          	bltu	a5,a0,80001a44 <procstate2str+0x54>
    800019fc:	050a                	slli	a0,a0,0x2
    800019fe:	00007717          	auipc	a4,0x7
    80001a02:	91270713          	addi	a4,a4,-1774 # 80008310 <digits+0x2d0>
    80001a06:	953a                	add	a0,a0,a4
    80001a08:	411c                	lw	a5,0(a0)
    80001a0a:	97ba                	add	a5,a5,a4
    80001a0c:	8782                	jr	a5
    80001a0e:	00006517          	auipc	a0,0x6
    80001a12:	7fa50513          	addi	a0,a0,2042 # 80008208 <digits+0x1c8>
    case ZOMBIE:
      return "ZOMBIE";
    default:
      return "UNKNOWN";
  }
}
    80001a16:	6422                	ld	s0,8(sp)
    80001a18:	0141                	addi	sp,sp,16
    80001a1a:	8082                	ret
      return "SLEEPING";
    80001a1c:	00006517          	auipc	a0,0x6
    80001a20:	7f450513          	addi	a0,a0,2036 # 80008210 <digits+0x1d0>
    80001a24:	bfcd                	j	80001a16 <procstate2str+0x26>
      return "RUNNABLE";
    80001a26:	00006517          	auipc	a0,0x6
    80001a2a:	7fa50513          	addi	a0,a0,2042 # 80008220 <digits+0x1e0>
    80001a2e:	b7e5                	j	80001a16 <procstate2str+0x26>
      return "RUNNING";
    80001a30:	00007517          	auipc	a0,0x7
    80001a34:	80050513          	addi	a0,a0,-2048 # 80008230 <digits+0x1f0>
    80001a38:	bff9                	j	80001a16 <procstate2str+0x26>
      return "ZOMBIE";
    80001a3a:	00006517          	auipc	a0,0x6
    80001a3e:	7fe50513          	addi	a0,a0,2046 # 80008238 <digits+0x1f8>
    80001a42:	bfd1                	j	80001a16 <procstate2str+0x26>
      return "UNKNOWN";
    80001a44:	00006517          	auipc	a0,0x6
    80001a48:	7fc50513          	addi	a0,a0,2044 # 80008240 <digits+0x200>
    80001a4c:	b7e9                	j	80001a16 <procstate2str+0x26>
      return "UNUSED";
    80001a4e:	00006517          	auipc	a0,0x6
    80001a52:	7b250513          	addi	a0,a0,1970 # 80008200 <digits+0x1c0>
    80001a56:	b7c1                	j	80001a16 <procstate2str+0x26>

0000000080001a58 <state>:

char*
state(int pid)
{
    80001a58:	1101                	addi	sp,sp,-32
    80001a5a:	ec06                	sd	ra,24(sp)
    80001a5c:	e822                	sd	s0,16(sp)
    80001a5e:	e426                	sd	s1,8(sp)
    80001a60:	e04a                	sd	s2,0(sp)
    80001a62:	1000                	addi	s0,sp,32
    80001a64:	892a                	mv	s2,a0
  //do the same as name, but instead of returning name, return state
  struct proc *pp;
  //struct proc *p = myproc();
  acquire(&wait_lock);
    80001a66:	0000f517          	auipc	a0,0xf
    80001a6a:	18250513          	addi	a0,a0,386 # 80010be8 <wait_lock>
    80001a6e:	fffff097          	auipc	ra,0xfffff
    80001a72:	168080e7          	jalr	360(ra) # 80000bd6 <acquire>

  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001a76:	0000f497          	auipc	s1,0xf
    80001a7a:	58a48493          	addi	s1,s1,1418 # 80011000 <proc>
    80001a7e:	00015717          	auipc	a4,0x15
    80001a82:	f8270713          	addi	a4,a4,-126 # 80016a00 <tickslock>
      if(pp->pid == pid){
    80001a86:	589c                	lw	a5,48(s1)
    80001a88:	03278063          	beq	a5,s2,80001aa8 <state+0x50>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    80001a8c:	16848493          	addi	s1,s1,360
    80001a90:	fee49be3          	bne	s1,a4,80001a86 <state+0x2e>
        //return a pointer to the state
        return procstate2str(pp->state);
      }
      
    }
    release(&wait_lock);
    80001a94:	0000f517          	auipc	a0,0xf
    80001a98:	15450513          	addi	a0,a0,340 # 80010be8 <wait_lock>
    80001a9c:	fffff097          	auipc	ra,0xfffff
    80001aa0:	1ee080e7          	jalr	494(ra) # 80000c8a <release>
    return 0;
    80001aa4:	4501                	li	a0,0
    80001aa6:	a831                	j	80001ac2 <state+0x6a>
        release(&wait_lock);
    80001aa8:	0000f517          	auipc	a0,0xf
    80001aac:	14050513          	addi	a0,a0,320 # 80010be8 <wait_lock>
    80001ab0:	fffff097          	auipc	ra,0xfffff
    80001ab4:	1da080e7          	jalr	474(ra) # 80000c8a <release>
        return procstate2str(pp->state);
    80001ab8:	4c88                	lw	a0,24(s1)
    80001aba:	00000097          	auipc	ra,0x0
    80001abe:	f36080e7          	jalr	-202(ra) # 800019f0 <procstate2str>
}
    80001ac2:	60e2                	ld	ra,24(sp)
    80001ac4:	6442                	ld	s0,16(sp)
    80001ac6:	64a2                	ld	s1,8(sp)
    80001ac8:	6902                	ld	s2,0(sp)
    80001aca:	6105                	addi	sp,sp,32
    80001acc:	8082                	ret

0000000080001ace <cpuid>:
// Must be called with interrupts disabled,
// to prevent race with process being moved
// to a different CPU.
int
cpuid()
{
    80001ace:	1141                	addi	sp,sp,-16
    80001ad0:	e422                	sd	s0,8(sp)
    80001ad2:	0800                	addi	s0,sp,16
  asm volatile("mv %0, tp" : "=r" (x) );
    80001ad4:	8512                	mv	a0,tp
  int id = r_tp();
  return id;
}
    80001ad6:	2501                	sext.w	a0,a0
    80001ad8:	6422                	ld	s0,8(sp)
    80001ada:	0141                	addi	sp,sp,16
    80001adc:	8082                	ret

0000000080001ade <mycpu>:

// Return this CPU's cpu struct.
// Interrupts must be disabled.
struct cpu*
mycpu(void)
{
    80001ade:	1141                	addi	sp,sp,-16
    80001ae0:	e422                	sd	s0,8(sp)
    80001ae2:	0800                	addi	s0,sp,16
    80001ae4:	8792                	mv	a5,tp
  int id = cpuid();
  struct cpu *c = &cpus[id];
    80001ae6:	2781                	sext.w	a5,a5
    80001ae8:	079e                	slli	a5,a5,0x7
  return c;
}
    80001aea:	0000f517          	auipc	a0,0xf
    80001aee:	11650513          	addi	a0,a0,278 # 80010c00 <cpus>
    80001af2:	953e                	add	a0,a0,a5
    80001af4:	6422                	ld	s0,8(sp)
    80001af6:	0141                	addi	sp,sp,16
    80001af8:	8082                	ret

0000000080001afa <myproc>:

// Return the current struct proc *, or zero if none.
struct proc*
myproc(void)
{
    80001afa:	1101                	addi	sp,sp,-32
    80001afc:	ec06                	sd	ra,24(sp)
    80001afe:	e822                	sd	s0,16(sp)
    80001b00:	e426                	sd	s1,8(sp)
    80001b02:	1000                	addi	s0,sp,32
  push_off();
    80001b04:	fffff097          	auipc	ra,0xfffff
    80001b08:	086080e7          	jalr	134(ra) # 80000b8a <push_off>
    80001b0c:	8792                	mv	a5,tp
  struct cpu *c = mycpu();
  struct proc *p = c->proc;
    80001b0e:	2781                	sext.w	a5,a5
    80001b10:	079e                	slli	a5,a5,0x7
    80001b12:	0000f717          	auipc	a4,0xf
    80001b16:	0be70713          	addi	a4,a4,190 # 80010bd0 <pid_lock>
    80001b1a:	97ba                	add	a5,a5,a4
    80001b1c:	7b84                	ld	s1,48(a5)
  pop_off();
    80001b1e:	fffff097          	auipc	ra,0xfffff
    80001b22:	10c080e7          	jalr	268(ra) # 80000c2a <pop_off>
  return p;
}
    80001b26:	8526                	mv	a0,s1
    80001b28:	60e2                	ld	ra,24(sp)
    80001b2a:	6442                	ld	s0,16(sp)
    80001b2c:	64a2                	ld	s1,8(sp)
    80001b2e:	6105                	addi	sp,sp,32
    80001b30:	8082                	ret

0000000080001b32 <forkret>:

// A fork child's very first scheduling by scheduler()
// will swtch to forkret.
void
forkret(void)
{
    80001b32:	1141                	addi	sp,sp,-16
    80001b34:	e406                	sd	ra,8(sp)
    80001b36:	e022                	sd	s0,0(sp)
    80001b38:	0800                	addi	s0,sp,16
  static int first = 1;

  // Still holding p->lock from scheduler.
  release(&myproc()->lock);
    80001b3a:	00000097          	auipc	ra,0x0
    80001b3e:	fc0080e7          	jalr	-64(ra) # 80001afa <myproc>
    80001b42:	fffff097          	auipc	ra,0xfffff
    80001b46:	148080e7          	jalr	328(ra) # 80000c8a <release>

  if (first) {
    80001b4a:	00007797          	auipc	a5,0x7
    80001b4e:	d767a783          	lw	a5,-650(a5) # 800088c0 <first.1>
    80001b52:	eb89                	bnez	a5,80001b64 <forkret+0x32>
    // be run from main().
    first = 0;
    fsinit(ROOTDEV);
  }

  usertrapret();
    80001b54:	00001097          	auipc	ra,0x1
    80001b58:	c5c080e7          	jalr	-932(ra) # 800027b0 <usertrapret>
}
    80001b5c:	60a2                	ld	ra,8(sp)
    80001b5e:	6402                	ld	s0,0(sp)
    80001b60:	0141                	addi	sp,sp,16
    80001b62:	8082                	ret
    first = 0;
    80001b64:	00007797          	auipc	a5,0x7
    80001b68:	d407ae23          	sw	zero,-676(a5) # 800088c0 <first.1>
    fsinit(ROOTDEV);
    80001b6c:	4505                	li	a0,1
    80001b6e:	00002097          	auipc	ra,0x2
    80001b72:	b32080e7          	jalr	-1230(ra) # 800036a0 <fsinit>
    80001b76:	bff9                	j	80001b54 <forkret+0x22>

0000000080001b78 <allocpid>:
{
    80001b78:	1101                	addi	sp,sp,-32
    80001b7a:	ec06                	sd	ra,24(sp)
    80001b7c:	e822                	sd	s0,16(sp)
    80001b7e:	e426                	sd	s1,8(sp)
    80001b80:	e04a                	sd	s2,0(sp)
    80001b82:	1000                	addi	s0,sp,32
  acquire(&pid_lock);
    80001b84:	0000f917          	auipc	s2,0xf
    80001b88:	04c90913          	addi	s2,s2,76 # 80010bd0 <pid_lock>
    80001b8c:	854a                	mv	a0,s2
    80001b8e:	fffff097          	auipc	ra,0xfffff
    80001b92:	048080e7          	jalr	72(ra) # 80000bd6 <acquire>
  pid = nextpid;
    80001b96:	00007797          	auipc	a5,0x7
    80001b9a:	d2e78793          	addi	a5,a5,-722 # 800088c4 <nextpid>
    80001b9e:	4384                	lw	s1,0(a5)
  nextpid = nextpid + 1;
    80001ba0:	0014871b          	addiw	a4,s1,1
    80001ba4:	c398                	sw	a4,0(a5)
  release(&pid_lock);
    80001ba6:	854a                	mv	a0,s2
    80001ba8:	fffff097          	auipc	ra,0xfffff
    80001bac:	0e2080e7          	jalr	226(ra) # 80000c8a <release>
}
    80001bb0:	8526                	mv	a0,s1
    80001bb2:	60e2                	ld	ra,24(sp)
    80001bb4:	6442                	ld	s0,16(sp)
    80001bb6:	64a2                	ld	s1,8(sp)
    80001bb8:	6902                	ld	s2,0(sp)
    80001bba:	6105                	addi	sp,sp,32
    80001bbc:	8082                	ret

0000000080001bbe <proc_pagetable>:
{
    80001bbe:	1101                	addi	sp,sp,-32
    80001bc0:	ec06                	sd	ra,24(sp)
    80001bc2:	e822                	sd	s0,16(sp)
    80001bc4:	e426                	sd	s1,8(sp)
    80001bc6:	e04a                	sd	s2,0(sp)
    80001bc8:	1000                	addi	s0,sp,32
    80001bca:	892a                	mv	s2,a0
  pagetable = uvmcreate();
    80001bcc:	fffff097          	auipc	ra,0xfffff
    80001bd0:	75c080e7          	jalr	1884(ra) # 80001328 <uvmcreate>
    80001bd4:	84aa                	mv	s1,a0
  if(pagetable == 0)
    80001bd6:	c121                	beqz	a0,80001c16 <proc_pagetable+0x58>
  if(mappages(pagetable, TRAMPOLINE, PGSIZE,
    80001bd8:	4729                	li	a4,10
    80001bda:	00005697          	auipc	a3,0x5
    80001bde:	42668693          	addi	a3,a3,1062 # 80007000 <_trampoline>
    80001be2:	6605                	lui	a2,0x1
    80001be4:	040005b7          	lui	a1,0x4000
    80001be8:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001bea:	05b2                	slli	a1,a1,0xc
    80001bec:	fffff097          	auipc	ra,0xfffff
    80001bf0:	4b2080e7          	jalr	1202(ra) # 8000109e <mappages>
    80001bf4:	02054863          	bltz	a0,80001c24 <proc_pagetable+0x66>
  if(mappages(pagetable, TRAPFRAME, PGSIZE,
    80001bf8:	4719                	li	a4,6
    80001bfa:	05893683          	ld	a3,88(s2)
    80001bfe:	6605                	lui	a2,0x1
    80001c00:	020005b7          	lui	a1,0x2000
    80001c04:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001c06:	05b6                	slli	a1,a1,0xd
    80001c08:	8526                	mv	a0,s1
    80001c0a:	fffff097          	auipc	ra,0xfffff
    80001c0e:	494080e7          	jalr	1172(ra) # 8000109e <mappages>
    80001c12:	02054163          	bltz	a0,80001c34 <proc_pagetable+0x76>
}
    80001c16:	8526                	mv	a0,s1
    80001c18:	60e2                	ld	ra,24(sp)
    80001c1a:	6442                	ld	s0,16(sp)
    80001c1c:	64a2                	ld	s1,8(sp)
    80001c1e:	6902                	ld	s2,0(sp)
    80001c20:	6105                	addi	sp,sp,32
    80001c22:	8082                	ret
    uvmfree(pagetable, 0);
    80001c24:	4581                	li	a1,0
    80001c26:	8526                	mv	a0,s1
    80001c28:	00000097          	auipc	ra,0x0
    80001c2c:	906080e7          	jalr	-1786(ra) # 8000152e <uvmfree>
    return 0;
    80001c30:	4481                	li	s1,0
    80001c32:	b7d5                	j	80001c16 <proc_pagetable+0x58>
    uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c34:	4681                	li	a3,0
    80001c36:	4605                	li	a2,1
    80001c38:	040005b7          	lui	a1,0x4000
    80001c3c:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c3e:	05b2                	slli	a1,a1,0xc
    80001c40:	8526                	mv	a0,s1
    80001c42:	fffff097          	auipc	ra,0xfffff
    80001c46:	622080e7          	jalr	1570(ra) # 80001264 <uvmunmap>
    uvmfree(pagetable, 0);
    80001c4a:	4581                	li	a1,0
    80001c4c:	8526                	mv	a0,s1
    80001c4e:	00000097          	auipc	ra,0x0
    80001c52:	8e0080e7          	jalr	-1824(ra) # 8000152e <uvmfree>
    return 0;
    80001c56:	4481                	li	s1,0
    80001c58:	bf7d                	j	80001c16 <proc_pagetable+0x58>

0000000080001c5a <proc_freepagetable>:
{
    80001c5a:	1101                	addi	sp,sp,-32
    80001c5c:	ec06                	sd	ra,24(sp)
    80001c5e:	e822                	sd	s0,16(sp)
    80001c60:	e426                	sd	s1,8(sp)
    80001c62:	e04a                	sd	s2,0(sp)
    80001c64:	1000                	addi	s0,sp,32
    80001c66:	84aa                	mv	s1,a0
    80001c68:	892e                	mv	s2,a1
  uvmunmap(pagetable, TRAMPOLINE, 1, 0);
    80001c6a:	4681                	li	a3,0
    80001c6c:	4605                	li	a2,1
    80001c6e:	040005b7          	lui	a1,0x4000
    80001c72:	15fd                	addi	a1,a1,-1 # 3ffffff <_entry-0x7c000001>
    80001c74:	05b2                	slli	a1,a1,0xc
    80001c76:	fffff097          	auipc	ra,0xfffff
    80001c7a:	5ee080e7          	jalr	1518(ra) # 80001264 <uvmunmap>
  uvmunmap(pagetable, TRAPFRAME, 1, 0);
    80001c7e:	4681                	li	a3,0
    80001c80:	4605                	li	a2,1
    80001c82:	020005b7          	lui	a1,0x2000
    80001c86:	15fd                	addi	a1,a1,-1 # 1ffffff <_entry-0x7e000001>
    80001c88:	05b6                	slli	a1,a1,0xd
    80001c8a:	8526                	mv	a0,s1
    80001c8c:	fffff097          	auipc	ra,0xfffff
    80001c90:	5d8080e7          	jalr	1496(ra) # 80001264 <uvmunmap>
  uvmfree(pagetable, sz);
    80001c94:	85ca                	mv	a1,s2
    80001c96:	8526                	mv	a0,s1
    80001c98:	00000097          	auipc	ra,0x0
    80001c9c:	896080e7          	jalr	-1898(ra) # 8000152e <uvmfree>
}
    80001ca0:	60e2                	ld	ra,24(sp)
    80001ca2:	6442                	ld	s0,16(sp)
    80001ca4:	64a2                	ld	s1,8(sp)
    80001ca6:	6902                	ld	s2,0(sp)
    80001ca8:	6105                	addi	sp,sp,32
    80001caa:	8082                	ret

0000000080001cac <freeproc>:
{
    80001cac:	1101                	addi	sp,sp,-32
    80001cae:	ec06                	sd	ra,24(sp)
    80001cb0:	e822                	sd	s0,16(sp)
    80001cb2:	e426                	sd	s1,8(sp)
    80001cb4:	1000                	addi	s0,sp,32
    80001cb6:	84aa                	mv	s1,a0
  if(p->trapframe)
    80001cb8:	6d28                	ld	a0,88(a0)
    80001cba:	c509                	beqz	a0,80001cc4 <freeproc+0x18>
    kfree((void*)p->trapframe);
    80001cbc:	fffff097          	auipc	ra,0xfffff
    80001cc0:	d2c080e7          	jalr	-724(ra) # 800009e8 <kfree>
  p->trapframe = 0;
    80001cc4:	0404bc23          	sd	zero,88(s1)
  if(p->pagetable)
    80001cc8:	68a8                	ld	a0,80(s1)
    80001cca:	c511                	beqz	a0,80001cd6 <freeproc+0x2a>
    proc_freepagetable(p->pagetable, p->sz);
    80001ccc:	64ac                	ld	a1,72(s1)
    80001cce:	00000097          	auipc	ra,0x0
    80001cd2:	f8c080e7          	jalr	-116(ra) # 80001c5a <proc_freepagetable>
  p->pagetable = 0;
    80001cd6:	0404b823          	sd	zero,80(s1)
  p->sz = 0;
    80001cda:	0404b423          	sd	zero,72(s1)
  p->pid = 0;
    80001cde:	0204a823          	sw	zero,48(s1)
  p->parent = 0;
    80001ce2:	0204bc23          	sd	zero,56(s1)
  p->name[0] = 0;
    80001ce6:	14048c23          	sb	zero,344(s1)
  p->chan = 0;
    80001cea:	0204b023          	sd	zero,32(s1)
  p->killed = 0;
    80001cee:	0204a423          	sw	zero,40(s1)
  p->xstate = 0;
    80001cf2:	0204a623          	sw	zero,44(s1)
  p->state = UNUSED;
    80001cf6:	0004ac23          	sw	zero,24(s1)
}
    80001cfa:	60e2                	ld	ra,24(sp)
    80001cfc:	6442                	ld	s0,16(sp)
    80001cfe:	64a2                	ld	s1,8(sp)
    80001d00:	6105                	addi	sp,sp,32
    80001d02:	8082                	ret

0000000080001d04 <allocproc>:
{
    80001d04:	1101                	addi	sp,sp,-32
    80001d06:	ec06                	sd	ra,24(sp)
    80001d08:	e822                	sd	s0,16(sp)
    80001d0a:	e426                	sd	s1,8(sp)
    80001d0c:	e04a                	sd	s2,0(sp)
    80001d0e:	1000                	addi	s0,sp,32
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d10:	0000f497          	auipc	s1,0xf
    80001d14:	2f048493          	addi	s1,s1,752 # 80011000 <proc>
    80001d18:	00015917          	auipc	s2,0x15
    80001d1c:	ce890913          	addi	s2,s2,-792 # 80016a00 <tickslock>
    acquire(&p->lock);
    80001d20:	8526                	mv	a0,s1
    80001d22:	fffff097          	auipc	ra,0xfffff
    80001d26:	eb4080e7          	jalr	-332(ra) # 80000bd6 <acquire>
    if(p->state == UNUSED) {
    80001d2a:	4c9c                	lw	a5,24(s1)
    80001d2c:	cf81                	beqz	a5,80001d44 <allocproc+0x40>
      release(&p->lock);
    80001d2e:	8526                	mv	a0,s1
    80001d30:	fffff097          	auipc	ra,0xfffff
    80001d34:	f5a080e7          	jalr	-166(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    80001d38:	16848493          	addi	s1,s1,360
    80001d3c:	ff2492e3          	bne	s1,s2,80001d20 <allocproc+0x1c>
  return 0;
    80001d40:	4481                	li	s1,0
    80001d42:	a889                	j	80001d94 <allocproc+0x90>
  p->pid = allocpid();
    80001d44:	00000097          	auipc	ra,0x0
    80001d48:	e34080e7          	jalr	-460(ra) # 80001b78 <allocpid>
    80001d4c:	d888                	sw	a0,48(s1)
  p->state = USED;
    80001d4e:	4785                	li	a5,1
    80001d50:	cc9c                	sw	a5,24(s1)
  if((p->trapframe = (struct trapframe *)kalloc()) == 0){
    80001d52:	fffff097          	auipc	ra,0xfffff
    80001d56:	d94080e7          	jalr	-620(ra) # 80000ae6 <kalloc>
    80001d5a:	892a                	mv	s2,a0
    80001d5c:	eca8                	sd	a0,88(s1)
    80001d5e:	c131                	beqz	a0,80001da2 <allocproc+0x9e>
  p->pagetable = proc_pagetable(p);
    80001d60:	8526                	mv	a0,s1
    80001d62:	00000097          	auipc	ra,0x0
    80001d66:	e5c080e7          	jalr	-420(ra) # 80001bbe <proc_pagetable>
    80001d6a:	892a                	mv	s2,a0
    80001d6c:	e8a8                	sd	a0,80(s1)
  if(p->pagetable == 0){
    80001d6e:	c531                	beqz	a0,80001dba <allocproc+0xb6>
  memset(&p->context, 0, sizeof(p->context));
    80001d70:	07000613          	li	a2,112
    80001d74:	4581                	li	a1,0
    80001d76:	06048513          	addi	a0,s1,96
    80001d7a:	fffff097          	auipc	ra,0xfffff
    80001d7e:	f58080e7          	jalr	-168(ra) # 80000cd2 <memset>
  p->context.ra = (uint64)forkret;
    80001d82:	00000797          	auipc	a5,0x0
    80001d86:	db078793          	addi	a5,a5,-592 # 80001b32 <forkret>
    80001d8a:	f0bc                	sd	a5,96(s1)
  p->context.sp = p->kstack + PGSIZE;
    80001d8c:	60bc                	ld	a5,64(s1)
    80001d8e:	6705                	lui	a4,0x1
    80001d90:	97ba                	add	a5,a5,a4
    80001d92:	f4bc                	sd	a5,104(s1)
}
    80001d94:	8526                	mv	a0,s1
    80001d96:	60e2                	ld	ra,24(sp)
    80001d98:	6442                	ld	s0,16(sp)
    80001d9a:	64a2                	ld	s1,8(sp)
    80001d9c:	6902                	ld	s2,0(sp)
    80001d9e:	6105                	addi	sp,sp,32
    80001da0:	8082                	ret
    freeproc(p);
    80001da2:	8526                	mv	a0,s1
    80001da4:	00000097          	auipc	ra,0x0
    80001da8:	f08080e7          	jalr	-248(ra) # 80001cac <freeproc>
    release(&p->lock);
    80001dac:	8526                	mv	a0,s1
    80001dae:	fffff097          	auipc	ra,0xfffff
    80001db2:	edc080e7          	jalr	-292(ra) # 80000c8a <release>
    return 0;
    80001db6:	84ca                	mv	s1,s2
    80001db8:	bff1                	j	80001d94 <allocproc+0x90>
    freeproc(p);
    80001dba:	8526                	mv	a0,s1
    80001dbc:	00000097          	auipc	ra,0x0
    80001dc0:	ef0080e7          	jalr	-272(ra) # 80001cac <freeproc>
    release(&p->lock);
    80001dc4:	8526                	mv	a0,s1
    80001dc6:	fffff097          	auipc	ra,0xfffff
    80001dca:	ec4080e7          	jalr	-316(ra) # 80000c8a <release>
    return 0;
    80001dce:	84ca                	mv	s1,s2
    80001dd0:	b7d1                	j	80001d94 <allocproc+0x90>

0000000080001dd2 <userinit>:
{
    80001dd2:	1101                	addi	sp,sp,-32
    80001dd4:	ec06                	sd	ra,24(sp)
    80001dd6:	e822                	sd	s0,16(sp)
    80001dd8:	e426                	sd	s1,8(sp)
    80001dda:	1000                	addi	s0,sp,32
  p = allocproc();
    80001ddc:	00000097          	auipc	ra,0x0
    80001de0:	f28080e7          	jalr	-216(ra) # 80001d04 <allocproc>
    80001de4:	84aa                	mv	s1,a0
  initproc = p;
    80001de6:	00007797          	auipc	a5,0x7
    80001dea:	b6a7b923          	sd	a0,-1166(a5) # 80008958 <initproc>
  uvmfirst(p->pagetable, initcode, sizeof(initcode));
    80001dee:	03400613          	li	a2,52
    80001df2:	00007597          	auipc	a1,0x7
    80001df6:	ade58593          	addi	a1,a1,-1314 # 800088d0 <initcode>
    80001dfa:	6928                	ld	a0,80(a0)
    80001dfc:	fffff097          	auipc	ra,0xfffff
    80001e00:	55a080e7          	jalr	1370(ra) # 80001356 <uvmfirst>
  p->sz = PGSIZE;
    80001e04:	6785                	lui	a5,0x1
    80001e06:	e4bc                	sd	a5,72(s1)
  p->trapframe->epc = 0;      // user program counter
    80001e08:	6cb8                	ld	a4,88(s1)
    80001e0a:	00073c23          	sd	zero,24(a4) # 1018 <_entry-0x7fffefe8>
  p->trapframe->sp = PGSIZE;  // user stack pointer
    80001e0e:	6cb8                	ld	a4,88(s1)
    80001e10:	fb1c                	sd	a5,48(a4)
  safestrcpy(p->name, "initcode", sizeof(p->name));
    80001e12:	4641                	li	a2,16
    80001e14:	00006597          	auipc	a1,0x6
    80001e18:	43458593          	addi	a1,a1,1076 # 80008248 <digits+0x208>
    80001e1c:	15848513          	addi	a0,s1,344
    80001e20:	fffff097          	auipc	ra,0xfffff
    80001e24:	ffc080e7          	jalr	-4(ra) # 80000e1c <safestrcpy>
  p->cwd = namei("/");
    80001e28:	00006517          	auipc	a0,0x6
    80001e2c:	43050513          	addi	a0,a0,1072 # 80008258 <digits+0x218>
    80001e30:	00002097          	auipc	ra,0x2
    80001e34:	29a080e7          	jalr	666(ra) # 800040ca <namei>
    80001e38:	14a4b823          	sd	a0,336(s1)
  p->state = RUNNABLE;
    80001e3c:	478d                	li	a5,3
    80001e3e:	cc9c                	sw	a5,24(s1)
  release(&p->lock);
    80001e40:	8526                	mv	a0,s1
    80001e42:	fffff097          	auipc	ra,0xfffff
    80001e46:	e48080e7          	jalr	-440(ra) # 80000c8a <release>
}
    80001e4a:	60e2                	ld	ra,24(sp)
    80001e4c:	6442                	ld	s0,16(sp)
    80001e4e:	64a2                	ld	s1,8(sp)
    80001e50:	6105                	addi	sp,sp,32
    80001e52:	8082                	ret

0000000080001e54 <growproc>:
{
    80001e54:	1101                	addi	sp,sp,-32
    80001e56:	ec06                	sd	ra,24(sp)
    80001e58:	e822                	sd	s0,16(sp)
    80001e5a:	e426                	sd	s1,8(sp)
    80001e5c:	e04a                	sd	s2,0(sp)
    80001e5e:	1000                	addi	s0,sp,32
    80001e60:	892a                	mv	s2,a0
  struct proc *p = myproc();
    80001e62:	00000097          	auipc	ra,0x0
    80001e66:	c98080e7          	jalr	-872(ra) # 80001afa <myproc>
    80001e6a:	84aa                	mv	s1,a0
  sz = p->sz;
    80001e6c:	652c                	ld	a1,72(a0)
  if(n > 0){
    80001e6e:	01204c63          	bgtz	s2,80001e86 <growproc+0x32>
  } else if(n < 0){
    80001e72:	02094663          	bltz	s2,80001e9e <growproc+0x4a>
  p->sz = sz;
    80001e76:	e4ac                	sd	a1,72(s1)
  return 0;
    80001e78:	4501                	li	a0,0
}
    80001e7a:	60e2                	ld	ra,24(sp)
    80001e7c:	6442                	ld	s0,16(sp)
    80001e7e:	64a2                	ld	s1,8(sp)
    80001e80:	6902                	ld	s2,0(sp)
    80001e82:	6105                	addi	sp,sp,32
    80001e84:	8082                	ret
    if((sz = uvmalloc(p->pagetable, sz, sz + n, PTE_W)) == 0) {
    80001e86:	4691                	li	a3,4
    80001e88:	00b90633          	add	a2,s2,a1
    80001e8c:	6928                	ld	a0,80(a0)
    80001e8e:	fffff097          	auipc	ra,0xfffff
    80001e92:	582080e7          	jalr	1410(ra) # 80001410 <uvmalloc>
    80001e96:	85aa                	mv	a1,a0
    80001e98:	fd79                	bnez	a0,80001e76 <growproc+0x22>
      return -1;
    80001e9a:	557d                	li	a0,-1
    80001e9c:	bff9                	j	80001e7a <growproc+0x26>
    sz = uvmdealloc(p->pagetable, sz, sz + n);
    80001e9e:	00b90633          	add	a2,s2,a1
    80001ea2:	6928                	ld	a0,80(a0)
    80001ea4:	fffff097          	auipc	ra,0xfffff
    80001ea8:	524080e7          	jalr	1316(ra) # 800013c8 <uvmdealloc>
    80001eac:	85aa                	mv	a1,a0
    80001eae:	b7e1                	j	80001e76 <growproc+0x22>

0000000080001eb0 <fork>:
{
    80001eb0:	7139                	addi	sp,sp,-64
    80001eb2:	fc06                	sd	ra,56(sp)
    80001eb4:	f822                	sd	s0,48(sp)
    80001eb6:	f426                	sd	s1,40(sp)
    80001eb8:	f04a                	sd	s2,32(sp)
    80001eba:	ec4e                	sd	s3,24(sp)
    80001ebc:	e852                	sd	s4,16(sp)
    80001ebe:	e456                	sd	s5,8(sp)
    80001ec0:	0080                	addi	s0,sp,64
  struct proc *p = myproc();
    80001ec2:	00000097          	auipc	ra,0x0
    80001ec6:	c38080e7          	jalr	-968(ra) # 80001afa <myproc>
    80001eca:	8aaa                	mv	s5,a0
  if((np = allocproc()) == 0){
    80001ecc:	00000097          	auipc	ra,0x0
    80001ed0:	e38080e7          	jalr	-456(ra) # 80001d04 <allocproc>
    80001ed4:	10050c63          	beqz	a0,80001fec <fork+0x13c>
    80001ed8:	8a2a                	mv	s4,a0
  if(uvmcopy(p->pagetable, np->pagetable, p->sz) < 0){
    80001eda:	048ab603          	ld	a2,72(s5)
    80001ede:	692c                	ld	a1,80(a0)
    80001ee0:	050ab503          	ld	a0,80(s5)
    80001ee4:	fffff097          	auipc	ra,0xfffff
    80001ee8:	684080e7          	jalr	1668(ra) # 80001568 <uvmcopy>
    80001eec:	04054863          	bltz	a0,80001f3c <fork+0x8c>
  np->sz = p->sz;
    80001ef0:	048ab783          	ld	a5,72(s5)
    80001ef4:	04fa3423          	sd	a5,72(s4)
  *(np->trapframe) = *(p->trapframe);
    80001ef8:	058ab683          	ld	a3,88(s5)
    80001efc:	87b6                	mv	a5,a3
    80001efe:	058a3703          	ld	a4,88(s4)
    80001f02:	12068693          	addi	a3,a3,288
    80001f06:	0007b803          	ld	a6,0(a5) # 1000 <_entry-0x7ffff000>
    80001f0a:	6788                	ld	a0,8(a5)
    80001f0c:	6b8c                	ld	a1,16(a5)
    80001f0e:	6f90                	ld	a2,24(a5)
    80001f10:	01073023          	sd	a6,0(a4)
    80001f14:	e708                	sd	a0,8(a4)
    80001f16:	eb0c                	sd	a1,16(a4)
    80001f18:	ef10                	sd	a2,24(a4)
    80001f1a:	02078793          	addi	a5,a5,32
    80001f1e:	02070713          	addi	a4,a4,32
    80001f22:	fed792e3          	bne	a5,a3,80001f06 <fork+0x56>
  np->trapframe->a0 = 0;
    80001f26:	058a3783          	ld	a5,88(s4)
    80001f2a:	0607b823          	sd	zero,112(a5)
  for(i = 0; i < NOFILE; i++)
    80001f2e:	0d0a8493          	addi	s1,s5,208
    80001f32:	0d0a0913          	addi	s2,s4,208
    80001f36:	150a8993          	addi	s3,s5,336
    80001f3a:	a00d                	j	80001f5c <fork+0xac>
    freeproc(np);
    80001f3c:	8552                	mv	a0,s4
    80001f3e:	00000097          	auipc	ra,0x0
    80001f42:	d6e080e7          	jalr	-658(ra) # 80001cac <freeproc>
    release(&np->lock);
    80001f46:	8552                	mv	a0,s4
    80001f48:	fffff097          	auipc	ra,0xfffff
    80001f4c:	d42080e7          	jalr	-702(ra) # 80000c8a <release>
    return -1;
    80001f50:	597d                	li	s2,-1
    80001f52:	a059                	j	80001fd8 <fork+0x128>
  for(i = 0; i < NOFILE; i++)
    80001f54:	04a1                	addi	s1,s1,8
    80001f56:	0921                	addi	s2,s2,8
    80001f58:	01348b63          	beq	s1,s3,80001f6e <fork+0xbe>
    if(p->ofile[i])
    80001f5c:	6088                	ld	a0,0(s1)
    80001f5e:	d97d                	beqz	a0,80001f54 <fork+0xa4>
      np->ofile[i] = filedup(p->ofile[i]);
    80001f60:	00003097          	auipc	ra,0x3
    80001f64:	800080e7          	jalr	-2048(ra) # 80004760 <filedup>
    80001f68:	00a93023          	sd	a0,0(s2)
    80001f6c:	b7e5                	j	80001f54 <fork+0xa4>
  np->cwd = idup(p->cwd);
    80001f6e:	150ab503          	ld	a0,336(s5)
    80001f72:	00002097          	auipc	ra,0x2
    80001f76:	96e080e7          	jalr	-1682(ra) # 800038e0 <idup>
    80001f7a:	14aa3823          	sd	a0,336(s4)
  safestrcpy(np->name, p->name, sizeof(p->name));
    80001f7e:	4641                	li	a2,16
    80001f80:	158a8593          	addi	a1,s5,344
    80001f84:	158a0513          	addi	a0,s4,344
    80001f88:	fffff097          	auipc	ra,0xfffff
    80001f8c:	e94080e7          	jalr	-364(ra) # 80000e1c <safestrcpy>
  pid = np->pid;
    80001f90:	030a2903          	lw	s2,48(s4)
  release(&np->lock);
    80001f94:	8552                	mv	a0,s4
    80001f96:	fffff097          	auipc	ra,0xfffff
    80001f9a:	cf4080e7          	jalr	-780(ra) # 80000c8a <release>
  acquire(&wait_lock);
    80001f9e:	0000f497          	auipc	s1,0xf
    80001fa2:	c4a48493          	addi	s1,s1,-950 # 80010be8 <wait_lock>
    80001fa6:	8526                	mv	a0,s1
    80001fa8:	fffff097          	auipc	ra,0xfffff
    80001fac:	c2e080e7          	jalr	-978(ra) # 80000bd6 <acquire>
  np->parent = p;
    80001fb0:	035a3c23          	sd	s5,56(s4)
  release(&wait_lock);
    80001fb4:	8526                	mv	a0,s1
    80001fb6:	fffff097          	auipc	ra,0xfffff
    80001fba:	cd4080e7          	jalr	-812(ra) # 80000c8a <release>
  acquire(&np->lock);
    80001fbe:	8552                	mv	a0,s4
    80001fc0:	fffff097          	auipc	ra,0xfffff
    80001fc4:	c16080e7          	jalr	-1002(ra) # 80000bd6 <acquire>
  np->state = RUNNABLE;
    80001fc8:	478d                	li	a5,3
    80001fca:	00fa2c23          	sw	a5,24(s4)
  release(&np->lock);
    80001fce:	8552                	mv	a0,s4
    80001fd0:	fffff097          	auipc	ra,0xfffff
    80001fd4:	cba080e7          	jalr	-838(ra) # 80000c8a <release>
}
    80001fd8:	854a                	mv	a0,s2
    80001fda:	70e2                	ld	ra,56(sp)
    80001fdc:	7442                	ld	s0,48(sp)
    80001fde:	74a2                	ld	s1,40(sp)
    80001fe0:	7902                	ld	s2,32(sp)
    80001fe2:	69e2                	ld	s3,24(sp)
    80001fe4:	6a42                	ld	s4,16(sp)
    80001fe6:	6aa2                	ld	s5,8(sp)
    80001fe8:	6121                	addi	sp,sp,64
    80001fea:	8082                	ret
    return -1;
    80001fec:	597d                	li	s2,-1
    80001fee:	b7ed                	j	80001fd8 <fork+0x128>

0000000080001ff0 <scheduler>:
{
    80001ff0:	7139                	addi	sp,sp,-64
    80001ff2:	fc06                	sd	ra,56(sp)
    80001ff4:	f822                	sd	s0,48(sp)
    80001ff6:	f426                	sd	s1,40(sp)
    80001ff8:	f04a                	sd	s2,32(sp)
    80001ffa:	ec4e                	sd	s3,24(sp)
    80001ffc:	e852                	sd	s4,16(sp)
    80001ffe:	e456                	sd	s5,8(sp)
    80002000:	e05a                	sd	s6,0(sp)
    80002002:	0080                	addi	s0,sp,64
    80002004:	8792                	mv	a5,tp
  int id = r_tp();
    80002006:	2781                	sext.w	a5,a5
  c->proc = 0;
    80002008:	00779a93          	slli	s5,a5,0x7
    8000200c:	0000f717          	auipc	a4,0xf
    80002010:	bc470713          	addi	a4,a4,-1084 # 80010bd0 <pid_lock>
    80002014:	9756                	add	a4,a4,s5
    80002016:	02073823          	sd	zero,48(a4)
        swtch(&c->context, &p->context);
    8000201a:	0000f717          	auipc	a4,0xf
    8000201e:	bee70713          	addi	a4,a4,-1042 # 80010c08 <cpus+0x8>
    80002022:	9aba                	add	s5,s5,a4
      if(p->state == RUNNABLE) {
    80002024:	498d                	li	s3,3
        p->state = RUNNING;
    80002026:	4b11                	li	s6,4
        c->proc = p;
    80002028:	079e                	slli	a5,a5,0x7
    8000202a:	0000fa17          	auipc	s4,0xf
    8000202e:	ba6a0a13          	addi	s4,s4,-1114 # 80010bd0 <pid_lock>
    80002032:	9a3e                	add	s4,s4,a5
    for(p = proc; p < &proc[NPROC]; p++) {
    80002034:	00015917          	auipc	s2,0x15
    80002038:	9cc90913          	addi	s2,s2,-1588 # 80016a00 <tickslock>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000203c:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    80002040:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002044:	10079073          	csrw	sstatus,a5
    80002048:	0000f497          	auipc	s1,0xf
    8000204c:	fb848493          	addi	s1,s1,-72 # 80011000 <proc>
    80002050:	a811                	j	80002064 <scheduler+0x74>
      release(&p->lock);
    80002052:	8526                	mv	a0,s1
    80002054:	fffff097          	auipc	ra,0xfffff
    80002058:	c36080e7          	jalr	-970(ra) # 80000c8a <release>
    for(p = proc; p < &proc[NPROC]; p++) {
    8000205c:	16848493          	addi	s1,s1,360
    80002060:	fd248ee3          	beq	s1,s2,8000203c <scheduler+0x4c>
      acquire(&p->lock);
    80002064:	8526                	mv	a0,s1
    80002066:	fffff097          	auipc	ra,0xfffff
    8000206a:	b70080e7          	jalr	-1168(ra) # 80000bd6 <acquire>
      if(p->state == RUNNABLE) {
    8000206e:	4c9c                	lw	a5,24(s1)
    80002070:	ff3791e3          	bne	a5,s3,80002052 <scheduler+0x62>
        p->state = RUNNING;
    80002074:	0164ac23          	sw	s6,24(s1)
        c->proc = p;
    80002078:	029a3823          	sd	s1,48(s4)
        swtch(&c->context, &p->context);
    8000207c:	06048593          	addi	a1,s1,96
    80002080:	8556                	mv	a0,s5
    80002082:	00000097          	auipc	ra,0x0
    80002086:	684080e7          	jalr	1668(ra) # 80002706 <swtch>
        c->proc = 0;
    8000208a:	020a3823          	sd	zero,48(s4)
    8000208e:	b7d1                	j	80002052 <scheduler+0x62>

0000000080002090 <sched>:
{
    80002090:	7179                	addi	sp,sp,-48
    80002092:	f406                	sd	ra,40(sp)
    80002094:	f022                	sd	s0,32(sp)
    80002096:	ec26                	sd	s1,24(sp)
    80002098:	e84a                	sd	s2,16(sp)
    8000209a:	e44e                	sd	s3,8(sp)
    8000209c:	1800                	addi	s0,sp,48
  struct proc *p = myproc();
    8000209e:	00000097          	auipc	ra,0x0
    800020a2:	a5c080e7          	jalr	-1444(ra) # 80001afa <myproc>
    800020a6:	84aa                	mv	s1,a0
  if(!holding(&p->lock))
    800020a8:	fffff097          	auipc	ra,0xfffff
    800020ac:	ab4080e7          	jalr	-1356(ra) # 80000b5c <holding>
    800020b0:	c93d                	beqz	a0,80002126 <sched+0x96>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020b2:	8792                	mv	a5,tp
  if(mycpu()->noff != 1)
    800020b4:	2781                	sext.w	a5,a5
    800020b6:	079e                	slli	a5,a5,0x7
    800020b8:	0000f717          	auipc	a4,0xf
    800020bc:	b1870713          	addi	a4,a4,-1256 # 80010bd0 <pid_lock>
    800020c0:	97ba                	add	a5,a5,a4
    800020c2:	0a87a703          	lw	a4,168(a5)
    800020c6:	4785                	li	a5,1
    800020c8:	06f71763          	bne	a4,a5,80002136 <sched+0xa6>
  if(p->state == RUNNING)
    800020cc:	4c98                	lw	a4,24(s1)
    800020ce:	4791                	li	a5,4
    800020d0:	06f70b63          	beq	a4,a5,80002146 <sched+0xb6>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800020d4:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    800020d8:	8b89                	andi	a5,a5,2
  if(intr_get())
    800020da:	efb5                	bnez	a5,80002156 <sched+0xc6>
  asm volatile("mv %0, tp" : "=r" (x) );
    800020dc:	8792                	mv	a5,tp
  intena = mycpu()->intena;
    800020de:	0000f917          	auipc	s2,0xf
    800020e2:	af290913          	addi	s2,s2,-1294 # 80010bd0 <pid_lock>
    800020e6:	2781                	sext.w	a5,a5
    800020e8:	079e                	slli	a5,a5,0x7
    800020ea:	97ca                	add	a5,a5,s2
    800020ec:	0ac7a983          	lw	s3,172(a5)
    800020f0:	8792                	mv	a5,tp
  swtch(&p->context, &mycpu()->context);
    800020f2:	2781                	sext.w	a5,a5
    800020f4:	079e                	slli	a5,a5,0x7
    800020f6:	0000f597          	auipc	a1,0xf
    800020fa:	b1258593          	addi	a1,a1,-1262 # 80010c08 <cpus+0x8>
    800020fe:	95be                	add	a1,a1,a5
    80002100:	06048513          	addi	a0,s1,96
    80002104:	00000097          	auipc	ra,0x0
    80002108:	602080e7          	jalr	1538(ra) # 80002706 <swtch>
    8000210c:	8792                	mv	a5,tp
  mycpu()->intena = intena;
    8000210e:	2781                	sext.w	a5,a5
    80002110:	079e                	slli	a5,a5,0x7
    80002112:	993e                	add	s2,s2,a5
    80002114:	0b392623          	sw	s3,172(s2)
}
    80002118:	70a2                	ld	ra,40(sp)
    8000211a:	7402                	ld	s0,32(sp)
    8000211c:	64e2                	ld	s1,24(sp)
    8000211e:	6942                	ld	s2,16(sp)
    80002120:	69a2                	ld	s3,8(sp)
    80002122:	6145                	addi	sp,sp,48
    80002124:	8082                	ret
    panic("sched p->lock");
    80002126:	00006517          	auipc	a0,0x6
    8000212a:	13a50513          	addi	a0,a0,314 # 80008260 <digits+0x220>
    8000212e:	ffffe097          	auipc	ra,0xffffe
    80002132:	412080e7          	jalr	1042(ra) # 80000540 <panic>
    panic("sched locks");
    80002136:	00006517          	auipc	a0,0x6
    8000213a:	13a50513          	addi	a0,a0,314 # 80008270 <digits+0x230>
    8000213e:	ffffe097          	auipc	ra,0xffffe
    80002142:	402080e7          	jalr	1026(ra) # 80000540 <panic>
    panic("sched running");
    80002146:	00006517          	auipc	a0,0x6
    8000214a:	13a50513          	addi	a0,a0,314 # 80008280 <digits+0x240>
    8000214e:	ffffe097          	auipc	ra,0xffffe
    80002152:	3f2080e7          	jalr	1010(ra) # 80000540 <panic>
    panic("sched interruptible");
    80002156:	00006517          	auipc	a0,0x6
    8000215a:	13a50513          	addi	a0,a0,314 # 80008290 <digits+0x250>
    8000215e:	ffffe097          	auipc	ra,0xffffe
    80002162:	3e2080e7          	jalr	994(ra) # 80000540 <panic>

0000000080002166 <yield>:
{
    80002166:	1101                	addi	sp,sp,-32
    80002168:	ec06                	sd	ra,24(sp)
    8000216a:	e822                	sd	s0,16(sp)
    8000216c:	e426                	sd	s1,8(sp)
    8000216e:	1000                	addi	s0,sp,32
  struct proc *p = myproc();
    80002170:	00000097          	auipc	ra,0x0
    80002174:	98a080e7          	jalr	-1654(ra) # 80001afa <myproc>
    80002178:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000217a:	fffff097          	auipc	ra,0xfffff
    8000217e:	a5c080e7          	jalr	-1444(ra) # 80000bd6 <acquire>
  p->state = RUNNABLE;
    80002182:	478d                	li	a5,3
    80002184:	cc9c                	sw	a5,24(s1)
  sched();
    80002186:	00000097          	auipc	ra,0x0
    8000218a:	f0a080e7          	jalr	-246(ra) # 80002090 <sched>
  release(&p->lock);
    8000218e:	8526                	mv	a0,s1
    80002190:	fffff097          	auipc	ra,0xfffff
    80002194:	afa080e7          	jalr	-1286(ra) # 80000c8a <release>
}
    80002198:	60e2                	ld	ra,24(sp)
    8000219a:	6442                	ld	s0,16(sp)
    8000219c:	64a2                	ld	s1,8(sp)
    8000219e:	6105                	addi	sp,sp,32
    800021a0:	8082                	ret

00000000800021a2 <sleep>:

// Atomically release lock and sleep on chan.
// Reacquires lock when awakened.
void
sleep(void *chan, struct spinlock *lk)
{
    800021a2:	7179                	addi	sp,sp,-48
    800021a4:	f406                	sd	ra,40(sp)
    800021a6:	f022                	sd	s0,32(sp)
    800021a8:	ec26                	sd	s1,24(sp)
    800021aa:	e84a                	sd	s2,16(sp)
    800021ac:	e44e                	sd	s3,8(sp)
    800021ae:	1800                	addi	s0,sp,48
    800021b0:	89aa                	mv	s3,a0
    800021b2:	892e                	mv	s2,a1
  struct proc *p = myproc();
    800021b4:	00000097          	auipc	ra,0x0
    800021b8:	946080e7          	jalr	-1722(ra) # 80001afa <myproc>
    800021bc:	84aa                	mv	s1,a0
  // Once we hold p->lock, we can be
  // guaranteed that we won't miss any wakeup
  // (wakeup locks p->lock),
  // so it's okay to release lk.

  acquire(&p->lock);  //DOC: sleeplock1
    800021be:	fffff097          	auipc	ra,0xfffff
    800021c2:	a18080e7          	jalr	-1512(ra) # 80000bd6 <acquire>
  release(lk);
    800021c6:	854a                	mv	a0,s2
    800021c8:	fffff097          	auipc	ra,0xfffff
    800021cc:	ac2080e7          	jalr	-1342(ra) # 80000c8a <release>

  // Go to sleep.
  p->chan = chan;
    800021d0:	0334b023          	sd	s3,32(s1)
  p->state = SLEEPING;
    800021d4:	4789                	li	a5,2
    800021d6:	cc9c                	sw	a5,24(s1)

  sched();
    800021d8:	00000097          	auipc	ra,0x0
    800021dc:	eb8080e7          	jalr	-328(ra) # 80002090 <sched>

  // Tidy up.
  p->chan = 0;
    800021e0:	0204b023          	sd	zero,32(s1)

  // Reacquire original lock.
  release(&p->lock);
    800021e4:	8526                	mv	a0,s1
    800021e6:	fffff097          	auipc	ra,0xfffff
    800021ea:	aa4080e7          	jalr	-1372(ra) # 80000c8a <release>
  acquire(lk);
    800021ee:	854a                	mv	a0,s2
    800021f0:	fffff097          	auipc	ra,0xfffff
    800021f4:	9e6080e7          	jalr	-1562(ra) # 80000bd6 <acquire>
}
    800021f8:	70a2                	ld	ra,40(sp)
    800021fa:	7402                	ld	s0,32(sp)
    800021fc:	64e2                	ld	s1,24(sp)
    800021fe:	6942                	ld	s2,16(sp)
    80002200:	69a2                	ld	s3,8(sp)
    80002202:	6145                	addi	sp,sp,48
    80002204:	8082                	ret

0000000080002206 <wakeup>:

// Wake up all processes sleeping on chan.
// Must be called without any p->lock.
void
wakeup(void *chan)
{
    80002206:	7139                	addi	sp,sp,-64
    80002208:	fc06                	sd	ra,56(sp)
    8000220a:	f822                	sd	s0,48(sp)
    8000220c:	f426                	sd	s1,40(sp)
    8000220e:	f04a                	sd	s2,32(sp)
    80002210:	ec4e                	sd	s3,24(sp)
    80002212:	e852                	sd	s4,16(sp)
    80002214:	e456                	sd	s5,8(sp)
    80002216:	0080                	addi	s0,sp,64
    80002218:	8a2a                	mv	s4,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++) {
    8000221a:	0000f497          	auipc	s1,0xf
    8000221e:	de648493          	addi	s1,s1,-538 # 80011000 <proc>
    if(p != myproc()){
      acquire(&p->lock);
      if(p->state == SLEEPING && p->chan == chan) {
    80002222:	4989                	li	s3,2
        p->state = RUNNABLE;
    80002224:	4a8d                	li	s5,3
  for(p = proc; p < &proc[NPROC]; p++) {
    80002226:	00014917          	auipc	s2,0x14
    8000222a:	7da90913          	addi	s2,s2,2010 # 80016a00 <tickslock>
    8000222e:	a811                	j	80002242 <wakeup+0x3c>
      }
      release(&p->lock);
    80002230:	8526                	mv	a0,s1
    80002232:	fffff097          	auipc	ra,0xfffff
    80002236:	a58080e7          	jalr	-1448(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++) {
    8000223a:	16848493          	addi	s1,s1,360
    8000223e:	03248663          	beq	s1,s2,8000226a <wakeup+0x64>
    if(p != myproc()){
    80002242:	00000097          	auipc	ra,0x0
    80002246:	8b8080e7          	jalr	-1864(ra) # 80001afa <myproc>
    8000224a:	fea488e3          	beq	s1,a0,8000223a <wakeup+0x34>
      acquire(&p->lock);
    8000224e:	8526                	mv	a0,s1
    80002250:	fffff097          	auipc	ra,0xfffff
    80002254:	986080e7          	jalr	-1658(ra) # 80000bd6 <acquire>
      if(p->state == SLEEPING && p->chan == chan) {
    80002258:	4c9c                	lw	a5,24(s1)
    8000225a:	fd379be3          	bne	a5,s3,80002230 <wakeup+0x2a>
    8000225e:	709c                	ld	a5,32(s1)
    80002260:	fd4798e3          	bne	a5,s4,80002230 <wakeup+0x2a>
        p->state = RUNNABLE;
    80002264:	0154ac23          	sw	s5,24(s1)
    80002268:	b7e1                	j	80002230 <wakeup+0x2a>
    }
  }
}
    8000226a:	70e2                	ld	ra,56(sp)
    8000226c:	7442                	ld	s0,48(sp)
    8000226e:	74a2                	ld	s1,40(sp)
    80002270:	7902                	ld	s2,32(sp)
    80002272:	69e2                	ld	s3,24(sp)
    80002274:	6a42                	ld	s4,16(sp)
    80002276:	6aa2                	ld	s5,8(sp)
    80002278:	6121                	addi	sp,sp,64
    8000227a:	8082                	ret

000000008000227c <reparent>:
{
    8000227c:	7179                	addi	sp,sp,-48
    8000227e:	f406                	sd	ra,40(sp)
    80002280:	f022                	sd	s0,32(sp)
    80002282:	ec26                	sd	s1,24(sp)
    80002284:	e84a                	sd	s2,16(sp)
    80002286:	e44e                	sd	s3,8(sp)
    80002288:	e052                	sd	s4,0(sp)
    8000228a:	1800                	addi	s0,sp,48
    8000228c:	892a                	mv	s2,a0
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000228e:	0000f497          	auipc	s1,0xf
    80002292:	d7248493          	addi	s1,s1,-654 # 80011000 <proc>
      pp->parent = initproc;
    80002296:	00006a17          	auipc	s4,0x6
    8000229a:	6c2a0a13          	addi	s4,s4,1730 # 80008958 <initproc>
  for(pp = proc; pp < &proc[NPROC]; pp++){
    8000229e:	00014997          	auipc	s3,0x14
    800022a2:	76298993          	addi	s3,s3,1890 # 80016a00 <tickslock>
    800022a6:	a029                	j	800022b0 <reparent+0x34>
    800022a8:	16848493          	addi	s1,s1,360
    800022ac:	01348d63          	beq	s1,s3,800022c6 <reparent+0x4a>
    if(pp->parent == p){
    800022b0:	7c9c                	ld	a5,56(s1)
    800022b2:	ff279be3          	bne	a5,s2,800022a8 <reparent+0x2c>
      pp->parent = initproc;
    800022b6:	000a3503          	ld	a0,0(s4)
    800022ba:	fc88                	sd	a0,56(s1)
      wakeup(initproc);
    800022bc:	00000097          	auipc	ra,0x0
    800022c0:	f4a080e7          	jalr	-182(ra) # 80002206 <wakeup>
    800022c4:	b7d5                	j	800022a8 <reparent+0x2c>
}
    800022c6:	70a2                	ld	ra,40(sp)
    800022c8:	7402                	ld	s0,32(sp)
    800022ca:	64e2                	ld	s1,24(sp)
    800022cc:	6942                	ld	s2,16(sp)
    800022ce:	69a2                	ld	s3,8(sp)
    800022d0:	6a02                	ld	s4,0(sp)
    800022d2:	6145                	addi	sp,sp,48
    800022d4:	8082                	ret

00000000800022d6 <exit>:
{
    800022d6:	7179                	addi	sp,sp,-48
    800022d8:	f406                	sd	ra,40(sp)
    800022da:	f022                	sd	s0,32(sp)
    800022dc:	ec26                	sd	s1,24(sp)
    800022de:	e84a                	sd	s2,16(sp)
    800022e0:	e44e                	sd	s3,8(sp)
    800022e2:	e052                	sd	s4,0(sp)
    800022e4:	1800                	addi	s0,sp,48
    800022e6:	8a2a                	mv	s4,a0
  struct proc *p = myproc();
    800022e8:	00000097          	auipc	ra,0x0
    800022ec:	812080e7          	jalr	-2030(ra) # 80001afa <myproc>
    800022f0:	89aa                	mv	s3,a0
  if(p == initproc)
    800022f2:	00006797          	auipc	a5,0x6
    800022f6:	6667b783          	ld	a5,1638(a5) # 80008958 <initproc>
    800022fa:	0d050493          	addi	s1,a0,208
    800022fe:	15050913          	addi	s2,a0,336
    80002302:	02a79363          	bne	a5,a0,80002328 <exit+0x52>
    panic("init exiting");
    80002306:	00006517          	auipc	a0,0x6
    8000230a:	fa250513          	addi	a0,a0,-94 # 800082a8 <digits+0x268>
    8000230e:	ffffe097          	auipc	ra,0xffffe
    80002312:	232080e7          	jalr	562(ra) # 80000540 <panic>
      fileclose(f);
    80002316:	00002097          	auipc	ra,0x2
    8000231a:	49c080e7          	jalr	1180(ra) # 800047b2 <fileclose>
      p->ofile[fd] = 0;
    8000231e:	0004b023          	sd	zero,0(s1)
  for(int fd = 0; fd < NOFILE; fd++){
    80002322:	04a1                	addi	s1,s1,8
    80002324:	01248563          	beq	s1,s2,8000232e <exit+0x58>
    if(p->ofile[fd]){
    80002328:	6088                	ld	a0,0(s1)
    8000232a:	f575                	bnez	a0,80002316 <exit+0x40>
    8000232c:	bfdd                	j	80002322 <exit+0x4c>
  begin_op();
    8000232e:	00002097          	auipc	ra,0x2
    80002332:	fbc080e7          	jalr	-68(ra) # 800042ea <begin_op>
  iput(p->cwd);
    80002336:	1509b503          	ld	a0,336(s3)
    8000233a:	00001097          	auipc	ra,0x1
    8000233e:	79e080e7          	jalr	1950(ra) # 80003ad8 <iput>
  end_op();
    80002342:	00002097          	auipc	ra,0x2
    80002346:	026080e7          	jalr	38(ra) # 80004368 <end_op>
  p->cwd = 0;
    8000234a:	1409b823          	sd	zero,336(s3)
  acquire(&wait_lock);
    8000234e:	0000f497          	auipc	s1,0xf
    80002352:	89a48493          	addi	s1,s1,-1894 # 80010be8 <wait_lock>
    80002356:	8526                	mv	a0,s1
    80002358:	fffff097          	auipc	ra,0xfffff
    8000235c:	87e080e7          	jalr	-1922(ra) # 80000bd6 <acquire>
  reparent(p);
    80002360:	854e                	mv	a0,s3
    80002362:	00000097          	auipc	ra,0x0
    80002366:	f1a080e7          	jalr	-230(ra) # 8000227c <reparent>
  wakeup(p->parent);
    8000236a:	0389b503          	ld	a0,56(s3)
    8000236e:	00000097          	auipc	ra,0x0
    80002372:	e98080e7          	jalr	-360(ra) # 80002206 <wakeup>
  acquire(&p->lock);
    80002376:	854e                	mv	a0,s3
    80002378:	fffff097          	auipc	ra,0xfffff
    8000237c:	85e080e7          	jalr	-1954(ra) # 80000bd6 <acquire>
  p->xstate = status;
    80002380:	0349a623          	sw	s4,44(s3)
  p->state = ZOMBIE;
    80002384:	4795                	li	a5,5
    80002386:	00f9ac23          	sw	a5,24(s3)
  release(&wait_lock);
    8000238a:	8526                	mv	a0,s1
    8000238c:	fffff097          	auipc	ra,0xfffff
    80002390:	8fe080e7          	jalr	-1794(ra) # 80000c8a <release>
  sched();
    80002394:	00000097          	auipc	ra,0x0
    80002398:	cfc080e7          	jalr	-772(ra) # 80002090 <sched>
  panic("zombie exit");
    8000239c:	00006517          	auipc	a0,0x6
    800023a0:	f1c50513          	addi	a0,a0,-228 # 800082b8 <digits+0x278>
    800023a4:	ffffe097          	auipc	ra,0xffffe
    800023a8:	19c080e7          	jalr	412(ra) # 80000540 <panic>

00000000800023ac <kill>:
// Kill the process with the given pid.
// The victim won't exit until it tries to return
// to user space (see usertrap() in trap.c).
int
kill(int pid)
{
    800023ac:	7179                	addi	sp,sp,-48
    800023ae:	f406                	sd	ra,40(sp)
    800023b0:	f022                	sd	s0,32(sp)
    800023b2:	ec26                	sd	s1,24(sp)
    800023b4:	e84a                	sd	s2,16(sp)
    800023b6:	e44e                	sd	s3,8(sp)
    800023b8:	1800                	addi	s0,sp,48
    800023ba:	892a                	mv	s2,a0
  struct proc *p;

  for(p = proc; p < &proc[NPROC]; p++){
    800023bc:	0000f497          	auipc	s1,0xf
    800023c0:	c4448493          	addi	s1,s1,-956 # 80011000 <proc>
    800023c4:	00014997          	auipc	s3,0x14
    800023c8:	63c98993          	addi	s3,s3,1596 # 80016a00 <tickslock>
    acquire(&p->lock);
    800023cc:	8526                	mv	a0,s1
    800023ce:	fffff097          	auipc	ra,0xfffff
    800023d2:	808080e7          	jalr	-2040(ra) # 80000bd6 <acquire>
    if(p->pid == pid){
    800023d6:	589c                	lw	a5,48(s1)
    800023d8:	01278d63          	beq	a5,s2,800023f2 <kill+0x46>
        p->state = RUNNABLE;
      }
      release(&p->lock);
      return 0;
    }
    release(&p->lock);
    800023dc:	8526                	mv	a0,s1
    800023de:	fffff097          	auipc	ra,0xfffff
    800023e2:	8ac080e7          	jalr	-1876(ra) # 80000c8a <release>
  for(p = proc; p < &proc[NPROC]; p++){
    800023e6:	16848493          	addi	s1,s1,360
    800023ea:	ff3491e3          	bne	s1,s3,800023cc <kill+0x20>
  }
  return -1;
    800023ee:	557d                	li	a0,-1
    800023f0:	a829                	j	8000240a <kill+0x5e>
      p->killed = 1;
    800023f2:	4785                	li	a5,1
    800023f4:	d49c                	sw	a5,40(s1)
      if(p->state == SLEEPING){
    800023f6:	4c98                	lw	a4,24(s1)
    800023f8:	4789                	li	a5,2
    800023fa:	00f70f63          	beq	a4,a5,80002418 <kill+0x6c>
      release(&p->lock);
    800023fe:	8526                	mv	a0,s1
    80002400:	fffff097          	auipc	ra,0xfffff
    80002404:	88a080e7          	jalr	-1910(ra) # 80000c8a <release>
      return 0;
    80002408:	4501                	li	a0,0
}
    8000240a:	70a2                	ld	ra,40(sp)
    8000240c:	7402                	ld	s0,32(sp)
    8000240e:	64e2                	ld	s1,24(sp)
    80002410:	6942                	ld	s2,16(sp)
    80002412:	69a2                	ld	s3,8(sp)
    80002414:	6145                	addi	sp,sp,48
    80002416:	8082                	ret
        p->state = RUNNABLE;
    80002418:	478d                	li	a5,3
    8000241a:	cc9c                	sw	a5,24(s1)
    8000241c:	b7cd                	j	800023fe <kill+0x52>

000000008000241e <setkilled>:

void
setkilled(struct proc *p)
{
    8000241e:	1101                	addi	sp,sp,-32
    80002420:	ec06                	sd	ra,24(sp)
    80002422:	e822                	sd	s0,16(sp)
    80002424:	e426                	sd	s1,8(sp)
    80002426:	1000                	addi	s0,sp,32
    80002428:	84aa                	mv	s1,a0
  acquire(&p->lock);
    8000242a:	ffffe097          	auipc	ra,0xffffe
    8000242e:	7ac080e7          	jalr	1964(ra) # 80000bd6 <acquire>
  p->killed = 1;
    80002432:	4785                	li	a5,1
    80002434:	d49c                	sw	a5,40(s1)
  release(&p->lock);
    80002436:	8526                	mv	a0,s1
    80002438:	fffff097          	auipc	ra,0xfffff
    8000243c:	852080e7          	jalr	-1966(ra) # 80000c8a <release>
}
    80002440:	60e2                	ld	ra,24(sp)
    80002442:	6442                	ld	s0,16(sp)
    80002444:	64a2                	ld	s1,8(sp)
    80002446:	6105                	addi	sp,sp,32
    80002448:	8082                	ret

000000008000244a <killed>:

int
killed(struct proc *p)
{
    8000244a:	1101                	addi	sp,sp,-32
    8000244c:	ec06                	sd	ra,24(sp)
    8000244e:	e822                	sd	s0,16(sp)
    80002450:	e426                	sd	s1,8(sp)
    80002452:	e04a                	sd	s2,0(sp)
    80002454:	1000                	addi	s0,sp,32
    80002456:	84aa                	mv	s1,a0
  int k;
  
  acquire(&p->lock);
    80002458:	ffffe097          	auipc	ra,0xffffe
    8000245c:	77e080e7          	jalr	1918(ra) # 80000bd6 <acquire>
  k = p->killed;
    80002460:	0284a903          	lw	s2,40(s1)
  release(&p->lock);
    80002464:	8526                	mv	a0,s1
    80002466:	fffff097          	auipc	ra,0xfffff
    8000246a:	824080e7          	jalr	-2012(ra) # 80000c8a <release>
  return k;
}
    8000246e:	854a                	mv	a0,s2
    80002470:	60e2                	ld	ra,24(sp)
    80002472:	6442                	ld	s0,16(sp)
    80002474:	64a2                	ld	s1,8(sp)
    80002476:	6902                	ld	s2,0(sp)
    80002478:	6105                	addi	sp,sp,32
    8000247a:	8082                	ret

000000008000247c <wait>:
{
    8000247c:	715d                	addi	sp,sp,-80
    8000247e:	e486                	sd	ra,72(sp)
    80002480:	e0a2                	sd	s0,64(sp)
    80002482:	fc26                	sd	s1,56(sp)
    80002484:	f84a                	sd	s2,48(sp)
    80002486:	f44e                	sd	s3,40(sp)
    80002488:	f052                	sd	s4,32(sp)
    8000248a:	ec56                	sd	s5,24(sp)
    8000248c:	e85a                	sd	s6,16(sp)
    8000248e:	e45e                	sd	s7,8(sp)
    80002490:	e062                	sd	s8,0(sp)
    80002492:	0880                	addi	s0,sp,80
    80002494:	8b2a                	mv	s6,a0
  struct proc *p = myproc();
    80002496:	fffff097          	auipc	ra,0xfffff
    8000249a:	664080e7          	jalr	1636(ra) # 80001afa <myproc>
    8000249e:	892a                	mv	s2,a0
  acquire(&wait_lock);
    800024a0:	0000e517          	auipc	a0,0xe
    800024a4:	74850513          	addi	a0,a0,1864 # 80010be8 <wait_lock>
    800024a8:	ffffe097          	auipc	ra,0xffffe
    800024ac:	72e080e7          	jalr	1838(ra) # 80000bd6 <acquire>
    havekids = 0;
    800024b0:	4b81                	li	s7,0
        if(pp->state == ZOMBIE){
    800024b2:	4a15                	li	s4,5
        havekids = 1;
    800024b4:	4a85                	li	s5,1
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800024b6:	00014997          	auipc	s3,0x14
    800024ba:	54a98993          	addi	s3,s3,1354 # 80016a00 <tickslock>
    sleep(p, &wait_lock);  //DOC: wait-sleep
    800024be:	0000ec17          	auipc	s8,0xe
    800024c2:	72ac0c13          	addi	s8,s8,1834 # 80010be8 <wait_lock>
    havekids = 0;
    800024c6:	875e                	mv	a4,s7
    for(pp = proc; pp < &proc[NPROC]; pp++){
    800024c8:	0000f497          	auipc	s1,0xf
    800024cc:	b3848493          	addi	s1,s1,-1224 # 80011000 <proc>
    800024d0:	a0bd                	j	8000253e <wait+0xc2>
          pid = pp->pid;
    800024d2:	0304a983          	lw	s3,48(s1)
          if(addr != 0 && copyout(p->pagetable, addr, (char *)&pp->xstate,
    800024d6:	000b0e63          	beqz	s6,800024f2 <wait+0x76>
    800024da:	4691                	li	a3,4
    800024dc:	02c48613          	addi	a2,s1,44
    800024e0:	85da                	mv	a1,s6
    800024e2:	05093503          	ld	a0,80(s2)
    800024e6:	fffff097          	auipc	ra,0xfffff
    800024ea:	186080e7          	jalr	390(ra) # 8000166c <copyout>
    800024ee:	02054563          	bltz	a0,80002518 <wait+0x9c>
          freeproc(pp);
    800024f2:	8526                	mv	a0,s1
    800024f4:	fffff097          	auipc	ra,0xfffff
    800024f8:	7b8080e7          	jalr	1976(ra) # 80001cac <freeproc>
          release(&pp->lock);
    800024fc:	8526                	mv	a0,s1
    800024fe:	ffffe097          	auipc	ra,0xffffe
    80002502:	78c080e7          	jalr	1932(ra) # 80000c8a <release>
          release(&wait_lock);
    80002506:	0000e517          	auipc	a0,0xe
    8000250a:	6e250513          	addi	a0,a0,1762 # 80010be8 <wait_lock>
    8000250e:	ffffe097          	auipc	ra,0xffffe
    80002512:	77c080e7          	jalr	1916(ra) # 80000c8a <release>
          return pid;
    80002516:	a0b5                	j	80002582 <wait+0x106>
            release(&pp->lock);
    80002518:	8526                	mv	a0,s1
    8000251a:	ffffe097          	auipc	ra,0xffffe
    8000251e:	770080e7          	jalr	1904(ra) # 80000c8a <release>
            release(&wait_lock);
    80002522:	0000e517          	auipc	a0,0xe
    80002526:	6c650513          	addi	a0,a0,1734 # 80010be8 <wait_lock>
    8000252a:	ffffe097          	auipc	ra,0xffffe
    8000252e:	760080e7          	jalr	1888(ra) # 80000c8a <release>
            return -1;
    80002532:	59fd                	li	s3,-1
    80002534:	a0b9                	j	80002582 <wait+0x106>
    for(pp = proc; pp < &proc[NPROC]; pp++){
    80002536:	16848493          	addi	s1,s1,360
    8000253a:	03348463          	beq	s1,s3,80002562 <wait+0xe6>
      if(pp->parent == p){
    8000253e:	7c9c                	ld	a5,56(s1)
    80002540:	ff279be3          	bne	a5,s2,80002536 <wait+0xba>
        acquire(&pp->lock);
    80002544:	8526                	mv	a0,s1
    80002546:	ffffe097          	auipc	ra,0xffffe
    8000254a:	690080e7          	jalr	1680(ra) # 80000bd6 <acquire>
        if(pp->state == ZOMBIE){
    8000254e:	4c9c                	lw	a5,24(s1)
    80002550:	f94781e3          	beq	a5,s4,800024d2 <wait+0x56>
        release(&pp->lock);
    80002554:	8526                	mv	a0,s1
    80002556:	ffffe097          	auipc	ra,0xffffe
    8000255a:	734080e7          	jalr	1844(ra) # 80000c8a <release>
        havekids = 1;
    8000255e:	8756                	mv	a4,s5
    80002560:	bfd9                	j	80002536 <wait+0xba>
    if(!havekids || killed(p)){
    80002562:	c719                	beqz	a4,80002570 <wait+0xf4>
    80002564:	854a                	mv	a0,s2
    80002566:	00000097          	auipc	ra,0x0
    8000256a:	ee4080e7          	jalr	-284(ra) # 8000244a <killed>
    8000256e:	c51d                	beqz	a0,8000259c <wait+0x120>
      release(&wait_lock);
    80002570:	0000e517          	auipc	a0,0xe
    80002574:	67850513          	addi	a0,a0,1656 # 80010be8 <wait_lock>
    80002578:	ffffe097          	auipc	ra,0xffffe
    8000257c:	712080e7          	jalr	1810(ra) # 80000c8a <release>
      return -1;
    80002580:	59fd                	li	s3,-1
}
    80002582:	854e                	mv	a0,s3
    80002584:	60a6                	ld	ra,72(sp)
    80002586:	6406                	ld	s0,64(sp)
    80002588:	74e2                	ld	s1,56(sp)
    8000258a:	7942                	ld	s2,48(sp)
    8000258c:	79a2                	ld	s3,40(sp)
    8000258e:	7a02                	ld	s4,32(sp)
    80002590:	6ae2                	ld	s5,24(sp)
    80002592:	6b42                	ld	s6,16(sp)
    80002594:	6ba2                	ld	s7,8(sp)
    80002596:	6c02                	ld	s8,0(sp)
    80002598:	6161                	addi	sp,sp,80
    8000259a:	8082                	ret
    sleep(p, &wait_lock);  //DOC: wait-sleep
    8000259c:	85e2                	mv	a1,s8
    8000259e:	854a                	mv	a0,s2
    800025a0:	00000097          	auipc	ra,0x0
    800025a4:	c02080e7          	jalr	-1022(ra) # 800021a2 <sleep>
    havekids = 0;
    800025a8:	bf39                	j	800024c6 <wait+0x4a>

00000000800025aa <either_copyout>:
// Copy to either a user address, or kernel address,
// depending on usr_dst.
// Returns 0 on success, -1 on error.
int
either_copyout(int user_dst, uint64 dst, void *src, uint64 len)
{
    800025aa:	7179                	addi	sp,sp,-48
    800025ac:	f406                	sd	ra,40(sp)
    800025ae:	f022                	sd	s0,32(sp)
    800025b0:	ec26                	sd	s1,24(sp)
    800025b2:	e84a                	sd	s2,16(sp)
    800025b4:	e44e                	sd	s3,8(sp)
    800025b6:	e052                	sd	s4,0(sp)
    800025b8:	1800                	addi	s0,sp,48
    800025ba:	84aa                	mv	s1,a0
    800025bc:	892e                	mv	s2,a1
    800025be:	89b2                	mv	s3,a2
    800025c0:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    800025c2:	fffff097          	auipc	ra,0xfffff
    800025c6:	538080e7          	jalr	1336(ra) # 80001afa <myproc>
  if(user_dst){
    800025ca:	c08d                	beqz	s1,800025ec <either_copyout+0x42>
    return copyout(p->pagetable, dst, src, len);
    800025cc:	86d2                	mv	a3,s4
    800025ce:	864e                	mv	a2,s3
    800025d0:	85ca                	mv	a1,s2
    800025d2:	6928                	ld	a0,80(a0)
    800025d4:	fffff097          	auipc	ra,0xfffff
    800025d8:	098080e7          	jalr	152(ra) # 8000166c <copyout>
  } else {
    memmove((char *)dst, src, len);
    return 0;
  }
}
    800025dc:	70a2                	ld	ra,40(sp)
    800025de:	7402                	ld	s0,32(sp)
    800025e0:	64e2                	ld	s1,24(sp)
    800025e2:	6942                	ld	s2,16(sp)
    800025e4:	69a2                	ld	s3,8(sp)
    800025e6:	6a02                	ld	s4,0(sp)
    800025e8:	6145                	addi	sp,sp,48
    800025ea:	8082                	ret
    memmove((char *)dst, src, len);
    800025ec:	000a061b          	sext.w	a2,s4
    800025f0:	85ce                	mv	a1,s3
    800025f2:	854a                	mv	a0,s2
    800025f4:	ffffe097          	auipc	ra,0xffffe
    800025f8:	73a080e7          	jalr	1850(ra) # 80000d2e <memmove>
    return 0;
    800025fc:	8526                	mv	a0,s1
    800025fe:	bff9                	j	800025dc <either_copyout+0x32>

0000000080002600 <either_copyin>:
// Copy from either a user address, or kernel address,
// depending on usr_src.
// Returns 0 on success, -1 on error.
int
either_copyin(void *dst, int user_src, uint64 src, uint64 len)
{
    80002600:	7179                	addi	sp,sp,-48
    80002602:	f406                	sd	ra,40(sp)
    80002604:	f022                	sd	s0,32(sp)
    80002606:	ec26                	sd	s1,24(sp)
    80002608:	e84a                	sd	s2,16(sp)
    8000260a:	e44e                	sd	s3,8(sp)
    8000260c:	e052                	sd	s4,0(sp)
    8000260e:	1800                	addi	s0,sp,48
    80002610:	892a                	mv	s2,a0
    80002612:	84ae                	mv	s1,a1
    80002614:	89b2                	mv	s3,a2
    80002616:	8a36                	mv	s4,a3
  struct proc *p = myproc();
    80002618:	fffff097          	auipc	ra,0xfffff
    8000261c:	4e2080e7          	jalr	1250(ra) # 80001afa <myproc>
  if(user_src){
    80002620:	c08d                	beqz	s1,80002642 <either_copyin+0x42>
    return copyin(p->pagetable, dst, src, len);
    80002622:	86d2                	mv	a3,s4
    80002624:	864e                	mv	a2,s3
    80002626:	85ca                	mv	a1,s2
    80002628:	6928                	ld	a0,80(a0)
    8000262a:	fffff097          	auipc	ra,0xfffff
    8000262e:	0ce080e7          	jalr	206(ra) # 800016f8 <copyin>
  } else {
    memmove(dst, (char*)src, len);
    return 0;
  }
}
    80002632:	70a2                	ld	ra,40(sp)
    80002634:	7402                	ld	s0,32(sp)
    80002636:	64e2                	ld	s1,24(sp)
    80002638:	6942                	ld	s2,16(sp)
    8000263a:	69a2                	ld	s3,8(sp)
    8000263c:	6a02                	ld	s4,0(sp)
    8000263e:	6145                	addi	sp,sp,48
    80002640:	8082                	ret
    memmove(dst, (char*)src, len);
    80002642:	000a061b          	sext.w	a2,s4
    80002646:	85ce                	mv	a1,s3
    80002648:	854a                	mv	a0,s2
    8000264a:	ffffe097          	auipc	ra,0xffffe
    8000264e:	6e4080e7          	jalr	1764(ra) # 80000d2e <memmove>
    return 0;
    80002652:	8526                	mv	a0,s1
    80002654:	bff9                	j	80002632 <either_copyin+0x32>

0000000080002656 <procdump>:
// Print a process listing to console.  For debugging.
// Runs when user types ^P on console.
// No lock to avoid wedging a stuck machine further.
void
procdump(void)
{
    80002656:	715d                	addi	sp,sp,-80
    80002658:	e486                	sd	ra,72(sp)
    8000265a:	e0a2                	sd	s0,64(sp)
    8000265c:	fc26                	sd	s1,56(sp)
    8000265e:	f84a                	sd	s2,48(sp)
    80002660:	f44e                	sd	s3,40(sp)
    80002662:	f052                	sd	s4,32(sp)
    80002664:	ec56                	sd	s5,24(sp)
    80002666:	e85a                	sd	s6,16(sp)
    80002668:	e45e                	sd	s7,8(sp)
    8000266a:	0880                	addi	s0,sp,80
  [ZOMBIE]    "zombie"
  };
  struct proc *p;
  char *state;

  printf("\n");
    8000266c:	00006517          	auipc	a0,0x6
    80002670:	a5c50513          	addi	a0,a0,-1444 # 800080c8 <digits+0x88>
    80002674:	ffffe097          	auipc	ra,0xffffe
    80002678:	f16080e7          	jalr	-234(ra) # 8000058a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    8000267c:	0000f497          	auipc	s1,0xf
    80002680:	adc48493          	addi	s1,s1,-1316 # 80011158 <proc+0x158>
    80002684:	00014917          	auipc	s2,0x14
    80002688:	4d490913          	addi	s2,s2,1236 # 80016b58 <bcache+0x140>
    if(p->state == UNUSED)
      continue;
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    8000268c:	4b15                	li	s6,5
      state = states[p->state];
    else
      state = "???";
    8000268e:	00006997          	auipc	s3,0x6
    80002692:	c3a98993          	addi	s3,s3,-966 # 800082c8 <digits+0x288>
    printf("%d %s %s", p->pid, state, p->name);
    80002696:	00006a97          	auipc	s5,0x6
    8000269a:	c3aa8a93          	addi	s5,s5,-966 # 800082d0 <digits+0x290>
    printf("\n");
    8000269e:	00006a17          	auipc	s4,0x6
    800026a2:	a2aa0a13          	addi	s4,s4,-1494 # 800080c8 <digits+0x88>
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026a6:	00006b97          	auipc	s7,0x6
    800026aa:	c82b8b93          	addi	s7,s7,-894 # 80008328 <states.0>
    800026ae:	a00d                	j	800026d0 <procdump+0x7a>
    printf("%d %s %s", p->pid, state, p->name);
    800026b0:	ed86a583          	lw	a1,-296(a3)
    800026b4:	8556                	mv	a0,s5
    800026b6:	ffffe097          	auipc	ra,0xffffe
    800026ba:	ed4080e7          	jalr	-300(ra) # 8000058a <printf>
    printf("\n");
    800026be:	8552                	mv	a0,s4
    800026c0:	ffffe097          	auipc	ra,0xffffe
    800026c4:	eca080e7          	jalr	-310(ra) # 8000058a <printf>
  for(p = proc; p < &proc[NPROC]; p++){
    800026c8:	16848493          	addi	s1,s1,360
    800026cc:	03248263          	beq	s1,s2,800026f0 <procdump+0x9a>
    if(p->state == UNUSED)
    800026d0:	86a6                	mv	a3,s1
    800026d2:	ec04a783          	lw	a5,-320(s1)
    800026d6:	dbed                	beqz	a5,800026c8 <procdump+0x72>
      state = "???";
    800026d8:	864e                	mv	a2,s3
    if(p->state >= 0 && p->state < NELEM(states) && states[p->state])
    800026da:	fcfb6be3          	bltu	s6,a5,800026b0 <procdump+0x5a>
    800026de:	02079713          	slli	a4,a5,0x20
    800026e2:	01d75793          	srli	a5,a4,0x1d
    800026e6:	97de                	add	a5,a5,s7
    800026e8:	6390                	ld	a2,0(a5)
    800026ea:	f279                	bnez	a2,800026b0 <procdump+0x5a>
      state = "???";
    800026ec:	864e                	mv	a2,s3
    800026ee:	b7c9                	j	800026b0 <procdump+0x5a>
  }
}
    800026f0:	60a6                	ld	ra,72(sp)
    800026f2:	6406                	ld	s0,64(sp)
    800026f4:	74e2                	ld	s1,56(sp)
    800026f6:	7942                	ld	s2,48(sp)
    800026f8:	79a2                	ld	s3,40(sp)
    800026fa:	7a02                	ld	s4,32(sp)
    800026fc:	6ae2                	ld	s5,24(sp)
    800026fe:	6b42                	ld	s6,16(sp)
    80002700:	6ba2                	ld	s7,8(sp)
    80002702:	6161                	addi	sp,sp,80
    80002704:	8082                	ret

0000000080002706 <swtch>:
    80002706:	00153023          	sd	ra,0(a0)
    8000270a:	00253423          	sd	sp,8(a0)
    8000270e:	e900                	sd	s0,16(a0)
    80002710:	ed04                	sd	s1,24(a0)
    80002712:	03253023          	sd	s2,32(a0)
    80002716:	03353423          	sd	s3,40(a0)
    8000271a:	03453823          	sd	s4,48(a0)
    8000271e:	03553c23          	sd	s5,56(a0)
    80002722:	05653023          	sd	s6,64(a0)
    80002726:	05753423          	sd	s7,72(a0)
    8000272a:	05853823          	sd	s8,80(a0)
    8000272e:	05953c23          	sd	s9,88(a0)
    80002732:	07a53023          	sd	s10,96(a0)
    80002736:	07b53423          	sd	s11,104(a0)
    8000273a:	0005b083          	ld	ra,0(a1)
    8000273e:	0085b103          	ld	sp,8(a1)
    80002742:	6980                	ld	s0,16(a1)
    80002744:	6d84                	ld	s1,24(a1)
    80002746:	0205b903          	ld	s2,32(a1)
    8000274a:	0285b983          	ld	s3,40(a1)
    8000274e:	0305ba03          	ld	s4,48(a1)
    80002752:	0385ba83          	ld	s5,56(a1)
    80002756:	0405bb03          	ld	s6,64(a1)
    8000275a:	0485bb83          	ld	s7,72(a1)
    8000275e:	0505bc03          	ld	s8,80(a1)
    80002762:	0585bc83          	ld	s9,88(a1)
    80002766:	0605bd03          	ld	s10,96(a1)
    8000276a:	0685bd83          	ld	s11,104(a1)
    8000276e:	8082                	ret

0000000080002770 <trapinit>:

extern int devintr();

void
trapinit(void)
{
    80002770:	1141                	addi	sp,sp,-16
    80002772:	e406                	sd	ra,8(sp)
    80002774:	e022                	sd	s0,0(sp)
    80002776:	0800                	addi	s0,sp,16
  initlock(&tickslock, "time");
    80002778:	00006597          	auipc	a1,0x6
    8000277c:	be058593          	addi	a1,a1,-1056 # 80008358 <states.0+0x30>
    80002780:	00014517          	auipc	a0,0x14
    80002784:	28050513          	addi	a0,a0,640 # 80016a00 <tickslock>
    80002788:	ffffe097          	auipc	ra,0xffffe
    8000278c:	3be080e7          	jalr	958(ra) # 80000b46 <initlock>
}
    80002790:	60a2                	ld	ra,8(sp)
    80002792:	6402                	ld	s0,0(sp)
    80002794:	0141                	addi	sp,sp,16
    80002796:	8082                	ret

0000000080002798 <trapinithart>:

// set up to take exceptions and traps while in the kernel.
void
trapinithart(void)
{
    80002798:	1141                	addi	sp,sp,-16
    8000279a:	e422                	sd	s0,8(sp)
    8000279c:	0800                	addi	s0,sp,16
  asm volatile("csrw stvec, %0" : : "r" (x));
    8000279e:	00003797          	auipc	a5,0x3
    800027a2:	66278793          	addi	a5,a5,1634 # 80005e00 <kernelvec>
    800027a6:	10579073          	csrw	stvec,a5
  w_stvec((uint64)kernelvec);
}
    800027aa:	6422                	ld	s0,8(sp)
    800027ac:	0141                	addi	sp,sp,16
    800027ae:	8082                	ret

00000000800027b0 <usertrapret>:
//
// return to user space
//
void
usertrapret(void)
{
    800027b0:	1141                	addi	sp,sp,-16
    800027b2:	e406                	sd	ra,8(sp)
    800027b4:	e022                	sd	s0,0(sp)
    800027b6:	0800                	addi	s0,sp,16
  struct proc *p = myproc();
    800027b8:	fffff097          	auipc	ra,0xfffff
    800027bc:	342080e7          	jalr	834(ra) # 80001afa <myproc>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800027c0:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() & ~SSTATUS_SIE);
    800027c4:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800027c6:	10079073          	csrw	sstatus,a5
  // kerneltrap() to usertrap(), so turn off interrupts until
  // we're back in user space, where usertrap() is correct.
  intr_off();

  // send syscalls, interrupts, and exceptions to uservec in trampoline.S
  uint64 trampoline_uservec = TRAMPOLINE + (uservec - trampoline);
    800027ca:	00005697          	auipc	a3,0x5
    800027ce:	83668693          	addi	a3,a3,-1994 # 80007000 <_trampoline>
    800027d2:	00005717          	auipc	a4,0x5
    800027d6:	82e70713          	addi	a4,a4,-2002 # 80007000 <_trampoline>
    800027da:	8f15                	sub	a4,a4,a3
    800027dc:	040007b7          	lui	a5,0x4000
    800027e0:	17fd                	addi	a5,a5,-1 # 3ffffff <_entry-0x7c000001>
    800027e2:	07b2                	slli	a5,a5,0xc
    800027e4:	973e                	add	a4,a4,a5
  asm volatile("csrw stvec, %0" : : "r" (x));
    800027e6:	10571073          	csrw	stvec,a4
  w_stvec(trampoline_uservec);

  // set up trapframe values that uservec will need when
  // the process next traps into the kernel.
  p->trapframe->kernel_satp = r_satp();         // kernel page table
    800027ea:	6d38                	ld	a4,88(a0)
  asm volatile("csrr %0, satp" : "=r" (x) );
    800027ec:	18002673          	csrr	a2,satp
    800027f0:	e310                	sd	a2,0(a4)
  p->trapframe->kernel_sp = p->kstack + PGSIZE; // process's kernel stack
    800027f2:	6d30                	ld	a2,88(a0)
    800027f4:	6138                	ld	a4,64(a0)
    800027f6:	6585                	lui	a1,0x1
    800027f8:	972e                	add	a4,a4,a1
    800027fa:	e618                	sd	a4,8(a2)
  p->trapframe->kernel_trap = (uint64)usertrap;
    800027fc:	6d38                	ld	a4,88(a0)
    800027fe:	00000617          	auipc	a2,0x0
    80002802:	13060613          	addi	a2,a2,304 # 8000292e <usertrap>
    80002806:	eb10                	sd	a2,16(a4)
  p->trapframe->kernel_hartid = r_tp();         // hartid for cpuid()
    80002808:	6d38                	ld	a4,88(a0)
  asm volatile("mv %0, tp" : "=r" (x) );
    8000280a:	8612                	mv	a2,tp
    8000280c:	f310                	sd	a2,32(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000280e:	10002773          	csrr	a4,sstatus
  // set up the registers that trampoline.S's sret will use
  // to get to user space.
  
  // set S Previous Privilege mode to User.
  unsigned long x = r_sstatus();
  x &= ~SSTATUS_SPP; // clear SPP to 0 for user mode
    80002812:	eff77713          	andi	a4,a4,-257
  x |= SSTATUS_SPIE; // enable interrupts in user mode
    80002816:	02076713          	ori	a4,a4,32
  asm volatile("csrw sstatus, %0" : : "r" (x));
    8000281a:	10071073          	csrw	sstatus,a4
  w_sstatus(x);

  // set S Exception Program Counter to the saved user pc.
  w_sepc(p->trapframe->epc);
    8000281e:	6d38                	ld	a4,88(a0)
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002820:	6f18                	ld	a4,24(a4)
    80002822:	14171073          	csrw	sepc,a4

  // tell trampoline.S the user page table to switch to.
  uint64 satp = MAKE_SATP(p->pagetable);
    80002826:	6928                	ld	a0,80(a0)
    80002828:	8131                	srli	a0,a0,0xc

  // jump to userret in trampoline.S at the top of memory, which 
  // switches to the user page table, restores user registers,
  // and switches to user mode with sret.
  uint64 trampoline_userret = TRAMPOLINE + (userret - trampoline);
    8000282a:	00005717          	auipc	a4,0x5
    8000282e:	87270713          	addi	a4,a4,-1934 # 8000709c <userret>
    80002832:	8f15                	sub	a4,a4,a3
    80002834:	97ba                	add	a5,a5,a4
  ((void (*)(uint64))trampoline_userret)(satp);
    80002836:	577d                	li	a4,-1
    80002838:	177e                	slli	a4,a4,0x3f
    8000283a:	8d59                	or	a0,a0,a4
    8000283c:	9782                	jalr	a5
}
    8000283e:	60a2                	ld	ra,8(sp)
    80002840:	6402                	ld	s0,0(sp)
    80002842:	0141                	addi	sp,sp,16
    80002844:	8082                	ret

0000000080002846 <clockintr>:
  w_sstatus(sstatus);
}

void
clockintr()
{
    80002846:	1101                	addi	sp,sp,-32
    80002848:	ec06                	sd	ra,24(sp)
    8000284a:	e822                	sd	s0,16(sp)
    8000284c:	e426                	sd	s1,8(sp)
    8000284e:	1000                	addi	s0,sp,32
  acquire(&tickslock);
    80002850:	00014497          	auipc	s1,0x14
    80002854:	1b048493          	addi	s1,s1,432 # 80016a00 <tickslock>
    80002858:	8526                	mv	a0,s1
    8000285a:	ffffe097          	auipc	ra,0xffffe
    8000285e:	37c080e7          	jalr	892(ra) # 80000bd6 <acquire>
  ticks++;
    80002862:	00006517          	auipc	a0,0x6
    80002866:	0fe50513          	addi	a0,a0,254 # 80008960 <ticks>
    8000286a:	411c                	lw	a5,0(a0)
    8000286c:	2785                	addiw	a5,a5,1
    8000286e:	c11c                	sw	a5,0(a0)
  wakeup(&ticks);
    80002870:	00000097          	auipc	ra,0x0
    80002874:	996080e7          	jalr	-1642(ra) # 80002206 <wakeup>
  release(&tickslock);
    80002878:	8526                	mv	a0,s1
    8000287a:	ffffe097          	auipc	ra,0xffffe
    8000287e:	410080e7          	jalr	1040(ra) # 80000c8a <release>
}
    80002882:	60e2                	ld	ra,24(sp)
    80002884:	6442                	ld	s0,16(sp)
    80002886:	64a2                	ld	s1,8(sp)
    80002888:	6105                	addi	sp,sp,32
    8000288a:	8082                	ret

000000008000288c <devintr>:
// returns 2 if timer interrupt,
// 1 if other device,
// 0 if not recognized.
int
devintr()
{
    8000288c:	1101                	addi	sp,sp,-32
    8000288e:	ec06                	sd	ra,24(sp)
    80002890:	e822                	sd	s0,16(sp)
    80002892:	e426                	sd	s1,8(sp)
    80002894:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002896:	14202773          	csrr	a4,scause
  uint64 scause = r_scause();

  if((scause & 0x8000000000000000L) &&
    8000289a:	00074d63          	bltz	a4,800028b4 <devintr+0x28>
    // now allowed to interrupt again.
    if(irq)
      plic_complete(irq);

    return 1;
  } else if(scause == 0x8000000000000001L){
    8000289e:	57fd                	li	a5,-1
    800028a0:	17fe                	slli	a5,a5,0x3f
    800028a2:	0785                	addi	a5,a5,1
    // the SSIP bit in sip.
    w_sip(r_sip() & ~2);

    return 2;
  } else {
    return 0;
    800028a4:	4501                	li	a0,0
  } else if(scause == 0x8000000000000001L){
    800028a6:	06f70363          	beq	a4,a5,8000290c <devintr+0x80>
  }
}
    800028aa:	60e2                	ld	ra,24(sp)
    800028ac:	6442                	ld	s0,16(sp)
    800028ae:	64a2                	ld	s1,8(sp)
    800028b0:	6105                	addi	sp,sp,32
    800028b2:	8082                	ret
     (scause & 0xff) == 9){
    800028b4:	0ff77793          	zext.b	a5,a4
  if((scause & 0x8000000000000000L) &&
    800028b8:	46a5                	li	a3,9
    800028ba:	fed792e3          	bne	a5,a3,8000289e <devintr+0x12>
    int irq = plic_claim();
    800028be:	00003097          	auipc	ra,0x3
    800028c2:	64a080e7          	jalr	1610(ra) # 80005f08 <plic_claim>
    800028c6:	84aa                	mv	s1,a0
    if(irq == UART0_IRQ){
    800028c8:	47a9                	li	a5,10
    800028ca:	02f50763          	beq	a0,a5,800028f8 <devintr+0x6c>
    } else if(irq == VIRTIO0_IRQ){
    800028ce:	4785                	li	a5,1
    800028d0:	02f50963          	beq	a0,a5,80002902 <devintr+0x76>
    return 1;
    800028d4:	4505                	li	a0,1
    } else if(irq){
    800028d6:	d8f1                	beqz	s1,800028aa <devintr+0x1e>
      printf("unexpected interrupt irq=%d\n", irq);
    800028d8:	85a6                	mv	a1,s1
    800028da:	00006517          	auipc	a0,0x6
    800028de:	a8650513          	addi	a0,a0,-1402 # 80008360 <states.0+0x38>
    800028e2:	ffffe097          	auipc	ra,0xffffe
    800028e6:	ca8080e7          	jalr	-856(ra) # 8000058a <printf>
      plic_complete(irq);
    800028ea:	8526                	mv	a0,s1
    800028ec:	00003097          	auipc	ra,0x3
    800028f0:	640080e7          	jalr	1600(ra) # 80005f2c <plic_complete>
    return 1;
    800028f4:	4505                	li	a0,1
    800028f6:	bf55                	j	800028aa <devintr+0x1e>
      uartintr();
    800028f8:	ffffe097          	auipc	ra,0xffffe
    800028fc:	0a0080e7          	jalr	160(ra) # 80000998 <uartintr>
    80002900:	b7ed                	j	800028ea <devintr+0x5e>
      virtio_disk_intr();
    80002902:	00004097          	auipc	ra,0x4
    80002906:	af2080e7          	jalr	-1294(ra) # 800063f4 <virtio_disk_intr>
    8000290a:	b7c5                	j	800028ea <devintr+0x5e>
    if(cpuid() == 0){
    8000290c:	fffff097          	auipc	ra,0xfffff
    80002910:	1c2080e7          	jalr	450(ra) # 80001ace <cpuid>
    80002914:	c901                	beqz	a0,80002924 <devintr+0x98>
  asm volatile("csrr %0, sip" : "=r" (x) );
    80002916:	144027f3          	csrr	a5,sip
    w_sip(r_sip() & ~2);
    8000291a:	9bf5                	andi	a5,a5,-3
  asm volatile("csrw sip, %0" : : "r" (x));
    8000291c:	14479073          	csrw	sip,a5
    return 2;
    80002920:	4509                	li	a0,2
    80002922:	b761                	j	800028aa <devintr+0x1e>
      clockintr();
    80002924:	00000097          	auipc	ra,0x0
    80002928:	f22080e7          	jalr	-222(ra) # 80002846 <clockintr>
    8000292c:	b7ed                	j	80002916 <devintr+0x8a>

000000008000292e <usertrap>:
{
    8000292e:	1101                	addi	sp,sp,-32
    80002930:	ec06                	sd	ra,24(sp)
    80002932:	e822                	sd	s0,16(sp)
    80002934:	e426                	sd	s1,8(sp)
    80002936:	e04a                	sd	s2,0(sp)
    80002938:	1000                	addi	s0,sp,32
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    8000293a:	100027f3          	csrr	a5,sstatus
  if((r_sstatus() & SSTATUS_SPP) != 0)
    8000293e:	1007f793          	andi	a5,a5,256
    80002942:	e3b1                	bnez	a5,80002986 <usertrap+0x58>
  asm volatile("csrw stvec, %0" : : "r" (x));
    80002944:	00003797          	auipc	a5,0x3
    80002948:	4bc78793          	addi	a5,a5,1212 # 80005e00 <kernelvec>
    8000294c:	10579073          	csrw	stvec,a5
  struct proc *p = myproc();
    80002950:	fffff097          	auipc	ra,0xfffff
    80002954:	1aa080e7          	jalr	426(ra) # 80001afa <myproc>
    80002958:	84aa                	mv	s1,a0
  p->trapframe->epc = r_sepc();
    8000295a:	6d3c                	ld	a5,88(a0)
  asm volatile("csrr %0, sepc" : "=r" (x) );
    8000295c:	14102773          	csrr	a4,sepc
    80002960:	ef98                	sd	a4,24(a5)
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002962:	14202773          	csrr	a4,scause
  if(r_scause() == 8){
    80002966:	47a1                	li	a5,8
    80002968:	02f70763          	beq	a4,a5,80002996 <usertrap+0x68>
  } else if((which_dev = devintr()) != 0){
    8000296c:	00000097          	auipc	ra,0x0
    80002970:	f20080e7          	jalr	-224(ra) # 8000288c <devintr>
    80002974:	892a                	mv	s2,a0
    80002976:	c151                	beqz	a0,800029fa <usertrap+0xcc>
  if(killed(p))
    80002978:	8526                	mv	a0,s1
    8000297a:	00000097          	auipc	ra,0x0
    8000297e:	ad0080e7          	jalr	-1328(ra) # 8000244a <killed>
    80002982:	c929                	beqz	a0,800029d4 <usertrap+0xa6>
    80002984:	a099                	j	800029ca <usertrap+0x9c>
    panic("usertrap: not from user mode");
    80002986:	00006517          	auipc	a0,0x6
    8000298a:	9fa50513          	addi	a0,a0,-1542 # 80008380 <states.0+0x58>
    8000298e:	ffffe097          	auipc	ra,0xffffe
    80002992:	bb2080e7          	jalr	-1102(ra) # 80000540 <panic>
    if(killed(p))
    80002996:	00000097          	auipc	ra,0x0
    8000299a:	ab4080e7          	jalr	-1356(ra) # 8000244a <killed>
    8000299e:	e921                	bnez	a0,800029ee <usertrap+0xc0>
    p->trapframe->epc += 4;
    800029a0:	6cb8                	ld	a4,88(s1)
    800029a2:	6f1c                	ld	a5,24(a4)
    800029a4:	0791                	addi	a5,a5,4
    800029a6:	ef1c                	sd	a5,24(a4)
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    800029a8:	100027f3          	csrr	a5,sstatus
  w_sstatus(r_sstatus() | SSTATUS_SIE);
    800029ac:	0027e793          	ori	a5,a5,2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    800029b0:	10079073          	csrw	sstatus,a5
    syscall();
    800029b4:	00000097          	auipc	ra,0x0
    800029b8:	2d4080e7          	jalr	724(ra) # 80002c88 <syscall>
  if(killed(p))
    800029bc:	8526                	mv	a0,s1
    800029be:	00000097          	auipc	ra,0x0
    800029c2:	a8c080e7          	jalr	-1396(ra) # 8000244a <killed>
    800029c6:	c911                	beqz	a0,800029da <usertrap+0xac>
    800029c8:	4901                	li	s2,0
    exit(-1);
    800029ca:	557d                	li	a0,-1
    800029cc:	00000097          	auipc	ra,0x0
    800029d0:	90a080e7          	jalr	-1782(ra) # 800022d6 <exit>
  if(which_dev == 2)
    800029d4:	4789                	li	a5,2
    800029d6:	04f90f63          	beq	s2,a5,80002a34 <usertrap+0x106>
  usertrapret();
    800029da:	00000097          	auipc	ra,0x0
    800029de:	dd6080e7          	jalr	-554(ra) # 800027b0 <usertrapret>
}
    800029e2:	60e2                	ld	ra,24(sp)
    800029e4:	6442                	ld	s0,16(sp)
    800029e6:	64a2                	ld	s1,8(sp)
    800029e8:	6902                	ld	s2,0(sp)
    800029ea:	6105                	addi	sp,sp,32
    800029ec:	8082                	ret
      exit(-1);
    800029ee:	557d                	li	a0,-1
    800029f0:	00000097          	auipc	ra,0x0
    800029f4:	8e6080e7          	jalr	-1818(ra) # 800022d6 <exit>
    800029f8:	b765                	j	800029a0 <usertrap+0x72>
  asm volatile("csrr %0, scause" : "=r" (x) );
    800029fa:	142025f3          	csrr	a1,scause
    printf("usertrap(): unexpected scause %p pid=%d\n", r_scause(), p->pid);
    800029fe:	5890                	lw	a2,48(s1)
    80002a00:	00006517          	auipc	a0,0x6
    80002a04:	9a050513          	addi	a0,a0,-1632 # 800083a0 <states.0+0x78>
    80002a08:	ffffe097          	auipc	ra,0xffffe
    80002a0c:	b82080e7          	jalr	-1150(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a10:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002a14:	14302673          	csrr	a2,stval
    printf("            sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002a18:	00006517          	auipc	a0,0x6
    80002a1c:	9b850513          	addi	a0,a0,-1608 # 800083d0 <states.0+0xa8>
    80002a20:	ffffe097          	auipc	ra,0xffffe
    80002a24:	b6a080e7          	jalr	-1174(ra) # 8000058a <printf>
    setkilled(p);
    80002a28:	8526                	mv	a0,s1
    80002a2a:	00000097          	auipc	ra,0x0
    80002a2e:	9f4080e7          	jalr	-1548(ra) # 8000241e <setkilled>
    80002a32:	b769                	j	800029bc <usertrap+0x8e>
    yield();
    80002a34:	fffff097          	auipc	ra,0xfffff
    80002a38:	732080e7          	jalr	1842(ra) # 80002166 <yield>
    80002a3c:	bf79                	j	800029da <usertrap+0xac>

0000000080002a3e <kerneltrap>:
{
    80002a3e:	7179                	addi	sp,sp,-48
    80002a40:	f406                	sd	ra,40(sp)
    80002a42:	f022                	sd	s0,32(sp)
    80002a44:	ec26                	sd	s1,24(sp)
    80002a46:	e84a                	sd	s2,16(sp)
    80002a48:	e44e                	sd	s3,8(sp)
    80002a4a:	1800                	addi	s0,sp,48
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002a4c:	14102973          	csrr	s2,sepc
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a50:	100024f3          	csrr	s1,sstatus
  asm volatile("csrr %0, scause" : "=r" (x) );
    80002a54:	142029f3          	csrr	s3,scause
  if((sstatus & SSTATUS_SPP) == 0)
    80002a58:	1004f793          	andi	a5,s1,256
    80002a5c:	cb85                	beqz	a5,80002a8c <kerneltrap+0x4e>
  asm volatile("csrr %0, sstatus" : "=r" (x) );
    80002a5e:	100027f3          	csrr	a5,sstatus
  return (x & SSTATUS_SIE) != 0;
    80002a62:	8b89                	andi	a5,a5,2
  if(intr_get() != 0)
    80002a64:	ef85                	bnez	a5,80002a9c <kerneltrap+0x5e>
  if((which_dev = devintr()) == 0){
    80002a66:	00000097          	auipc	ra,0x0
    80002a6a:	e26080e7          	jalr	-474(ra) # 8000288c <devintr>
    80002a6e:	cd1d                	beqz	a0,80002aac <kerneltrap+0x6e>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002a70:	4789                	li	a5,2
    80002a72:	06f50a63          	beq	a0,a5,80002ae6 <kerneltrap+0xa8>
  asm volatile("csrw sepc, %0" : : "r" (x));
    80002a76:	14191073          	csrw	sepc,s2
  asm volatile("csrw sstatus, %0" : : "r" (x));
    80002a7a:	10049073          	csrw	sstatus,s1
}
    80002a7e:	70a2                	ld	ra,40(sp)
    80002a80:	7402                	ld	s0,32(sp)
    80002a82:	64e2                	ld	s1,24(sp)
    80002a84:	6942                	ld	s2,16(sp)
    80002a86:	69a2                	ld	s3,8(sp)
    80002a88:	6145                	addi	sp,sp,48
    80002a8a:	8082                	ret
    panic("kerneltrap: not from supervisor mode");
    80002a8c:	00006517          	auipc	a0,0x6
    80002a90:	96450513          	addi	a0,a0,-1692 # 800083f0 <states.0+0xc8>
    80002a94:	ffffe097          	auipc	ra,0xffffe
    80002a98:	aac080e7          	jalr	-1364(ra) # 80000540 <panic>
    panic("kerneltrap: interrupts enabled");
    80002a9c:	00006517          	auipc	a0,0x6
    80002aa0:	97c50513          	addi	a0,a0,-1668 # 80008418 <states.0+0xf0>
    80002aa4:	ffffe097          	auipc	ra,0xffffe
    80002aa8:	a9c080e7          	jalr	-1380(ra) # 80000540 <panic>
    printf("scause %p\n", scause);
    80002aac:	85ce                	mv	a1,s3
    80002aae:	00006517          	auipc	a0,0x6
    80002ab2:	98a50513          	addi	a0,a0,-1654 # 80008438 <states.0+0x110>
    80002ab6:	ffffe097          	auipc	ra,0xffffe
    80002aba:	ad4080e7          	jalr	-1324(ra) # 8000058a <printf>
  asm volatile("csrr %0, sepc" : "=r" (x) );
    80002abe:	141025f3          	csrr	a1,sepc
  asm volatile("csrr %0, stval" : "=r" (x) );
    80002ac2:	14302673          	csrr	a2,stval
    printf("sepc=%p stval=%p\n", r_sepc(), r_stval());
    80002ac6:	00006517          	auipc	a0,0x6
    80002aca:	98250513          	addi	a0,a0,-1662 # 80008448 <states.0+0x120>
    80002ace:	ffffe097          	auipc	ra,0xffffe
    80002ad2:	abc080e7          	jalr	-1348(ra) # 8000058a <printf>
    panic("kerneltrap");
    80002ad6:	00006517          	auipc	a0,0x6
    80002ada:	98a50513          	addi	a0,a0,-1654 # 80008460 <states.0+0x138>
    80002ade:	ffffe097          	auipc	ra,0xffffe
    80002ae2:	a62080e7          	jalr	-1438(ra) # 80000540 <panic>
  if(which_dev == 2 && myproc() != 0 && myproc()->state == RUNNING)
    80002ae6:	fffff097          	auipc	ra,0xfffff
    80002aea:	014080e7          	jalr	20(ra) # 80001afa <myproc>
    80002aee:	d541                	beqz	a0,80002a76 <kerneltrap+0x38>
    80002af0:	fffff097          	auipc	ra,0xfffff
    80002af4:	00a080e7          	jalr	10(ra) # 80001afa <myproc>
    80002af8:	4d18                	lw	a4,24(a0)
    80002afa:	4791                	li	a5,4
    80002afc:	f6f71de3          	bne	a4,a5,80002a76 <kerneltrap+0x38>
    yield();
    80002b00:	fffff097          	auipc	ra,0xfffff
    80002b04:	666080e7          	jalr	1638(ra) # 80002166 <yield>
    80002b08:	b7bd                	j	80002a76 <kerneltrap+0x38>

0000000080002b0a <argraw>:
  return strlen(buf);
}

static uint64
argraw(int n)
{
    80002b0a:	1101                	addi	sp,sp,-32
    80002b0c:	ec06                	sd	ra,24(sp)
    80002b0e:	e822                	sd	s0,16(sp)
    80002b10:	e426                	sd	s1,8(sp)
    80002b12:	1000                	addi	s0,sp,32
    80002b14:	84aa                	mv	s1,a0
  struct proc *p = myproc();
    80002b16:	fffff097          	auipc	ra,0xfffff
    80002b1a:	fe4080e7          	jalr	-28(ra) # 80001afa <myproc>
  switch (n) {
    80002b1e:	4795                	li	a5,5
    80002b20:	0497e163          	bltu	a5,s1,80002b62 <argraw+0x58>
    80002b24:	048a                	slli	s1,s1,0x2
    80002b26:	00006717          	auipc	a4,0x6
    80002b2a:	97270713          	addi	a4,a4,-1678 # 80008498 <states.0+0x170>
    80002b2e:	94ba                	add	s1,s1,a4
    80002b30:	409c                	lw	a5,0(s1)
    80002b32:	97ba                	add	a5,a5,a4
    80002b34:	8782                	jr	a5
  case 0:
    return p->trapframe->a0;
    80002b36:	6d3c                	ld	a5,88(a0)
    80002b38:	7ba8                	ld	a0,112(a5)
  case 5:
    return p->trapframe->a5;
  }
  panic("argraw");
  return -1;
}
    80002b3a:	60e2                	ld	ra,24(sp)
    80002b3c:	6442                	ld	s0,16(sp)
    80002b3e:	64a2                	ld	s1,8(sp)
    80002b40:	6105                	addi	sp,sp,32
    80002b42:	8082                	ret
    return p->trapframe->a1;
    80002b44:	6d3c                	ld	a5,88(a0)
    80002b46:	7fa8                	ld	a0,120(a5)
    80002b48:	bfcd                	j	80002b3a <argraw+0x30>
    return p->trapframe->a2;
    80002b4a:	6d3c                	ld	a5,88(a0)
    80002b4c:	63c8                	ld	a0,128(a5)
    80002b4e:	b7f5                	j	80002b3a <argraw+0x30>
    return p->trapframe->a3;
    80002b50:	6d3c                	ld	a5,88(a0)
    80002b52:	67c8                	ld	a0,136(a5)
    80002b54:	b7dd                	j	80002b3a <argraw+0x30>
    return p->trapframe->a4;
    80002b56:	6d3c                	ld	a5,88(a0)
    80002b58:	6bc8                	ld	a0,144(a5)
    80002b5a:	b7c5                	j	80002b3a <argraw+0x30>
    return p->trapframe->a5;
    80002b5c:	6d3c                	ld	a5,88(a0)
    80002b5e:	6fc8                	ld	a0,152(a5)
    80002b60:	bfe9                	j	80002b3a <argraw+0x30>
  panic("argraw");
    80002b62:	00006517          	auipc	a0,0x6
    80002b66:	90e50513          	addi	a0,a0,-1778 # 80008470 <states.0+0x148>
    80002b6a:	ffffe097          	auipc	ra,0xffffe
    80002b6e:	9d6080e7          	jalr	-1578(ra) # 80000540 <panic>

0000000080002b72 <fetchaddr>:
{
    80002b72:	1101                	addi	sp,sp,-32
    80002b74:	ec06                	sd	ra,24(sp)
    80002b76:	e822                	sd	s0,16(sp)
    80002b78:	e426                	sd	s1,8(sp)
    80002b7a:	e04a                	sd	s2,0(sp)
    80002b7c:	1000                	addi	s0,sp,32
    80002b7e:	84aa                	mv	s1,a0
    80002b80:	892e                	mv	s2,a1
  struct proc *p = myproc();
    80002b82:	fffff097          	auipc	ra,0xfffff
    80002b86:	f78080e7          	jalr	-136(ra) # 80001afa <myproc>
  if(addr >= p->sz || addr+sizeof(uint64) > p->sz) // both tests needed, in case of overflow
    80002b8a:	653c                	ld	a5,72(a0)
    80002b8c:	02f4f863          	bgeu	s1,a5,80002bbc <fetchaddr+0x4a>
    80002b90:	00848713          	addi	a4,s1,8
    80002b94:	02e7e663          	bltu	a5,a4,80002bc0 <fetchaddr+0x4e>
  if(copyin(p->pagetable, (char *)ip, addr, sizeof(*ip)) != 0)
    80002b98:	46a1                	li	a3,8
    80002b9a:	8626                	mv	a2,s1
    80002b9c:	85ca                	mv	a1,s2
    80002b9e:	6928                	ld	a0,80(a0)
    80002ba0:	fffff097          	auipc	ra,0xfffff
    80002ba4:	b58080e7          	jalr	-1192(ra) # 800016f8 <copyin>
    80002ba8:	00a03533          	snez	a0,a0
    80002bac:	40a00533          	neg	a0,a0
}
    80002bb0:	60e2                	ld	ra,24(sp)
    80002bb2:	6442                	ld	s0,16(sp)
    80002bb4:	64a2                	ld	s1,8(sp)
    80002bb6:	6902                	ld	s2,0(sp)
    80002bb8:	6105                	addi	sp,sp,32
    80002bba:	8082                	ret
    return -1;
    80002bbc:	557d                	li	a0,-1
    80002bbe:	bfcd                	j	80002bb0 <fetchaddr+0x3e>
    80002bc0:	557d                	li	a0,-1
    80002bc2:	b7fd                	j	80002bb0 <fetchaddr+0x3e>

0000000080002bc4 <fetchstr>:
{
    80002bc4:	7179                	addi	sp,sp,-48
    80002bc6:	f406                	sd	ra,40(sp)
    80002bc8:	f022                	sd	s0,32(sp)
    80002bca:	ec26                	sd	s1,24(sp)
    80002bcc:	e84a                	sd	s2,16(sp)
    80002bce:	e44e                	sd	s3,8(sp)
    80002bd0:	1800                	addi	s0,sp,48
    80002bd2:	892a                	mv	s2,a0
    80002bd4:	84ae                	mv	s1,a1
    80002bd6:	89b2                	mv	s3,a2
  struct proc *p = myproc();
    80002bd8:	fffff097          	auipc	ra,0xfffff
    80002bdc:	f22080e7          	jalr	-222(ra) # 80001afa <myproc>
  if(copyinstr(p->pagetable, buf, addr, max) < 0)
    80002be0:	86ce                	mv	a3,s3
    80002be2:	864a                	mv	a2,s2
    80002be4:	85a6                	mv	a1,s1
    80002be6:	6928                	ld	a0,80(a0)
    80002be8:	fffff097          	auipc	ra,0xfffff
    80002bec:	b9e080e7          	jalr	-1122(ra) # 80001786 <copyinstr>
    80002bf0:	00054e63          	bltz	a0,80002c0c <fetchstr+0x48>
  return strlen(buf);
    80002bf4:	8526                	mv	a0,s1
    80002bf6:	ffffe097          	auipc	ra,0xffffe
    80002bfa:	258080e7          	jalr	600(ra) # 80000e4e <strlen>
}
    80002bfe:	70a2                	ld	ra,40(sp)
    80002c00:	7402                	ld	s0,32(sp)
    80002c02:	64e2                	ld	s1,24(sp)
    80002c04:	6942                	ld	s2,16(sp)
    80002c06:	69a2                	ld	s3,8(sp)
    80002c08:	6145                	addi	sp,sp,48
    80002c0a:	8082                	ret
    return -1;
    80002c0c:	557d                	li	a0,-1
    80002c0e:	bfc5                	j	80002bfe <fetchstr+0x3a>

0000000080002c10 <argint>:

// Fetch the nth 32-bit system call argument.
void
argint(int n, int *ip)
{
    80002c10:	1101                	addi	sp,sp,-32
    80002c12:	ec06                	sd	ra,24(sp)
    80002c14:	e822                	sd	s0,16(sp)
    80002c16:	e426                	sd	s1,8(sp)
    80002c18:	1000                	addi	s0,sp,32
    80002c1a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c1c:	00000097          	auipc	ra,0x0
    80002c20:	eee080e7          	jalr	-274(ra) # 80002b0a <argraw>
    80002c24:	c088                	sw	a0,0(s1)
}
    80002c26:	60e2                	ld	ra,24(sp)
    80002c28:	6442                	ld	s0,16(sp)
    80002c2a:	64a2                	ld	s1,8(sp)
    80002c2c:	6105                	addi	sp,sp,32
    80002c2e:	8082                	ret

0000000080002c30 <argaddr>:
// Retrieve an argument as a pointer.
// Doesn't check for legality, since
// copyin/copyout will do that.
void
argaddr(int n, uint64 *ip)
{
    80002c30:	1101                	addi	sp,sp,-32
    80002c32:	ec06                	sd	ra,24(sp)
    80002c34:	e822                	sd	s0,16(sp)
    80002c36:	e426                	sd	s1,8(sp)
    80002c38:	1000                	addi	s0,sp,32
    80002c3a:	84ae                	mv	s1,a1
  *ip = argraw(n);
    80002c3c:	00000097          	auipc	ra,0x0
    80002c40:	ece080e7          	jalr	-306(ra) # 80002b0a <argraw>
    80002c44:	e088                	sd	a0,0(s1)
}
    80002c46:	60e2                	ld	ra,24(sp)
    80002c48:	6442                	ld	s0,16(sp)
    80002c4a:	64a2                	ld	s1,8(sp)
    80002c4c:	6105                	addi	sp,sp,32
    80002c4e:	8082                	ret

0000000080002c50 <argstr>:
// Fetch the nth word-sized system call argument as a null-terminated string.
// Copies into buf, at most max.
// Returns string length if OK (including nul), -1 if error.
int
argstr(int n, char *buf, int max)
{
    80002c50:	7179                	addi	sp,sp,-48
    80002c52:	f406                	sd	ra,40(sp)
    80002c54:	f022                	sd	s0,32(sp)
    80002c56:	ec26                	sd	s1,24(sp)
    80002c58:	e84a                	sd	s2,16(sp)
    80002c5a:	1800                	addi	s0,sp,48
    80002c5c:	84ae                	mv	s1,a1
    80002c5e:	8932                	mv	s2,a2
  uint64 addr;
  argaddr(n, &addr);
    80002c60:	fd840593          	addi	a1,s0,-40
    80002c64:	00000097          	auipc	ra,0x0
    80002c68:	fcc080e7          	jalr	-52(ra) # 80002c30 <argaddr>
  return fetchstr(addr, buf, max);
    80002c6c:	864a                	mv	a2,s2
    80002c6e:	85a6                	mv	a1,s1
    80002c70:	fd843503          	ld	a0,-40(s0)
    80002c74:	00000097          	auipc	ra,0x0
    80002c78:	f50080e7          	jalr	-176(ra) # 80002bc4 <fetchstr>
}
    80002c7c:	70a2                	ld	ra,40(sp)
    80002c7e:	7402                	ld	s0,32(sp)
    80002c80:	64e2                	ld	s1,24(sp)
    80002c82:	6942                	ld	s2,16(sp)
    80002c84:	6145                	addi	sp,sp,48
    80002c86:	8082                	ret

0000000080002c88 <syscall>:
[SYS_state]   sys_state,
};

void
syscall(void)
{
    80002c88:	1101                	addi	sp,sp,-32
    80002c8a:	ec06                	sd	ra,24(sp)
    80002c8c:	e822                	sd	s0,16(sp)
    80002c8e:	e426                	sd	s1,8(sp)
    80002c90:	e04a                	sd	s2,0(sp)
    80002c92:	1000                	addi	s0,sp,32
  int num;
  struct proc *p = myproc();
    80002c94:	fffff097          	auipc	ra,0xfffff
    80002c98:	e66080e7          	jalr	-410(ra) # 80001afa <myproc>
    80002c9c:	84aa                	mv	s1,a0

  num = p->trapframe->a7;
    80002c9e:	05853903          	ld	s2,88(a0)
    80002ca2:	0a893783          	ld	a5,168(s2)
    80002ca6:	0007869b          	sext.w	a3,a5
  if(num > 0 && num < NELEM(syscalls) && syscalls[num]) {
    80002caa:	37fd                	addiw	a5,a5,-1
    80002cac:	475d                	li	a4,23
    80002cae:	00f76f63          	bltu	a4,a5,80002ccc <syscall+0x44>
    80002cb2:	00369713          	slli	a4,a3,0x3
    80002cb6:	00005797          	auipc	a5,0x5
    80002cba:	7fa78793          	addi	a5,a5,2042 # 800084b0 <syscalls>
    80002cbe:	97ba                	add	a5,a5,a4
    80002cc0:	639c                	ld	a5,0(a5)
    80002cc2:	c789                	beqz	a5,80002ccc <syscall+0x44>
    // printf("Sys call %s\n", p->name);
    // Use num to lookup the system call function for num, call it,
    // and store its return value in p->trapframe->a0
    p->trapframe->a0 = syscalls[num]();
    80002cc4:	9782                	jalr	a5
    80002cc6:	06a93823          	sd	a0,112(s2)
    80002cca:	a839                	j	80002ce8 <syscall+0x60>
  } else {
    printf("%d %s: unknown sys call %d\n",
    80002ccc:	15848613          	addi	a2,s1,344
    80002cd0:	588c                	lw	a1,48(s1)
    80002cd2:	00005517          	auipc	a0,0x5
    80002cd6:	7a650513          	addi	a0,a0,1958 # 80008478 <states.0+0x150>
    80002cda:	ffffe097          	auipc	ra,0xffffe
    80002cde:	8b0080e7          	jalr	-1872(ra) # 8000058a <printf>
            p->pid, p->name, num);
    p->trapframe->a0 = -1;
    80002ce2:	6cbc                	ld	a5,88(s1)
    80002ce4:	577d                	li	a4,-1
    80002ce6:	fbb8                	sd	a4,112(a5)
  }
}
    80002ce8:	60e2                	ld	ra,24(sp)
    80002cea:	6442                	ld	s0,16(sp)
    80002cec:	64a2                	ld	s1,8(sp)
    80002cee:	6902                	ld	s2,0(sp)
    80002cf0:	6105                	addi	sp,sp,32
    80002cf2:	8082                	ret

0000000080002cf4 <sys_exit>:
#include "spinlock.h"
#include "proc.h"

uint64
sys_exit(void)
{
    80002cf4:	1101                	addi	sp,sp,-32
    80002cf6:	ec06                	sd	ra,24(sp)
    80002cf8:	e822                	sd	s0,16(sp)
    80002cfa:	1000                	addi	s0,sp,32
  int n;
  argint(0, &n);
    80002cfc:	fec40593          	addi	a1,s0,-20
    80002d00:	4501                	li	a0,0
    80002d02:	00000097          	auipc	ra,0x0
    80002d06:	f0e080e7          	jalr	-242(ra) # 80002c10 <argint>
  exit(n);
    80002d0a:	fec42503          	lw	a0,-20(s0)
    80002d0e:	fffff097          	auipc	ra,0xfffff
    80002d12:	5c8080e7          	jalr	1480(ra) # 800022d6 <exit>
  return 0;  // not reached
}
    80002d16:	4501                	li	a0,0
    80002d18:	60e2                	ld	ra,24(sp)
    80002d1a:	6442                	ld	s0,16(sp)
    80002d1c:	6105                	addi	sp,sp,32
    80002d1e:	8082                	ret

0000000080002d20 <sys_getpid>:

uint64
sys_getpid(void)
{
    80002d20:	1141                	addi	sp,sp,-16
    80002d22:	e406                	sd	ra,8(sp)
    80002d24:	e022                	sd	s0,0(sp)
    80002d26:	0800                	addi	s0,sp,16
  return myproc()->pid;
    80002d28:	fffff097          	auipc	ra,0xfffff
    80002d2c:	dd2080e7          	jalr	-558(ra) # 80001afa <myproc>
}
    80002d30:	5908                	lw	a0,48(a0)
    80002d32:	60a2                	ld	ra,8(sp)
    80002d34:	6402                	ld	s0,0(sp)
    80002d36:	0141                	addi	sp,sp,16
    80002d38:	8082                	ret

0000000080002d3a <sys_fork>:

uint64
sys_fork(void)
{
    80002d3a:	1141                	addi	sp,sp,-16
    80002d3c:	e406                	sd	ra,8(sp)
    80002d3e:	e022                	sd	s0,0(sp)
    80002d40:	0800                	addi	s0,sp,16
  return fork();
    80002d42:	fffff097          	auipc	ra,0xfffff
    80002d46:	16e080e7          	jalr	366(ra) # 80001eb0 <fork>
}
    80002d4a:	60a2                	ld	ra,8(sp)
    80002d4c:	6402                	ld	s0,0(sp)
    80002d4e:	0141                	addi	sp,sp,16
    80002d50:	8082                	ret

0000000080002d52 <sys_wait>:

uint64
sys_wait(void)
{
    80002d52:	1101                	addi	sp,sp,-32
    80002d54:	ec06                	sd	ra,24(sp)
    80002d56:	e822                	sd	s0,16(sp)
    80002d58:	1000                	addi	s0,sp,32
  uint64 p;
  argaddr(0, &p);
    80002d5a:	fe840593          	addi	a1,s0,-24
    80002d5e:	4501                	li	a0,0
    80002d60:	00000097          	auipc	ra,0x0
    80002d64:	ed0080e7          	jalr	-304(ra) # 80002c30 <argaddr>
  return wait(p);
    80002d68:	fe843503          	ld	a0,-24(s0)
    80002d6c:	fffff097          	auipc	ra,0xfffff
    80002d70:	710080e7          	jalr	1808(ra) # 8000247c <wait>
}
    80002d74:	60e2                	ld	ra,24(sp)
    80002d76:	6442                	ld	s0,16(sp)
    80002d78:	6105                	addi	sp,sp,32
    80002d7a:	8082                	ret

0000000080002d7c <sys_sbrk>:

uint64
sys_sbrk(void)
{
    80002d7c:	7179                	addi	sp,sp,-48
    80002d7e:	f406                	sd	ra,40(sp)
    80002d80:	f022                	sd	s0,32(sp)
    80002d82:	ec26                	sd	s1,24(sp)
    80002d84:	1800                	addi	s0,sp,48
  uint64 addr;
  int n;

  argint(0, &n);
    80002d86:	fdc40593          	addi	a1,s0,-36
    80002d8a:	4501                	li	a0,0
    80002d8c:	00000097          	auipc	ra,0x0
    80002d90:	e84080e7          	jalr	-380(ra) # 80002c10 <argint>
  addr = myproc()->sz;
    80002d94:	fffff097          	auipc	ra,0xfffff
    80002d98:	d66080e7          	jalr	-666(ra) # 80001afa <myproc>
    80002d9c:	6524                	ld	s1,72(a0)
  if(growproc(n) < 0)
    80002d9e:	fdc42503          	lw	a0,-36(s0)
    80002da2:	fffff097          	auipc	ra,0xfffff
    80002da6:	0b2080e7          	jalr	178(ra) # 80001e54 <growproc>
    80002daa:	00054863          	bltz	a0,80002dba <sys_sbrk+0x3e>
    return -1;
  return addr;
}
    80002dae:	8526                	mv	a0,s1
    80002db0:	70a2                	ld	ra,40(sp)
    80002db2:	7402                	ld	s0,32(sp)
    80002db4:	64e2                	ld	s1,24(sp)
    80002db6:	6145                	addi	sp,sp,48
    80002db8:	8082                	ret
    return -1;
    80002dba:	54fd                	li	s1,-1
    80002dbc:	bfcd                	j	80002dae <sys_sbrk+0x32>

0000000080002dbe <sys_sleep>:

uint64
sys_sleep(void)
{
    80002dbe:	7139                	addi	sp,sp,-64
    80002dc0:	fc06                	sd	ra,56(sp)
    80002dc2:	f822                	sd	s0,48(sp)
    80002dc4:	f426                	sd	s1,40(sp)
    80002dc6:	f04a                	sd	s2,32(sp)
    80002dc8:	ec4e                	sd	s3,24(sp)
    80002dca:	0080                	addi	s0,sp,64
  int n;
  uint ticks0;

  argint(0, &n);
    80002dcc:	fcc40593          	addi	a1,s0,-52
    80002dd0:	4501                	li	a0,0
    80002dd2:	00000097          	auipc	ra,0x0
    80002dd6:	e3e080e7          	jalr	-450(ra) # 80002c10 <argint>
  acquire(&tickslock);
    80002dda:	00014517          	auipc	a0,0x14
    80002dde:	c2650513          	addi	a0,a0,-986 # 80016a00 <tickslock>
    80002de2:	ffffe097          	auipc	ra,0xffffe
    80002de6:	df4080e7          	jalr	-524(ra) # 80000bd6 <acquire>
  ticks0 = ticks;
    80002dea:	00006917          	auipc	s2,0x6
    80002dee:	b7692903          	lw	s2,-1162(s2) # 80008960 <ticks>
  while(ticks - ticks0 < n){
    80002df2:	fcc42783          	lw	a5,-52(s0)
    80002df6:	cf9d                	beqz	a5,80002e34 <sys_sleep+0x76>
    if(killed(myproc())){
      release(&tickslock);
      return -1;
    }
    sleep(&ticks, &tickslock);
    80002df8:	00014997          	auipc	s3,0x14
    80002dfc:	c0898993          	addi	s3,s3,-1016 # 80016a00 <tickslock>
    80002e00:	00006497          	auipc	s1,0x6
    80002e04:	b6048493          	addi	s1,s1,-1184 # 80008960 <ticks>
    if(killed(myproc())){
    80002e08:	fffff097          	auipc	ra,0xfffff
    80002e0c:	cf2080e7          	jalr	-782(ra) # 80001afa <myproc>
    80002e10:	fffff097          	auipc	ra,0xfffff
    80002e14:	63a080e7          	jalr	1594(ra) # 8000244a <killed>
    80002e18:	ed15                	bnez	a0,80002e54 <sys_sleep+0x96>
    sleep(&ticks, &tickslock);
    80002e1a:	85ce                	mv	a1,s3
    80002e1c:	8526                	mv	a0,s1
    80002e1e:	fffff097          	auipc	ra,0xfffff
    80002e22:	384080e7          	jalr	900(ra) # 800021a2 <sleep>
  while(ticks - ticks0 < n){
    80002e26:	409c                	lw	a5,0(s1)
    80002e28:	412787bb          	subw	a5,a5,s2
    80002e2c:	fcc42703          	lw	a4,-52(s0)
    80002e30:	fce7ece3          	bltu	a5,a4,80002e08 <sys_sleep+0x4a>
  }
  release(&tickslock);
    80002e34:	00014517          	auipc	a0,0x14
    80002e38:	bcc50513          	addi	a0,a0,-1076 # 80016a00 <tickslock>
    80002e3c:	ffffe097          	auipc	ra,0xffffe
    80002e40:	e4e080e7          	jalr	-434(ra) # 80000c8a <release>
  return 0;
    80002e44:	4501                	li	a0,0
}
    80002e46:	70e2                	ld	ra,56(sp)
    80002e48:	7442                	ld	s0,48(sp)
    80002e4a:	74a2                	ld	s1,40(sp)
    80002e4c:	7902                	ld	s2,32(sp)
    80002e4e:	69e2                	ld	s3,24(sp)
    80002e50:	6121                	addi	sp,sp,64
    80002e52:	8082                	ret
      release(&tickslock);
    80002e54:	00014517          	auipc	a0,0x14
    80002e58:	bac50513          	addi	a0,a0,-1108 # 80016a00 <tickslock>
    80002e5c:	ffffe097          	auipc	ra,0xffffe
    80002e60:	e2e080e7          	jalr	-466(ra) # 80000c8a <release>
      return -1;
    80002e64:	557d                	li	a0,-1
    80002e66:	b7c5                	j	80002e46 <sys_sleep+0x88>

0000000080002e68 <sys_kill>:

uint64
sys_kill(void)
{
    80002e68:	1101                	addi	sp,sp,-32
    80002e6a:	ec06                	sd	ra,24(sp)
    80002e6c:	e822                	sd	s0,16(sp)
    80002e6e:	1000                	addi	s0,sp,32
  int pid;

  argint(0, &pid);
    80002e70:	fec40593          	addi	a1,s0,-20
    80002e74:	4501                	li	a0,0
    80002e76:	00000097          	auipc	ra,0x0
    80002e7a:	d9a080e7          	jalr	-614(ra) # 80002c10 <argint>
  return kill(pid);
    80002e7e:	fec42503          	lw	a0,-20(s0)
    80002e82:	fffff097          	auipc	ra,0xfffff
    80002e86:	52a080e7          	jalr	1322(ra) # 800023ac <kill>
}
    80002e8a:	60e2                	ld	ra,24(sp)
    80002e8c:	6442                	ld	s0,16(sp)
    80002e8e:	6105                	addi	sp,sp,32
    80002e90:	8082                	ret

0000000080002e92 <sys_uptime>:

// return how many clock tick interrupts have occurred
// since start.
uint64
sys_uptime(void)
{
    80002e92:	1101                	addi	sp,sp,-32
    80002e94:	ec06                	sd	ra,24(sp)
    80002e96:	e822                	sd	s0,16(sp)
    80002e98:	e426                	sd	s1,8(sp)
    80002e9a:	1000                	addi	s0,sp,32
  uint xticks;

  acquire(&tickslock);
    80002e9c:	00014517          	auipc	a0,0x14
    80002ea0:	b6450513          	addi	a0,a0,-1180 # 80016a00 <tickslock>
    80002ea4:	ffffe097          	auipc	ra,0xffffe
    80002ea8:	d32080e7          	jalr	-718(ra) # 80000bd6 <acquire>
  xticks = ticks;
    80002eac:	00006497          	auipc	s1,0x6
    80002eb0:	ab44a483          	lw	s1,-1356(s1) # 80008960 <ticks>
  release(&tickslock);
    80002eb4:	00014517          	auipc	a0,0x14
    80002eb8:	b4c50513          	addi	a0,a0,-1204 # 80016a00 <tickslock>
    80002ebc:	ffffe097          	auipc	ra,0xffffe
    80002ec0:	dce080e7          	jalr	-562(ra) # 80000c8a <release>
  return xticks;
}
    80002ec4:	02049513          	slli	a0,s1,0x20
    80002ec8:	9101                	srli	a0,a0,0x20
    80002eca:	60e2                	ld	ra,24(sp)
    80002ecc:	6442                	ld	s0,16(sp)
    80002ece:	64a2                	ld	s1,8(sp)
    80002ed0:	6105                	addi	sp,sp,32
    80002ed2:	8082                	ret

0000000080002ed4 <sys_procname>:

uint64
sys_procname(void){
    80002ed4:	7139                	addi	sp,sp,-64
    80002ed6:	fc06                	sd	ra,56(sp)
    80002ed8:	f822                	sd	s0,48(sp)
    80002eda:	f426                	sd	s1,40(sp)
    80002edc:	f04a                	sd	s2,32(sp)
    80002ede:	ec4e                	sd	s3,24(sp)
    80002ee0:	0080                	addi	s0,sp,64
  int pid;
  char* name_ptr;
  char* user_ptr;
  argint(0, &pid);
    80002ee2:	fcc40593          	addi	a1,s0,-52
    80002ee6:	4501                	li	a0,0
    80002ee8:	00000097          	auipc	ra,0x0
    80002eec:	d28080e7          	jalr	-728(ra) # 80002c10 <argint>
  if(pid < 0)
    80002ef0:	fcc42783          	lw	a5,-52(s0)
    return -1;
    80002ef4:	557d                	li	a0,-1
  if(pid < 0)
    80002ef6:	0407ca63          	bltz	a5,80002f4a <sys_procname+0x76>
  name_ptr = name(pid);
    80002efa:	853e                	mv	a0,a5
    80002efc:	fffff097          	auipc	ra,0xfffff
    80002f00:	a84080e7          	jalr	-1404(ra) # 80001980 <name>
    80002f04:	84aa                	mv	s1,a0
  argaddr(1, (uint64 *) &user_ptr);
    80002f06:	fc040593          	addi	a1,s0,-64
    80002f0a:	4505                	li	a0,1
    80002f0c:	00000097          	auipc	ra,0x0
    80002f10:	d24080e7          	jalr	-732(ra) # 80002c30 <argaddr>
  if (copyout(myproc()->pagetable, (uint64)user_ptr, (char*)name_ptr, strlen(name_ptr) + 1) < 0)
    80002f14:	fffff097          	auipc	ra,0xfffff
    80002f18:	be6080e7          	jalr	-1050(ra) # 80001afa <myproc>
    80002f1c:	05053903          	ld	s2,80(a0)
    80002f20:	fc043983          	ld	s3,-64(s0)
    80002f24:	8526                	mv	a0,s1
    80002f26:	ffffe097          	auipc	ra,0xffffe
    80002f2a:	f28080e7          	jalr	-216(ra) # 80000e4e <strlen>
    80002f2e:	0015069b          	addiw	a3,a0,1
    80002f32:	8626                	mv	a2,s1
    80002f34:	85ce                	mv	a1,s3
    80002f36:	854a                	mv	a0,s2
    80002f38:	ffffe097          	auipc	ra,0xffffe
    80002f3c:	734080e7          	jalr	1844(ra) # 8000166c <copyout>
  {
    return -1;
    80002f40:	fff54513          	not	a0,a0
    80002f44:	957d                	srai	a0,a0,0x3f
    80002f46:	8909                	andi	a0,a0,2
    80002f48:	157d                	addi	a0,a0,-1
  }
  return 1;
}
    80002f4a:	70e2                	ld	ra,56(sp)
    80002f4c:	7442                	ld	s0,48(sp)
    80002f4e:	74a2                	ld	s1,40(sp)
    80002f50:	7902                	ld	s2,32(sp)
    80002f52:	69e2                	ld	s3,24(sp)
    80002f54:	6121                	addi	sp,sp,64
    80002f56:	8082                	ret

0000000080002f58 <sys_state>:

uint64
sys_state(void){
    80002f58:	7139                	addi	sp,sp,-64
    80002f5a:	fc06                	sd	ra,56(sp)
    80002f5c:	f822                	sd	s0,48(sp)
    80002f5e:	f426                	sd	s1,40(sp)
    80002f60:	f04a                	sd	s2,32(sp)
    80002f62:	ec4e                	sd	s3,24(sp)
    80002f64:	0080                	addi	s0,sp,64
  int pid;
  char *state_ptr;
  char *user_ptr;
  argint(0, &pid);
    80002f66:	fcc40593          	addi	a1,s0,-52
    80002f6a:	4501                	li	a0,0
    80002f6c:	00000097          	auipc	ra,0x0
    80002f70:	ca4080e7          	jalr	-860(ra) # 80002c10 <argint>
  if(pid < 0)
    80002f74:	fcc42783          	lw	a5,-52(s0)
    return -1;
    80002f78:	557d                	li	a0,-1
  if(pid < 0)
    80002f7a:	0407ca63          	bltz	a5,80002fce <sys_state+0x76>
  state_ptr = state(pid);
    80002f7e:	853e                	mv	a0,a5
    80002f80:	fffff097          	auipc	ra,0xfffff
    80002f84:	ad8080e7          	jalr	-1320(ra) # 80001a58 <state>
    80002f88:	84aa                	mv	s1,a0
  argaddr(1, (uint64 *) &user_ptr);
    80002f8a:	fc040593          	addi	a1,s0,-64
    80002f8e:	4505                	li	a0,1
    80002f90:	00000097          	auipc	ra,0x0
    80002f94:	ca0080e7          	jalr	-864(ra) # 80002c30 <argaddr>
  if(copyout(myproc()->pagetable,(uint64)user_ptr, (char*)state_ptr, strlen(state_ptr) + 1) < 0)
    80002f98:	fffff097          	auipc	ra,0xfffff
    80002f9c:	b62080e7          	jalr	-1182(ra) # 80001afa <myproc>
    80002fa0:	05053903          	ld	s2,80(a0)
    80002fa4:	fc043983          	ld	s3,-64(s0)
    80002fa8:	8526                	mv	a0,s1
    80002faa:	ffffe097          	auipc	ra,0xffffe
    80002fae:	ea4080e7          	jalr	-348(ra) # 80000e4e <strlen>
    80002fb2:	0015069b          	addiw	a3,a0,1
    80002fb6:	8626                	mv	a2,s1
    80002fb8:	85ce                	mv	a1,s3
    80002fba:	854a                	mv	a0,s2
    80002fbc:	ffffe097          	auipc	ra,0xffffe
    80002fc0:	6b0080e7          	jalr	1712(ra) # 8000166c <copyout>
  {
    return -1;
    80002fc4:	fff54513          	not	a0,a0
    80002fc8:	957d                	srai	a0,a0,0x3f
    80002fca:	8909                	andi	a0,a0,2
    80002fcc:	157d                	addi	a0,a0,-1
  }
  return 1;
}
    80002fce:	70e2                	ld	ra,56(sp)
    80002fd0:	7442                	ld	s0,48(sp)
    80002fd2:	74a2                	ld	s1,40(sp)
    80002fd4:	7902                	ld	s2,32(sp)
    80002fd6:	69e2                	ld	s3,24(sp)
    80002fd8:	6121                	addi	sp,sp,64
    80002fda:	8082                	ret

0000000080002fdc <sys_year>:

uint64
sys_year(void)
{
    80002fdc:	7139                	addi	sp,sp,-64
    80002fde:	fc06                	sd	ra,56(sp)
    80002fe0:	f822                	sd	s0,48(sp)
    80002fe2:	f426                	sd	s1,40(sp)
    80002fe4:	f04a                	sd	s2,32(sp)
    80002fe6:	ec4e                	sd	s3,24(sp)
    80002fe8:	0080                	addi	s0,sp,64
  int user_buf_size;
  int count = 0;
  struct proc *p;

  // Fetch the system call arguments: pointer to user buffer and its size
  argaddr(0, (uint64 *)&user_buf);
    80002fea:	fc840593          	addi	a1,s0,-56
    80002fee:	4501                	li	a0,0
    80002ff0:	00000097          	auipc	ra,0x0
    80002ff4:	c40080e7          	jalr	-960(ra) # 80002c30 <argaddr>
  argint(1, &user_buf_size);
    80002ff8:	fc440593          	addi	a1,s0,-60
    80002ffc:	4505                	li	a0,1
    80002ffe:	00000097          	auipc	ra,0x0
    80003002:	c12080e7          	jalr	-1006(ra) # 80002c10 <argint>

  // Check if user_buf_size is valid
  if (user_buf_size <= 0)
    80003006:	fc442783          	lw	a5,-60(s0)
    8000300a:	06f05363          	blez	a5,80003070 <sys_year+0x94>
    8000300e:	0000e497          	auipc	s1,0xe
    80003012:	02248493          	addi	s1,s1,34 # 80011030 <proc+0x30>
    80003016:	00014997          	auipc	s3,0x14
    8000301a:	8b298993          	addi	s3,s3,-1870 # 800168c8 <proc+0x58c8>
  int count = 0;
    8000301e:	4901                	li	s2,0
    80003020:	a809                	j	80003032 <sys_year+0x56>
    return -1;

  // Iterate over the process table and copy PIDs to user buffer
  for(p = proc; p < &proc[NPROC] && count < user_buf_size; p++) {
    80003022:	02998f63          	beq	s3,s1,80003060 <sys_year+0x84>
    80003026:	16848493          	addi	s1,s1,360
    8000302a:	fc442783          	lw	a5,-60(s0)
    8000302e:	02f95963          	bge	s2,a5,80003060 <sys_year+0x84>
    if(p->state != UNUSED) {
    80003032:	fe84a783          	lw	a5,-24(s1)
    80003036:	d7f5                	beqz	a5,80003022 <sys_year+0x46>
      // Check for user-space memory access error
      if(copyout(myproc()->pagetable, (uint64)&user_buf[count], (char*)&p->pid, sizeof(int)) < 0)
    80003038:	fffff097          	auipc	ra,0xfffff
    8000303c:	ac2080e7          	jalr	-1342(ra) # 80001afa <myproc>
    80003040:	00291593          	slli	a1,s2,0x2
    80003044:	4691                	li	a3,4
    80003046:	8626                	mv	a2,s1
    80003048:	fc843783          	ld	a5,-56(s0)
    8000304c:	95be                	add	a1,a1,a5
    8000304e:	6928                	ld	a0,80(a0)
    80003050:	ffffe097          	auipc	ra,0xffffe
    80003054:	61c080e7          	jalr	1564(ra) # 8000166c <copyout>
    80003058:	00054e63          	bltz	a0,80003074 <sys_year+0x98>
        return -1;  // Return error if copyout fails

      count++;
    8000305c:	2905                	addiw	s2,s2,1
    8000305e:	b7d1                	j	80003022 <sys_year+0x46>
    }
  }

  return count;  // Return the number of PIDs written
    80003060:	854a                	mv	a0,s2
}
    80003062:	70e2                	ld	ra,56(sp)
    80003064:	7442                	ld	s0,48(sp)
    80003066:	74a2                	ld	s1,40(sp)
    80003068:	7902                	ld	s2,32(sp)
    8000306a:	69e2                	ld	s3,24(sp)
    8000306c:	6121                	addi	sp,sp,64
    8000306e:	8082                	ret
    return -1;
    80003070:	557d                	li	a0,-1
    80003072:	bfc5                	j	80003062 <sys_year+0x86>
        return -1;  // Return error if copyout fails
    80003074:	557d                	li	a0,-1
    80003076:	b7f5                	j	80003062 <sys_year+0x86>

0000000080003078 <binit>:
  struct buf head;
} bcache;

void
binit(void)
{
    80003078:	7179                	addi	sp,sp,-48
    8000307a:	f406                	sd	ra,40(sp)
    8000307c:	f022                	sd	s0,32(sp)
    8000307e:	ec26                	sd	s1,24(sp)
    80003080:	e84a                	sd	s2,16(sp)
    80003082:	e44e                	sd	s3,8(sp)
    80003084:	e052                	sd	s4,0(sp)
    80003086:	1800                	addi	s0,sp,48
  struct buf *b;

  initlock(&bcache.lock, "bcache");
    80003088:	00005597          	auipc	a1,0x5
    8000308c:	4f058593          	addi	a1,a1,1264 # 80008578 <syscalls+0xc8>
    80003090:	00014517          	auipc	a0,0x14
    80003094:	98850513          	addi	a0,a0,-1656 # 80016a18 <bcache>
    80003098:	ffffe097          	auipc	ra,0xffffe
    8000309c:	aae080e7          	jalr	-1362(ra) # 80000b46 <initlock>

  // Create linked list of buffers
  bcache.head.prev = &bcache.head;
    800030a0:	0001c797          	auipc	a5,0x1c
    800030a4:	97878793          	addi	a5,a5,-1672 # 8001ea18 <bcache+0x8000>
    800030a8:	0001c717          	auipc	a4,0x1c
    800030ac:	bd870713          	addi	a4,a4,-1064 # 8001ec80 <bcache+0x8268>
    800030b0:	2ae7b823          	sd	a4,688(a5)
  bcache.head.next = &bcache.head;
    800030b4:	2ae7bc23          	sd	a4,696(a5)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800030b8:	00014497          	auipc	s1,0x14
    800030bc:	97848493          	addi	s1,s1,-1672 # 80016a30 <bcache+0x18>
    b->next = bcache.head.next;
    800030c0:	893e                	mv	s2,a5
    b->prev = &bcache.head;
    800030c2:	89ba                	mv	s3,a4
    initsleeplock(&b->lock, "buffer");
    800030c4:	00005a17          	auipc	s4,0x5
    800030c8:	4bca0a13          	addi	s4,s4,1212 # 80008580 <syscalls+0xd0>
    b->next = bcache.head.next;
    800030cc:	2b893783          	ld	a5,696(s2)
    800030d0:	e8bc                	sd	a5,80(s1)
    b->prev = &bcache.head;
    800030d2:	0534b423          	sd	s3,72(s1)
    initsleeplock(&b->lock, "buffer");
    800030d6:	85d2                	mv	a1,s4
    800030d8:	01048513          	addi	a0,s1,16
    800030dc:	00001097          	auipc	ra,0x1
    800030e0:	4c8080e7          	jalr	1224(ra) # 800045a4 <initsleeplock>
    bcache.head.next->prev = b;
    800030e4:	2b893783          	ld	a5,696(s2)
    800030e8:	e7a4                	sd	s1,72(a5)
    bcache.head.next = b;
    800030ea:	2a993c23          	sd	s1,696(s2)
  for(b = bcache.buf; b < bcache.buf+NBUF; b++){
    800030ee:	45848493          	addi	s1,s1,1112
    800030f2:	fd349de3          	bne	s1,s3,800030cc <binit+0x54>
  }
}
    800030f6:	70a2                	ld	ra,40(sp)
    800030f8:	7402                	ld	s0,32(sp)
    800030fa:	64e2                	ld	s1,24(sp)
    800030fc:	6942                	ld	s2,16(sp)
    800030fe:	69a2                	ld	s3,8(sp)
    80003100:	6a02                	ld	s4,0(sp)
    80003102:	6145                	addi	sp,sp,48
    80003104:	8082                	ret

0000000080003106 <bread>:
}

// Return a locked buf with the contents of the indicated block.
struct buf*
bread(uint dev, uint blockno)
{
    80003106:	7179                	addi	sp,sp,-48
    80003108:	f406                	sd	ra,40(sp)
    8000310a:	f022                	sd	s0,32(sp)
    8000310c:	ec26                	sd	s1,24(sp)
    8000310e:	e84a                	sd	s2,16(sp)
    80003110:	e44e                	sd	s3,8(sp)
    80003112:	1800                	addi	s0,sp,48
    80003114:	892a                	mv	s2,a0
    80003116:	89ae                	mv	s3,a1
  acquire(&bcache.lock);
    80003118:	00014517          	auipc	a0,0x14
    8000311c:	90050513          	addi	a0,a0,-1792 # 80016a18 <bcache>
    80003120:	ffffe097          	auipc	ra,0xffffe
    80003124:	ab6080e7          	jalr	-1354(ra) # 80000bd6 <acquire>
  for(b = bcache.head.next; b != &bcache.head; b = b->next){
    80003128:	0001c497          	auipc	s1,0x1c
    8000312c:	ba84b483          	ld	s1,-1112(s1) # 8001ecd0 <bcache+0x82b8>
    80003130:	0001c797          	auipc	a5,0x1c
    80003134:	b5078793          	addi	a5,a5,-1200 # 8001ec80 <bcache+0x8268>
    80003138:	02f48f63          	beq	s1,a5,80003176 <bread+0x70>
    8000313c:	873e                	mv	a4,a5
    8000313e:	a021                	j	80003146 <bread+0x40>
    80003140:	68a4                	ld	s1,80(s1)
    80003142:	02e48a63          	beq	s1,a4,80003176 <bread+0x70>
    if(b->dev == dev && b->blockno == blockno){
    80003146:	449c                	lw	a5,8(s1)
    80003148:	ff279ce3          	bne	a5,s2,80003140 <bread+0x3a>
    8000314c:	44dc                	lw	a5,12(s1)
    8000314e:	ff3799e3          	bne	a5,s3,80003140 <bread+0x3a>
      b->refcnt++;
    80003152:	40bc                	lw	a5,64(s1)
    80003154:	2785                	addiw	a5,a5,1
    80003156:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    80003158:	00014517          	auipc	a0,0x14
    8000315c:	8c050513          	addi	a0,a0,-1856 # 80016a18 <bcache>
    80003160:	ffffe097          	auipc	ra,0xffffe
    80003164:	b2a080e7          	jalr	-1238(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    80003168:	01048513          	addi	a0,s1,16
    8000316c:	00001097          	auipc	ra,0x1
    80003170:	472080e7          	jalr	1138(ra) # 800045de <acquiresleep>
      return b;
    80003174:	a8b9                	j	800031d2 <bread+0xcc>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003176:	0001c497          	auipc	s1,0x1c
    8000317a:	b524b483          	ld	s1,-1198(s1) # 8001ecc8 <bcache+0x82b0>
    8000317e:	0001c797          	auipc	a5,0x1c
    80003182:	b0278793          	addi	a5,a5,-1278 # 8001ec80 <bcache+0x8268>
    80003186:	00f48863          	beq	s1,a5,80003196 <bread+0x90>
    8000318a:	873e                	mv	a4,a5
    if(b->refcnt == 0) {
    8000318c:	40bc                	lw	a5,64(s1)
    8000318e:	cf81                	beqz	a5,800031a6 <bread+0xa0>
  for(b = bcache.head.prev; b != &bcache.head; b = b->prev){
    80003190:	64a4                	ld	s1,72(s1)
    80003192:	fee49de3          	bne	s1,a4,8000318c <bread+0x86>
  panic("bget: no buffers");
    80003196:	00005517          	auipc	a0,0x5
    8000319a:	3f250513          	addi	a0,a0,1010 # 80008588 <syscalls+0xd8>
    8000319e:	ffffd097          	auipc	ra,0xffffd
    800031a2:	3a2080e7          	jalr	930(ra) # 80000540 <panic>
      b->dev = dev;
    800031a6:	0124a423          	sw	s2,8(s1)
      b->blockno = blockno;
    800031aa:	0134a623          	sw	s3,12(s1)
      b->valid = 0;
    800031ae:	0004a023          	sw	zero,0(s1)
      b->refcnt = 1;
    800031b2:	4785                	li	a5,1
    800031b4:	c0bc                	sw	a5,64(s1)
      release(&bcache.lock);
    800031b6:	00014517          	auipc	a0,0x14
    800031ba:	86250513          	addi	a0,a0,-1950 # 80016a18 <bcache>
    800031be:	ffffe097          	auipc	ra,0xffffe
    800031c2:	acc080e7          	jalr	-1332(ra) # 80000c8a <release>
      acquiresleep(&b->lock);
    800031c6:	01048513          	addi	a0,s1,16
    800031ca:	00001097          	auipc	ra,0x1
    800031ce:	414080e7          	jalr	1044(ra) # 800045de <acquiresleep>
  struct buf *b;

  b = bget(dev, blockno);
  if(!b->valid) {
    800031d2:	409c                	lw	a5,0(s1)
    800031d4:	cb89                	beqz	a5,800031e6 <bread+0xe0>
    virtio_disk_rw(b, 0);
    b->valid = 1;
  }
  return b;
}
    800031d6:	8526                	mv	a0,s1
    800031d8:	70a2                	ld	ra,40(sp)
    800031da:	7402                	ld	s0,32(sp)
    800031dc:	64e2                	ld	s1,24(sp)
    800031de:	6942                	ld	s2,16(sp)
    800031e0:	69a2                	ld	s3,8(sp)
    800031e2:	6145                	addi	sp,sp,48
    800031e4:	8082                	ret
    virtio_disk_rw(b, 0);
    800031e6:	4581                	li	a1,0
    800031e8:	8526                	mv	a0,s1
    800031ea:	00003097          	auipc	ra,0x3
    800031ee:	fd8080e7          	jalr	-40(ra) # 800061c2 <virtio_disk_rw>
    b->valid = 1;
    800031f2:	4785                	li	a5,1
    800031f4:	c09c                	sw	a5,0(s1)
  return b;
    800031f6:	b7c5                	j	800031d6 <bread+0xd0>

00000000800031f8 <bwrite>:

// Write b's contents to disk.  Must be locked.
void
bwrite(struct buf *b)
{
    800031f8:	1101                	addi	sp,sp,-32
    800031fa:	ec06                	sd	ra,24(sp)
    800031fc:	e822                	sd	s0,16(sp)
    800031fe:	e426                	sd	s1,8(sp)
    80003200:	1000                	addi	s0,sp,32
    80003202:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003204:	0541                	addi	a0,a0,16
    80003206:	00001097          	auipc	ra,0x1
    8000320a:	472080e7          	jalr	1138(ra) # 80004678 <holdingsleep>
    8000320e:	cd01                	beqz	a0,80003226 <bwrite+0x2e>
    panic("bwrite");
  virtio_disk_rw(b, 1);
    80003210:	4585                	li	a1,1
    80003212:	8526                	mv	a0,s1
    80003214:	00003097          	auipc	ra,0x3
    80003218:	fae080e7          	jalr	-82(ra) # 800061c2 <virtio_disk_rw>
}
    8000321c:	60e2                	ld	ra,24(sp)
    8000321e:	6442                	ld	s0,16(sp)
    80003220:	64a2                	ld	s1,8(sp)
    80003222:	6105                	addi	sp,sp,32
    80003224:	8082                	ret
    panic("bwrite");
    80003226:	00005517          	auipc	a0,0x5
    8000322a:	37a50513          	addi	a0,a0,890 # 800085a0 <syscalls+0xf0>
    8000322e:	ffffd097          	auipc	ra,0xffffd
    80003232:	312080e7          	jalr	786(ra) # 80000540 <panic>

0000000080003236 <brelse>:

// Release a locked buffer.
// Move to the head of the most-recently-used list.
void
brelse(struct buf *b)
{
    80003236:	1101                	addi	sp,sp,-32
    80003238:	ec06                	sd	ra,24(sp)
    8000323a:	e822                	sd	s0,16(sp)
    8000323c:	e426                	sd	s1,8(sp)
    8000323e:	e04a                	sd	s2,0(sp)
    80003240:	1000                	addi	s0,sp,32
    80003242:	84aa                	mv	s1,a0
  if(!holdingsleep(&b->lock))
    80003244:	01050913          	addi	s2,a0,16
    80003248:	854a                	mv	a0,s2
    8000324a:	00001097          	auipc	ra,0x1
    8000324e:	42e080e7          	jalr	1070(ra) # 80004678 <holdingsleep>
    80003252:	c92d                	beqz	a0,800032c4 <brelse+0x8e>
    panic("brelse");

  releasesleep(&b->lock);
    80003254:	854a                	mv	a0,s2
    80003256:	00001097          	auipc	ra,0x1
    8000325a:	3de080e7          	jalr	990(ra) # 80004634 <releasesleep>

  acquire(&bcache.lock);
    8000325e:	00013517          	auipc	a0,0x13
    80003262:	7ba50513          	addi	a0,a0,1978 # 80016a18 <bcache>
    80003266:	ffffe097          	auipc	ra,0xffffe
    8000326a:	970080e7          	jalr	-1680(ra) # 80000bd6 <acquire>
  b->refcnt--;
    8000326e:	40bc                	lw	a5,64(s1)
    80003270:	37fd                	addiw	a5,a5,-1
    80003272:	0007871b          	sext.w	a4,a5
    80003276:	c0bc                	sw	a5,64(s1)
  if (b->refcnt == 0) {
    80003278:	eb05                	bnez	a4,800032a8 <brelse+0x72>
    // no one is waiting for it.
    b->next->prev = b->prev;
    8000327a:	68bc                	ld	a5,80(s1)
    8000327c:	64b8                	ld	a4,72(s1)
    8000327e:	e7b8                	sd	a4,72(a5)
    b->prev->next = b->next;
    80003280:	64bc                	ld	a5,72(s1)
    80003282:	68b8                	ld	a4,80(s1)
    80003284:	ebb8                	sd	a4,80(a5)
    b->next = bcache.head.next;
    80003286:	0001b797          	auipc	a5,0x1b
    8000328a:	79278793          	addi	a5,a5,1938 # 8001ea18 <bcache+0x8000>
    8000328e:	2b87b703          	ld	a4,696(a5)
    80003292:	e8b8                	sd	a4,80(s1)
    b->prev = &bcache.head;
    80003294:	0001c717          	auipc	a4,0x1c
    80003298:	9ec70713          	addi	a4,a4,-1556 # 8001ec80 <bcache+0x8268>
    8000329c:	e4b8                	sd	a4,72(s1)
    bcache.head.next->prev = b;
    8000329e:	2b87b703          	ld	a4,696(a5)
    800032a2:	e724                	sd	s1,72(a4)
    bcache.head.next = b;
    800032a4:	2a97bc23          	sd	s1,696(a5)
  }
  
  release(&bcache.lock);
    800032a8:	00013517          	auipc	a0,0x13
    800032ac:	77050513          	addi	a0,a0,1904 # 80016a18 <bcache>
    800032b0:	ffffe097          	auipc	ra,0xffffe
    800032b4:	9da080e7          	jalr	-1574(ra) # 80000c8a <release>
}
    800032b8:	60e2                	ld	ra,24(sp)
    800032ba:	6442                	ld	s0,16(sp)
    800032bc:	64a2                	ld	s1,8(sp)
    800032be:	6902                	ld	s2,0(sp)
    800032c0:	6105                	addi	sp,sp,32
    800032c2:	8082                	ret
    panic("brelse");
    800032c4:	00005517          	auipc	a0,0x5
    800032c8:	2e450513          	addi	a0,a0,740 # 800085a8 <syscalls+0xf8>
    800032cc:	ffffd097          	auipc	ra,0xffffd
    800032d0:	274080e7          	jalr	628(ra) # 80000540 <panic>

00000000800032d4 <bpin>:

void
bpin(struct buf *b) {
    800032d4:	1101                	addi	sp,sp,-32
    800032d6:	ec06                	sd	ra,24(sp)
    800032d8:	e822                	sd	s0,16(sp)
    800032da:	e426                	sd	s1,8(sp)
    800032dc:	1000                	addi	s0,sp,32
    800032de:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    800032e0:	00013517          	auipc	a0,0x13
    800032e4:	73850513          	addi	a0,a0,1848 # 80016a18 <bcache>
    800032e8:	ffffe097          	auipc	ra,0xffffe
    800032ec:	8ee080e7          	jalr	-1810(ra) # 80000bd6 <acquire>
  b->refcnt++;
    800032f0:	40bc                	lw	a5,64(s1)
    800032f2:	2785                	addiw	a5,a5,1
    800032f4:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    800032f6:	00013517          	auipc	a0,0x13
    800032fa:	72250513          	addi	a0,a0,1826 # 80016a18 <bcache>
    800032fe:	ffffe097          	auipc	ra,0xffffe
    80003302:	98c080e7          	jalr	-1652(ra) # 80000c8a <release>
}
    80003306:	60e2                	ld	ra,24(sp)
    80003308:	6442                	ld	s0,16(sp)
    8000330a:	64a2                	ld	s1,8(sp)
    8000330c:	6105                	addi	sp,sp,32
    8000330e:	8082                	ret

0000000080003310 <bunpin>:

void
bunpin(struct buf *b) {
    80003310:	1101                	addi	sp,sp,-32
    80003312:	ec06                	sd	ra,24(sp)
    80003314:	e822                	sd	s0,16(sp)
    80003316:	e426                	sd	s1,8(sp)
    80003318:	1000                	addi	s0,sp,32
    8000331a:	84aa                	mv	s1,a0
  acquire(&bcache.lock);
    8000331c:	00013517          	auipc	a0,0x13
    80003320:	6fc50513          	addi	a0,a0,1788 # 80016a18 <bcache>
    80003324:	ffffe097          	auipc	ra,0xffffe
    80003328:	8b2080e7          	jalr	-1870(ra) # 80000bd6 <acquire>
  b->refcnt--;
    8000332c:	40bc                	lw	a5,64(s1)
    8000332e:	37fd                	addiw	a5,a5,-1
    80003330:	c0bc                	sw	a5,64(s1)
  release(&bcache.lock);
    80003332:	00013517          	auipc	a0,0x13
    80003336:	6e650513          	addi	a0,a0,1766 # 80016a18 <bcache>
    8000333a:	ffffe097          	auipc	ra,0xffffe
    8000333e:	950080e7          	jalr	-1712(ra) # 80000c8a <release>
}
    80003342:	60e2                	ld	ra,24(sp)
    80003344:	6442                	ld	s0,16(sp)
    80003346:	64a2                	ld	s1,8(sp)
    80003348:	6105                	addi	sp,sp,32
    8000334a:	8082                	ret

000000008000334c <bfree>:
}

// Free a disk block.
static void
bfree(int dev, uint b)
{
    8000334c:	1101                	addi	sp,sp,-32
    8000334e:	ec06                	sd	ra,24(sp)
    80003350:	e822                	sd	s0,16(sp)
    80003352:	e426                	sd	s1,8(sp)
    80003354:	e04a                	sd	s2,0(sp)
    80003356:	1000                	addi	s0,sp,32
    80003358:	84ae                	mv	s1,a1
  struct buf *bp;
  int bi, m;

  bp = bread(dev, BBLOCK(b, sb));
    8000335a:	00d5d59b          	srliw	a1,a1,0xd
    8000335e:	0001c797          	auipc	a5,0x1c
    80003362:	d967a783          	lw	a5,-618(a5) # 8001f0f4 <sb+0x1c>
    80003366:	9dbd                	addw	a1,a1,a5
    80003368:	00000097          	auipc	ra,0x0
    8000336c:	d9e080e7          	jalr	-610(ra) # 80003106 <bread>
  bi = b % BPB;
  m = 1 << (bi % 8);
    80003370:	0074f713          	andi	a4,s1,7
    80003374:	4785                	li	a5,1
    80003376:	00e797bb          	sllw	a5,a5,a4
  if((bp->data[bi/8] & m) == 0)
    8000337a:	14ce                	slli	s1,s1,0x33
    8000337c:	90d9                	srli	s1,s1,0x36
    8000337e:	00950733          	add	a4,a0,s1
    80003382:	05874703          	lbu	a4,88(a4)
    80003386:	00e7f6b3          	and	a3,a5,a4
    8000338a:	c69d                	beqz	a3,800033b8 <bfree+0x6c>
    8000338c:	892a                	mv	s2,a0
    panic("freeing free block");
  bp->data[bi/8] &= ~m;
    8000338e:	94aa                	add	s1,s1,a0
    80003390:	fff7c793          	not	a5,a5
    80003394:	8f7d                	and	a4,a4,a5
    80003396:	04e48c23          	sb	a4,88(s1)
  log_write(bp);
    8000339a:	00001097          	auipc	ra,0x1
    8000339e:	126080e7          	jalr	294(ra) # 800044c0 <log_write>
  brelse(bp);
    800033a2:	854a                	mv	a0,s2
    800033a4:	00000097          	auipc	ra,0x0
    800033a8:	e92080e7          	jalr	-366(ra) # 80003236 <brelse>
}
    800033ac:	60e2                	ld	ra,24(sp)
    800033ae:	6442                	ld	s0,16(sp)
    800033b0:	64a2                	ld	s1,8(sp)
    800033b2:	6902                	ld	s2,0(sp)
    800033b4:	6105                	addi	sp,sp,32
    800033b6:	8082                	ret
    panic("freeing free block");
    800033b8:	00005517          	auipc	a0,0x5
    800033bc:	1f850513          	addi	a0,a0,504 # 800085b0 <syscalls+0x100>
    800033c0:	ffffd097          	auipc	ra,0xffffd
    800033c4:	180080e7          	jalr	384(ra) # 80000540 <panic>

00000000800033c8 <balloc>:
{
    800033c8:	711d                	addi	sp,sp,-96
    800033ca:	ec86                	sd	ra,88(sp)
    800033cc:	e8a2                	sd	s0,80(sp)
    800033ce:	e4a6                	sd	s1,72(sp)
    800033d0:	e0ca                	sd	s2,64(sp)
    800033d2:	fc4e                	sd	s3,56(sp)
    800033d4:	f852                	sd	s4,48(sp)
    800033d6:	f456                	sd	s5,40(sp)
    800033d8:	f05a                	sd	s6,32(sp)
    800033da:	ec5e                	sd	s7,24(sp)
    800033dc:	e862                	sd	s8,16(sp)
    800033de:	e466                	sd	s9,8(sp)
    800033e0:	1080                	addi	s0,sp,96
  for(b = 0; b < sb.size; b += BPB){
    800033e2:	0001c797          	auipc	a5,0x1c
    800033e6:	cfa7a783          	lw	a5,-774(a5) # 8001f0dc <sb+0x4>
    800033ea:	cff5                	beqz	a5,800034e6 <balloc+0x11e>
    800033ec:	8baa                	mv	s7,a0
    800033ee:	4a81                	li	s5,0
    bp = bread(dev, BBLOCK(b, sb));
    800033f0:	0001cb17          	auipc	s6,0x1c
    800033f4:	ce8b0b13          	addi	s6,s6,-792 # 8001f0d8 <sb>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033f8:	4c01                	li	s8,0
      m = 1 << (bi % 8);
    800033fa:	4985                	li	s3,1
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800033fc:	6a09                	lui	s4,0x2
  for(b = 0; b < sb.size; b += BPB){
    800033fe:	6c89                	lui	s9,0x2
    80003400:	a061                	j	80003488 <balloc+0xc0>
        bp->data[bi/8] |= m;  // Mark block in use.
    80003402:	97ca                	add	a5,a5,s2
    80003404:	8e55                	or	a2,a2,a3
    80003406:	04c78c23          	sb	a2,88(a5)
        log_write(bp);
    8000340a:	854a                	mv	a0,s2
    8000340c:	00001097          	auipc	ra,0x1
    80003410:	0b4080e7          	jalr	180(ra) # 800044c0 <log_write>
        brelse(bp);
    80003414:	854a                	mv	a0,s2
    80003416:	00000097          	auipc	ra,0x0
    8000341a:	e20080e7          	jalr	-480(ra) # 80003236 <brelse>
  bp = bread(dev, bno);
    8000341e:	85a6                	mv	a1,s1
    80003420:	855e                	mv	a0,s7
    80003422:	00000097          	auipc	ra,0x0
    80003426:	ce4080e7          	jalr	-796(ra) # 80003106 <bread>
    8000342a:	892a                	mv	s2,a0
  memset(bp->data, 0, BSIZE);
    8000342c:	40000613          	li	a2,1024
    80003430:	4581                	li	a1,0
    80003432:	05850513          	addi	a0,a0,88
    80003436:	ffffe097          	auipc	ra,0xffffe
    8000343a:	89c080e7          	jalr	-1892(ra) # 80000cd2 <memset>
  log_write(bp);
    8000343e:	854a                	mv	a0,s2
    80003440:	00001097          	auipc	ra,0x1
    80003444:	080080e7          	jalr	128(ra) # 800044c0 <log_write>
  brelse(bp);
    80003448:	854a                	mv	a0,s2
    8000344a:	00000097          	auipc	ra,0x0
    8000344e:	dec080e7          	jalr	-532(ra) # 80003236 <brelse>
}
    80003452:	8526                	mv	a0,s1
    80003454:	60e6                	ld	ra,88(sp)
    80003456:	6446                	ld	s0,80(sp)
    80003458:	64a6                	ld	s1,72(sp)
    8000345a:	6906                	ld	s2,64(sp)
    8000345c:	79e2                	ld	s3,56(sp)
    8000345e:	7a42                	ld	s4,48(sp)
    80003460:	7aa2                	ld	s5,40(sp)
    80003462:	7b02                	ld	s6,32(sp)
    80003464:	6be2                	ld	s7,24(sp)
    80003466:	6c42                	ld	s8,16(sp)
    80003468:	6ca2                	ld	s9,8(sp)
    8000346a:	6125                	addi	sp,sp,96
    8000346c:	8082                	ret
    brelse(bp);
    8000346e:	854a                	mv	a0,s2
    80003470:	00000097          	auipc	ra,0x0
    80003474:	dc6080e7          	jalr	-570(ra) # 80003236 <brelse>
  for(b = 0; b < sb.size; b += BPB){
    80003478:	015c87bb          	addw	a5,s9,s5
    8000347c:	00078a9b          	sext.w	s5,a5
    80003480:	004b2703          	lw	a4,4(s6)
    80003484:	06eaf163          	bgeu	s5,a4,800034e6 <balloc+0x11e>
    bp = bread(dev, BBLOCK(b, sb));
    80003488:	41fad79b          	sraiw	a5,s5,0x1f
    8000348c:	0137d79b          	srliw	a5,a5,0x13
    80003490:	015787bb          	addw	a5,a5,s5
    80003494:	40d7d79b          	sraiw	a5,a5,0xd
    80003498:	01cb2583          	lw	a1,28(s6)
    8000349c:	9dbd                	addw	a1,a1,a5
    8000349e:	855e                	mv	a0,s7
    800034a0:	00000097          	auipc	ra,0x0
    800034a4:	c66080e7          	jalr	-922(ra) # 80003106 <bread>
    800034a8:	892a                	mv	s2,a0
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034aa:	004b2503          	lw	a0,4(s6)
    800034ae:	000a849b          	sext.w	s1,s5
    800034b2:	8762                	mv	a4,s8
    800034b4:	faa4fde3          	bgeu	s1,a0,8000346e <balloc+0xa6>
      m = 1 << (bi % 8);
    800034b8:	00777693          	andi	a3,a4,7
    800034bc:	00d996bb          	sllw	a3,s3,a3
      if((bp->data[bi/8] & m) == 0){  // Is block free?
    800034c0:	41f7579b          	sraiw	a5,a4,0x1f
    800034c4:	01d7d79b          	srliw	a5,a5,0x1d
    800034c8:	9fb9                	addw	a5,a5,a4
    800034ca:	4037d79b          	sraiw	a5,a5,0x3
    800034ce:	00f90633          	add	a2,s2,a5
    800034d2:	05864603          	lbu	a2,88(a2)
    800034d6:	00c6f5b3          	and	a1,a3,a2
    800034da:	d585                	beqz	a1,80003402 <balloc+0x3a>
    for(bi = 0; bi < BPB && b + bi < sb.size; bi++){
    800034dc:	2705                	addiw	a4,a4,1
    800034de:	2485                	addiw	s1,s1,1
    800034e0:	fd471ae3          	bne	a4,s4,800034b4 <balloc+0xec>
    800034e4:	b769                	j	8000346e <balloc+0xa6>
  printf("balloc: out of blocks\n");
    800034e6:	00005517          	auipc	a0,0x5
    800034ea:	0e250513          	addi	a0,a0,226 # 800085c8 <syscalls+0x118>
    800034ee:	ffffd097          	auipc	ra,0xffffd
    800034f2:	09c080e7          	jalr	156(ra) # 8000058a <printf>
  return 0;
    800034f6:	4481                	li	s1,0
    800034f8:	bfa9                	j	80003452 <balloc+0x8a>

00000000800034fa <bmap>:
// Return the disk block address of the nth block in inode ip.
// If there is no such block, bmap allocates one.
// returns 0 if out of disk space.
static uint
bmap(struct inode *ip, uint bn)
{
    800034fa:	7179                	addi	sp,sp,-48
    800034fc:	f406                	sd	ra,40(sp)
    800034fe:	f022                	sd	s0,32(sp)
    80003500:	ec26                	sd	s1,24(sp)
    80003502:	e84a                	sd	s2,16(sp)
    80003504:	e44e                	sd	s3,8(sp)
    80003506:	e052                	sd	s4,0(sp)
    80003508:	1800                	addi	s0,sp,48
    8000350a:	89aa                	mv	s3,a0
  uint addr, *a;
  struct buf *bp;

  if(bn < NDIRECT){
    8000350c:	47ad                	li	a5,11
    8000350e:	02b7e863          	bltu	a5,a1,8000353e <bmap+0x44>
    if((addr = ip->addrs[bn]) == 0){
    80003512:	02059793          	slli	a5,a1,0x20
    80003516:	01e7d593          	srli	a1,a5,0x1e
    8000351a:	00b504b3          	add	s1,a0,a1
    8000351e:	0504a903          	lw	s2,80(s1)
    80003522:	06091e63          	bnez	s2,8000359e <bmap+0xa4>
      addr = balloc(ip->dev);
    80003526:	4108                	lw	a0,0(a0)
    80003528:	00000097          	auipc	ra,0x0
    8000352c:	ea0080e7          	jalr	-352(ra) # 800033c8 <balloc>
    80003530:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003534:	06090563          	beqz	s2,8000359e <bmap+0xa4>
        return 0;
      ip->addrs[bn] = addr;
    80003538:	0524a823          	sw	s2,80(s1)
    8000353c:	a08d                	j	8000359e <bmap+0xa4>
    }
    return addr;
  }
  bn -= NDIRECT;
    8000353e:	ff45849b          	addiw	s1,a1,-12
    80003542:	0004871b          	sext.w	a4,s1

  if(bn < NINDIRECT){
    80003546:	0ff00793          	li	a5,255
    8000354a:	08e7e563          	bltu	a5,a4,800035d4 <bmap+0xda>
    // Load indirect block, allocating if necessary.
    if((addr = ip->addrs[NDIRECT]) == 0){
    8000354e:	08052903          	lw	s2,128(a0)
    80003552:	00091d63          	bnez	s2,8000356c <bmap+0x72>
      addr = balloc(ip->dev);
    80003556:	4108                	lw	a0,0(a0)
    80003558:	00000097          	auipc	ra,0x0
    8000355c:	e70080e7          	jalr	-400(ra) # 800033c8 <balloc>
    80003560:	0005091b          	sext.w	s2,a0
      if(addr == 0)
    80003564:	02090d63          	beqz	s2,8000359e <bmap+0xa4>
        return 0;
      ip->addrs[NDIRECT] = addr;
    80003568:	0929a023          	sw	s2,128(s3)
    }
    bp = bread(ip->dev, addr);
    8000356c:	85ca                	mv	a1,s2
    8000356e:	0009a503          	lw	a0,0(s3)
    80003572:	00000097          	auipc	ra,0x0
    80003576:	b94080e7          	jalr	-1132(ra) # 80003106 <bread>
    8000357a:	8a2a                	mv	s4,a0
    a = (uint*)bp->data;
    8000357c:	05850793          	addi	a5,a0,88
    if((addr = a[bn]) == 0){
    80003580:	02049713          	slli	a4,s1,0x20
    80003584:	01e75593          	srli	a1,a4,0x1e
    80003588:	00b784b3          	add	s1,a5,a1
    8000358c:	0004a903          	lw	s2,0(s1)
    80003590:	02090063          	beqz	s2,800035b0 <bmap+0xb6>
      if(addr){
        a[bn] = addr;
        log_write(bp);
      }
    }
    brelse(bp);
    80003594:	8552                	mv	a0,s4
    80003596:	00000097          	auipc	ra,0x0
    8000359a:	ca0080e7          	jalr	-864(ra) # 80003236 <brelse>
    return addr;
  }

  panic("bmap: out of range");
}
    8000359e:	854a                	mv	a0,s2
    800035a0:	70a2                	ld	ra,40(sp)
    800035a2:	7402                	ld	s0,32(sp)
    800035a4:	64e2                	ld	s1,24(sp)
    800035a6:	6942                	ld	s2,16(sp)
    800035a8:	69a2                	ld	s3,8(sp)
    800035aa:	6a02                	ld	s4,0(sp)
    800035ac:	6145                	addi	sp,sp,48
    800035ae:	8082                	ret
      addr = balloc(ip->dev);
    800035b0:	0009a503          	lw	a0,0(s3)
    800035b4:	00000097          	auipc	ra,0x0
    800035b8:	e14080e7          	jalr	-492(ra) # 800033c8 <balloc>
    800035bc:	0005091b          	sext.w	s2,a0
      if(addr){
    800035c0:	fc090ae3          	beqz	s2,80003594 <bmap+0x9a>
        a[bn] = addr;
    800035c4:	0124a023          	sw	s2,0(s1)
        log_write(bp);
    800035c8:	8552                	mv	a0,s4
    800035ca:	00001097          	auipc	ra,0x1
    800035ce:	ef6080e7          	jalr	-266(ra) # 800044c0 <log_write>
    800035d2:	b7c9                	j	80003594 <bmap+0x9a>
  panic("bmap: out of range");
    800035d4:	00005517          	auipc	a0,0x5
    800035d8:	00c50513          	addi	a0,a0,12 # 800085e0 <syscalls+0x130>
    800035dc:	ffffd097          	auipc	ra,0xffffd
    800035e0:	f64080e7          	jalr	-156(ra) # 80000540 <panic>

00000000800035e4 <iget>:
{
    800035e4:	7179                	addi	sp,sp,-48
    800035e6:	f406                	sd	ra,40(sp)
    800035e8:	f022                	sd	s0,32(sp)
    800035ea:	ec26                	sd	s1,24(sp)
    800035ec:	e84a                	sd	s2,16(sp)
    800035ee:	e44e                	sd	s3,8(sp)
    800035f0:	e052                	sd	s4,0(sp)
    800035f2:	1800                	addi	s0,sp,48
    800035f4:	89aa                	mv	s3,a0
    800035f6:	8a2e                	mv	s4,a1
  acquire(&itable.lock);
    800035f8:	0001c517          	auipc	a0,0x1c
    800035fc:	b0050513          	addi	a0,a0,-1280 # 8001f0f8 <itable>
    80003600:	ffffd097          	auipc	ra,0xffffd
    80003604:	5d6080e7          	jalr	1494(ra) # 80000bd6 <acquire>
  empty = 0;
    80003608:	4901                	li	s2,0
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    8000360a:	0001c497          	auipc	s1,0x1c
    8000360e:	b0648493          	addi	s1,s1,-1274 # 8001f110 <itable+0x18>
    80003612:	0001d697          	auipc	a3,0x1d
    80003616:	58e68693          	addi	a3,a3,1422 # 80020ba0 <log>
    8000361a:	a039                	j	80003628 <iget+0x44>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    8000361c:	02090b63          	beqz	s2,80003652 <iget+0x6e>
  for(ip = &itable.inode[0]; ip < &itable.inode[NINODE]; ip++){
    80003620:	08848493          	addi	s1,s1,136
    80003624:	02d48a63          	beq	s1,a3,80003658 <iget+0x74>
    if(ip->ref > 0 && ip->dev == dev && ip->inum == inum){
    80003628:	449c                	lw	a5,8(s1)
    8000362a:	fef059e3          	blez	a5,8000361c <iget+0x38>
    8000362e:	4098                	lw	a4,0(s1)
    80003630:	ff3716e3          	bne	a4,s3,8000361c <iget+0x38>
    80003634:	40d8                	lw	a4,4(s1)
    80003636:	ff4713e3          	bne	a4,s4,8000361c <iget+0x38>
      ip->ref++;
    8000363a:	2785                	addiw	a5,a5,1
    8000363c:	c49c                	sw	a5,8(s1)
      release(&itable.lock);
    8000363e:	0001c517          	auipc	a0,0x1c
    80003642:	aba50513          	addi	a0,a0,-1350 # 8001f0f8 <itable>
    80003646:	ffffd097          	auipc	ra,0xffffd
    8000364a:	644080e7          	jalr	1604(ra) # 80000c8a <release>
      return ip;
    8000364e:	8926                	mv	s2,s1
    80003650:	a03d                	j	8000367e <iget+0x9a>
    if(empty == 0 && ip->ref == 0)    // Remember empty slot.
    80003652:	f7f9                	bnez	a5,80003620 <iget+0x3c>
    80003654:	8926                	mv	s2,s1
    80003656:	b7e9                	j	80003620 <iget+0x3c>
  if(empty == 0)
    80003658:	02090c63          	beqz	s2,80003690 <iget+0xac>
  ip->dev = dev;
    8000365c:	01392023          	sw	s3,0(s2)
  ip->inum = inum;
    80003660:	01492223          	sw	s4,4(s2)
  ip->ref = 1;
    80003664:	4785                	li	a5,1
    80003666:	00f92423          	sw	a5,8(s2)
  ip->valid = 0;
    8000366a:	04092023          	sw	zero,64(s2)
  release(&itable.lock);
    8000366e:	0001c517          	auipc	a0,0x1c
    80003672:	a8a50513          	addi	a0,a0,-1398 # 8001f0f8 <itable>
    80003676:	ffffd097          	auipc	ra,0xffffd
    8000367a:	614080e7          	jalr	1556(ra) # 80000c8a <release>
}
    8000367e:	854a                	mv	a0,s2
    80003680:	70a2                	ld	ra,40(sp)
    80003682:	7402                	ld	s0,32(sp)
    80003684:	64e2                	ld	s1,24(sp)
    80003686:	6942                	ld	s2,16(sp)
    80003688:	69a2                	ld	s3,8(sp)
    8000368a:	6a02                	ld	s4,0(sp)
    8000368c:	6145                	addi	sp,sp,48
    8000368e:	8082                	ret
    panic("iget: no inodes");
    80003690:	00005517          	auipc	a0,0x5
    80003694:	f6850513          	addi	a0,a0,-152 # 800085f8 <syscalls+0x148>
    80003698:	ffffd097          	auipc	ra,0xffffd
    8000369c:	ea8080e7          	jalr	-344(ra) # 80000540 <panic>

00000000800036a0 <fsinit>:
fsinit(int dev) {
    800036a0:	7179                	addi	sp,sp,-48
    800036a2:	f406                	sd	ra,40(sp)
    800036a4:	f022                	sd	s0,32(sp)
    800036a6:	ec26                	sd	s1,24(sp)
    800036a8:	e84a                	sd	s2,16(sp)
    800036aa:	e44e                	sd	s3,8(sp)
    800036ac:	1800                	addi	s0,sp,48
    800036ae:	892a                	mv	s2,a0
  bp = bread(dev, 1);
    800036b0:	4585                	li	a1,1
    800036b2:	00000097          	auipc	ra,0x0
    800036b6:	a54080e7          	jalr	-1452(ra) # 80003106 <bread>
    800036ba:	84aa                	mv	s1,a0
  memmove(sb, bp->data, sizeof(*sb));
    800036bc:	0001c997          	auipc	s3,0x1c
    800036c0:	a1c98993          	addi	s3,s3,-1508 # 8001f0d8 <sb>
    800036c4:	02000613          	li	a2,32
    800036c8:	05850593          	addi	a1,a0,88
    800036cc:	854e                	mv	a0,s3
    800036ce:	ffffd097          	auipc	ra,0xffffd
    800036d2:	660080e7          	jalr	1632(ra) # 80000d2e <memmove>
  brelse(bp);
    800036d6:	8526                	mv	a0,s1
    800036d8:	00000097          	auipc	ra,0x0
    800036dc:	b5e080e7          	jalr	-1186(ra) # 80003236 <brelse>
  if(sb.magic != FSMAGIC)
    800036e0:	0009a703          	lw	a4,0(s3)
    800036e4:	102037b7          	lui	a5,0x10203
    800036e8:	04078793          	addi	a5,a5,64 # 10203040 <_entry-0x6fdfcfc0>
    800036ec:	02f71263          	bne	a4,a5,80003710 <fsinit+0x70>
  initlog(dev, &sb);
    800036f0:	0001c597          	auipc	a1,0x1c
    800036f4:	9e858593          	addi	a1,a1,-1560 # 8001f0d8 <sb>
    800036f8:	854a                	mv	a0,s2
    800036fa:	00001097          	auipc	ra,0x1
    800036fe:	b4a080e7          	jalr	-1206(ra) # 80004244 <initlog>
}
    80003702:	70a2                	ld	ra,40(sp)
    80003704:	7402                	ld	s0,32(sp)
    80003706:	64e2                	ld	s1,24(sp)
    80003708:	6942                	ld	s2,16(sp)
    8000370a:	69a2                	ld	s3,8(sp)
    8000370c:	6145                	addi	sp,sp,48
    8000370e:	8082                	ret
    panic("invalid file system");
    80003710:	00005517          	auipc	a0,0x5
    80003714:	ef850513          	addi	a0,a0,-264 # 80008608 <syscalls+0x158>
    80003718:	ffffd097          	auipc	ra,0xffffd
    8000371c:	e28080e7          	jalr	-472(ra) # 80000540 <panic>

0000000080003720 <iinit>:
{
    80003720:	7179                	addi	sp,sp,-48
    80003722:	f406                	sd	ra,40(sp)
    80003724:	f022                	sd	s0,32(sp)
    80003726:	ec26                	sd	s1,24(sp)
    80003728:	e84a                	sd	s2,16(sp)
    8000372a:	e44e                	sd	s3,8(sp)
    8000372c:	1800                	addi	s0,sp,48
  initlock(&itable.lock, "itable");
    8000372e:	00005597          	auipc	a1,0x5
    80003732:	ef258593          	addi	a1,a1,-270 # 80008620 <syscalls+0x170>
    80003736:	0001c517          	auipc	a0,0x1c
    8000373a:	9c250513          	addi	a0,a0,-1598 # 8001f0f8 <itable>
    8000373e:	ffffd097          	auipc	ra,0xffffd
    80003742:	408080e7          	jalr	1032(ra) # 80000b46 <initlock>
  for(i = 0; i < NINODE; i++) {
    80003746:	0001c497          	auipc	s1,0x1c
    8000374a:	9da48493          	addi	s1,s1,-1574 # 8001f120 <itable+0x28>
    8000374e:	0001d997          	auipc	s3,0x1d
    80003752:	46298993          	addi	s3,s3,1122 # 80020bb0 <log+0x10>
    initsleeplock(&itable.inode[i].lock, "inode");
    80003756:	00005917          	auipc	s2,0x5
    8000375a:	ed290913          	addi	s2,s2,-302 # 80008628 <syscalls+0x178>
    8000375e:	85ca                	mv	a1,s2
    80003760:	8526                	mv	a0,s1
    80003762:	00001097          	auipc	ra,0x1
    80003766:	e42080e7          	jalr	-446(ra) # 800045a4 <initsleeplock>
  for(i = 0; i < NINODE; i++) {
    8000376a:	08848493          	addi	s1,s1,136
    8000376e:	ff3498e3          	bne	s1,s3,8000375e <iinit+0x3e>
}
    80003772:	70a2                	ld	ra,40(sp)
    80003774:	7402                	ld	s0,32(sp)
    80003776:	64e2                	ld	s1,24(sp)
    80003778:	6942                	ld	s2,16(sp)
    8000377a:	69a2                	ld	s3,8(sp)
    8000377c:	6145                	addi	sp,sp,48
    8000377e:	8082                	ret

0000000080003780 <ialloc>:
{
    80003780:	715d                	addi	sp,sp,-80
    80003782:	e486                	sd	ra,72(sp)
    80003784:	e0a2                	sd	s0,64(sp)
    80003786:	fc26                	sd	s1,56(sp)
    80003788:	f84a                	sd	s2,48(sp)
    8000378a:	f44e                	sd	s3,40(sp)
    8000378c:	f052                	sd	s4,32(sp)
    8000378e:	ec56                	sd	s5,24(sp)
    80003790:	e85a                	sd	s6,16(sp)
    80003792:	e45e                	sd	s7,8(sp)
    80003794:	0880                	addi	s0,sp,80
  for(inum = 1; inum < sb.ninodes; inum++){
    80003796:	0001c717          	auipc	a4,0x1c
    8000379a:	94e72703          	lw	a4,-1714(a4) # 8001f0e4 <sb+0xc>
    8000379e:	4785                	li	a5,1
    800037a0:	04e7fa63          	bgeu	a5,a4,800037f4 <ialloc+0x74>
    800037a4:	8aaa                	mv	s5,a0
    800037a6:	8bae                	mv	s7,a1
    800037a8:	4485                	li	s1,1
    bp = bread(dev, IBLOCK(inum, sb));
    800037aa:	0001ca17          	auipc	s4,0x1c
    800037ae:	92ea0a13          	addi	s4,s4,-1746 # 8001f0d8 <sb>
    800037b2:	00048b1b          	sext.w	s6,s1
    800037b6:	0044d593          	srli	a1,s1,0x4
    800037ba:	018a2783          	lw	a5,24(s4)
    800037be:	9dbd                	addw	a1,a1,a5
    800037c0:	8556                	mv	a0,s5
    800037c2:	00000097          	auipc	ra,0x0
    800037c6:	944080e7          	jalr	-1724(ra) # 80003106 <bread>
    800037ca:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + inum%IPB;
    800037cc:	05850993          	addi	s3,a0,88
    800037d0:	00f4f793          	andi	a5,s1,15
    800037d4:	079a                	slli	a5,a5,0x6
    800037d6:	99be                	add	s3,s3,a5
    if(dip->type == 0){  // a free inode
    800037d8:	00099783          	lh	a5,0(s3)
    800037dc:	c3a1                	beqz	a5,8000381c <ialloc+0x9c>
    brelse(bp);
    800037de:	00000097          	auipc	ra,0x0
    800037e2:	a58080e7          	jalr	-1448(ra) # 80003236 <brelse>
  for(inum = 1; inum < sb.ninodes; inum++){
    800037e6:	0485                	addi	s1,s1,1
    800037e8:	00ca2703          	lw	a4,12(s4)
    800037ec:	0004879b          	sext.w	a5,s1
    800037f0:	fce7e1e3          	bltu	a5,a4,800037b2 <ialloc+0x32>
  printf("ialloc: no inodes\n");
    800037f4:	00005517          	auipc	a0,0x5
    800037f8:	e3c50513          	addi	a0,a0,-452 # 80008630 <syscalls+0x180>
    800037fc:	ffffd097          	auipc	ra,0xffffd
    80003800:	d8e080e7          	jalr	-626(ra) # 8000058a <printf>
  return 0;
    80003804:	4501                	li	a0,0
}
    80003806:	60a6                	ld	ra,72(sp)
    80003808:	6406                	ld	s0,64(sp)
    8000380a:	74e2                	ld	s1,56(sp)
    8000380c:	7942                	ld	s2,48(sp)
    8000380e:	79a2                	ld	s3,40(sp)
    80003810:	7a02                	ld	s4,32(sp)
    80003812:	6ae2                	ld	s5,24(sp)
    80003814:	6b42                	ld	s6,16(sp)
    80003816:	6ba2                	ld	s7,8(sp)
    80003818:	6161                	addi	sp,sp,80
    8000381a:	8082                	ret
      memset(dip, 0, sizeof(*dip));
    8000381c:	04000613          	li	a2,64
    80003820:	4581                	li	a1,0
    80003822:	854e                	mv	a0,s3
    80003824:	ffffd097          	auipc	ra,0xffffd
    80003828:	4ae080e7          	jalr	1198(ra) # 80000cd2 <memset>
      dip->type = type;
    8000382c:	01799023          	sh	s7,0(s3)
      log_write(bp);   // mark it allocated on the disk
    80003830:	854a                	mv	a0,s2
    80003832:	00001097          	auipc	ra,0x1
    80003836:	c8e080e7          	jalr	-882(ra) # 800044c0 <log_write>
      brelse(bp);
    8000383a:	854a                	mv	a0,s2
    8000383c:	00000097          	auipc	ra,0x0
    80003840:	9fa080e7          	jalr	-1542(ra) # 80003236 <brelse>
      return iget(dev, inum);
    80003844:	85da                	mv	a1,s6
    80003846:	8556                	mv	a0,s5
    80003848:	00000097          	auipc	ra,0x0
    8000384c:	d9c080e7          	jalr	-612(ra) # 800035e4 <iget>
    80003850:	bf5d                	j	80003806 <ialloc+0x86>

0000000080003852 <iupdate>:
{
    80003852:	1101                	addi	sp,sp,-32
    80003854:	ec06                	sd	ra,24(sp)
    80003856:	e822                	sd	s0,16(sp)
    80003858:	e426                	sd	s1,8(sp)
    8000385a:	e04a                	sd	s2,0(sp)
    8000385c:	1000                	addi	s0,sp,32
    8000385e:	84aa                	mv	s1,a0
  bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    80003860:	415c                	lw	a5,4(a0)
    80003862:	0047d79b          	srliw	a5,a5,0x4
    80003866:	0001c597          	auipc	a1,0x1c
    8000386a:	88a5a583          	lw	a1,-1910(a1) # 8001f0f0 <sb+0x18>
    8000386e:	9dbd                	addw	a1,a1,a5
    80003870:	4108                	lw	a0,0(a0)
    80003872:	00000097          	auipc	ra,0x0
    80003876:	894080e7          	jalr	-1900(ra) # 80003106 <bread>
    8000387a:	892a                	mv	s2,a0
  dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000387c:	05850793          	addi	a5,a0,88
    80003880:	40d8                	lw	a4,4(s1)
    80003882:	8b3d                	andi	a4,a4,15
    80003884:	071a                	slli	a4,a4,0x6
    80003886:	97ba                	add	a5,a5,a4
  dip->type = ip->type;
    80003888:	04449703          	lh	a4,68(s1)
    8000388c:	00e79023          	sh	a4,0(a5)
  dip->major = ip->major;
    80003890:	04649703          	lh	a4,70(s1)
    80003894:	00e79123          	sh	a4,2(a5)
  dip->minor = ip->minor;
    80003898:	04849703          	lh	a4,72(s1)
    8000389c:	00e79223          	sh	a4,4(a5)
  dip->nlink = ip->nlink;
    800038a0:	04a49703          	lh	a4,74(s1)
    800038a4:	00e79323          	sh	a4,6(a5)
  dip->size = ip->size;
    800038a8:	44f8                	lw	a4,76(s1)
    800038aa:	c798                	sw	a4,8(a5)
  memmove(dip->addrs, ip->addrs, sizeof(ip->addrs));
    800038ac:	03400613          	li	a2,52
    800038b0:	05048593          	addi	a1,s1,80
    800038b4:	00c78513          	addi	a0,a5,12
    800038b8:	ffffd097          	auipc	ra,0xffffd
    800038bc:	476080e7          	jalr	1142(ra) # 80000d2e <memmove>
  log_write(bp);
    800038c0:	854a                	mv	a0,s2
    800038c2:	00001097          	auipc	ra,0x1
    800038c6:	bfe080e7          	jalr	-1026(ra) # 800044c0 <log_write>
  brelse(bp);
    800038ca:	854a                	mv	a0,s2
    800038cc:	00000097          	auipc	ra,0x0
    800038d0:	96a080e7          	jalr	-1686(ra) # 80003236 <brelse>
}
    800038d4:	60e2                	ld	ra,24(sp)
    800038d6:	6442                	ld	s0,16(sp)
    800038d8:	64a2                	ld	s1,8(sp)
    800038da:	6902                	ld	s2,0(sp)
    800038dc:	6105                	addi	sp,sp,32
    800038de:	8082                	ret

00000000800038e0 <idup>:
{
    800038e0:	1101                	addi	sp,sp,-32
    800038e2:	ec06                	sd	ra,24(sp)
    800038e4:	e822                	sd	s0,16(sp)
    800038e6:	e426                	sd	s1,8(sp)
    800038e8:	1000                	addi	s0,sp,32
    800038ea:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    800038ec:	0001c517          	auipc	a0,0x1c
    800038f0:	80c50513          	addi	a0,a0,-2036 # 8001f0f8 <itable>
    800038f4:	ffffd097          	auipc	ra,0xffffd
    800038f8:	2e2080e7          	jalr	738(ra) # 80000bd6 <acquire>
  ip->ref++;
    800038fc:	449c                	lw	a5,8(s1)
    800038fe:	2785                	addiw	a5,a5,1
    80003900:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003902:	0001b517          	auipc	a0,0x1b
    80003906:	7f650513          	addi	a0,a0,2038 # 8001f0f8 <itable>
    8000390a:	ffffd097          	auipc	ra,0xffffd
    8000390e:	380080e7          	jalr	896(ra) # 80000c8a <release>
}
    80003912:	8526                	mv	a0,s1
    80003914:	60e2                	ld	ra,24(sp)
    80003916:	6442                	ld	s0,16(sp)
    80003918:	64a2                	ld	s1,8(sp)
    8000391a:	6105                	addi	sp,sp,32
    8000391c:	8082                	ret

000000008000391e <ilock>:
{
    8000391e:	1101                	addi	sp,sp,-32
    80003920:	ec06                	sd	ra,24(sp)
    80003922:	e822                	sd	s0,16(sp)
    80003924:	e426                	sd	s1,8(sp)
    80003926:	e04a                	sd	s2,0(sp)
    80003928:	1000                	addi	s0,sp,32
  if(ip == 0 || ip->ref < 1)
    8000392a:	c115                	beqz	a0,8000394e <ilock+0x30>
    8000392c:	84aa                	mv	s1,a0
    8000392e:	451c                	lw	a5,8(a0)
    80003930:	00f05f63          	blez	a5,8000394e <ilock+0x30>
  acquiresleep(&ip->lock);
    80003934:	0541                	addi	a0,a0,16
    80003936:	00001097          	auipc	ra,0x1
    8000393a:	ca8080e7          	jalr	-856(ra) # 800045de <acquiresleep>
  if(ip->valid == 0){
    8000393e:	40bc                	lw	a5,64(s1)
    80003940:	cf99                	beqz	a5,8000395e <ilock+0x40>
}
    80003942:	60e2                	ld	ra,24(sp)
    80003944:	6442                	ld	s0,16(sp)
    80003946:	64a2                	ld	s1,8(sp)
    80003948:	6902                	ld	s2,0(sp)
    8000394a:	6105                	addi	sp,sp,32
    8000394c:	8082                	ret
    panic("ilock");
    8000394e:	00005517          	auipc	a0,0x5
    80003952:	cfa50513          	addi	a0,a0,-774 # 80008648 <syscalls+0x198>
    80003956:	ffffd097          	auipc	ra,0xffffd
    8000395a:	bea080e7          	jalr	-1046(ra) # 80000540 <panic>
    bp = bread(ip->dev, IBLOCK(ip->inum, sb));
    8000395e:	40dc                	lw	a5,4(s1)
    80003960:	0047d79b          	srliw	a5,a5,0x4
    80003964:	0001b597          	auipc	a1,0x1b
    80003968:	78c5a583          	lw	a1,1932(a1) # 8001f0f0 <sb+0x18>
    8000396c:	9dbd                	addw	a1,a1,a5
    8000396e:	4088                	lw	a0,0(s1)
    80003970:	fffff097          	auipc	ra,0xfffff
    80003974:	796080e7          	jalr	1942(ra) # 80003106 <bread>
    80003978:	892a                	mv	s2,a0
    dip = (struct dinode*)bp->data + ip->inum%IPB;
    8000397a:	05850593          	addi	a1,a0,88
    8000397e:	40dc                	lw	a5,4(s1)
    80003980:	8bbd                	andi	a5,a5,15
    80003982:	079a                	slli	a5,a5,0x6
    80003984:	95be                	add	a1,a1,a5
    ip->type = dip->type;
    80003986:	00059783          	lh	a5,0(a1)
    8000398a:	04f49223          	sh	a5,68(s1)
    ip->major = dip->major;
    8000398e:	00259783          	lh	a5,2(a1)
    80003992:	04f49323          	sh	a5,70(s1)
    ip->minor = dip->minor;
    80003996:	00459783          	lh	a5,4(a1)
    8000399a:	04f49423          	sh	a5,72(s1)
    ip->nlink = dip->nlink;
    8000399e:	00659783          	lh	a5,6(a1)
    800039a2:	04f49523          	sh	a5,74(s1)
    ip->size = dip->size;
    800039a6:	459c                	lw	a5,8(a1)
    800039a8:	c4fc                	sw	a5,76(s1)
    memmove(ip->addrs, dip->addrs, sizeof(ip->addrs));
    800039aa:	03400613          	li	a2,52
    800039ae:	05b1                	addi	a1,a1,12
    800039b0:	05048513          	addi	a0,s1,80
    800039b4:	ffffd097          	auipc	ra,0xffffd
    800039b8:	37a080e7          	jalr	890(ra) # 80000d2e <memmove>
    brelse(bp);
    800039bc:	854a                	mv	a0,s2
    800039be:	00000097          	auipc	ra,0x0
    800039c2:	878080e7          	jalr	-1928(ra) # 80003236 <brelse>
    ip->valid = 1;
    800039c6:	4785                	li	a5,1
    800039c8:	c0bc                	sw	a5,64(s1)
    if(ip->type == 0)
    800039ca:	04449783          	lh	a5,68(s1)
    800039ce:	fbb5                	bnez	a5,80003942 <ilock+0x24>
      panic("ilock: no type");
    800039d0:	00005517          	auipc	a0,0x5
    800039d4:	c8050513          	addi	a0,a0,-896 # 80008650 <syscalls+0x1a0>
    800039d8:	ffffd097          	auipc	ra,0xffffd
    800039dc:	b68080e7          	jalr	-1176(ra) # 80000540 <panic>

00000000800039e0 <iunlock>:
{
    800039e0:	1101                	addi	sp,sp,-32
    800039e2:	ec06                	sd	ra,24(sp)
    800039e4:	e822                	sd	s0,16(sp)
    800039e6:	e426                	sd	s1,8(sp)
    800039e8:	e04a                	sd	s2,0(sp)
    800039ea:	1000                	addi	s0,sp,32
  if(ip == 0 || !holdingsleep(&ip->lock) || ip->ref < 1)
    800039ec:	c905                	beqz	a0,80003a1c <iunlock+0x3c>
    800039ee:	84aa                	mv	s1,a0
    800039f0:	01050913          	addi	s2,a0,16
    800039f4:	854a                	mv	a0,s2
    800039f6:	00001097          	auipc	ra,0x1
    800039fa:	c82080e7          	jalr	-894(ra) # 80004678 <holdingsleep>
    800039fe:	cd19                	beqz	a0,80003a1c <iunlock+0x3c>
    80003a00:	449c                	lw	a5,8(s1)
    80003a02:	00f05d63          	blez	a5,80003a1c <iunlock+0x3c>
  releasesleep(&ip->lock);
    80003a06:	854a                	mv	a0,s2
    80003a08:	00001097          	auipc	ra,0x1
    80003a0c:	c2c080e7          	jalr	-980(ra) # 80004634 <releasesleep>
}
    80003a10:	60e2                	ld	ra,24(sp)
    80003a12:	6442                	ld	s0,16(sp)
    80003a14:	64a2                	ld	s1,8(sp)
    80003a16:	6902                	ld	s2,0(sp)
    80003a18:	6105                	addi	sp,sp,32
    80003a1a:	8082                	ret
    panic("iunlock");
    80003a1c:	00005517          	auipc	a0,0x5
    80003a20:	c4450513          	addi	a0,a0,-956 # 80008660 <syscalls+0x1b0>
    80003a24:	ffffd097          	auipc	ra,0xffffd
    80003a28:	b1c080e7          	jalr	-1252(ra) # 80000540 <panic>

0000000080003a2c <itrunc>:

// Truncate inode (discard contents).
// Caller must hold ip->lock.
void
itrunc(struct inode *ip)
{
    80003a2c:	7179                	addi	sp,sp,-48
    80003a2e:	f406                	sd	ra,40(sp)
    80003a30:	f022                	sd	s0,32(sp)
    80003a32:	ec26                	sd	s1,24(sp)
    80003a34:	e84a                	sd	s2,16(sp)
    80003a36:	e44e                	sd	s3,8(sp)
    80003a38:	e052                	sd	s4,0(sp)
    80003a3a:	1800                	addi	s0,sp,48
    80003a3c:	89aa                	mv	s3,a0
  int i, j;
  struct buf *bp;
  uint *a;

  for(i = 0; i < NDIRECT; i++){
    80003a3e:	05050493          	addi	s1,a0,80
    80003a42:	08050913          	addi	s2,a0,128
    80003a46:	a021                	j	80003a4e <itrunc+0x22>
    80003a48:	0491                	addi	s1,s1,4
    80003a4a:	01248d63          	beq	s1,s2,80003a64 <itrunc+0x38>
    if(ip->addrs[i]){
    80003a4e:	408c                	lw	a1,0(s1)
    80003a50:	dde5                	beqz	a1,80003a48 <itrunc+0x1c>
      bfree(ip->dev, ip->addrs[i]);
    80003a52:	0009a503          	lw	a0,0(s3)
    80003a56:	00000097          	auipc	ra,0x0
    80003a5a:	8f6080e7          	jalr	-1802(ra) # 8000334c <bfree>
      ip->addrs[i] = 0;
    80003a5e:	0004a023          	sw	zero,0(s1)
    80003a62:	b7dd                	j	80003a48 <itrunc+0x1c>
    }
  }

  if(ip->addrs[NDIRECT]){
    80003a64:	0809a583          	lw	a1,128(s3)
    80003a68:	e185                	bnez	a1,80003a88 <itrunc+0x5c>
    brelse(bp);
    bfree(ip->dev, ip->addrs[NDIRECT]);
    ip->addrs[NDIRECT] = 0;
  }

  ip->size = 0;
    80003a6a:	0409a623          	sw	zero,76(s3)
  iupdate(ip);
    80003a6e:	854e                	mv	a0,s3
    80003a70:	00000097          	auipc	ra,0x0
    80003a74:	de2080e7          	jalr	-542(ra) # 80003852 <iupdate>
}
    80003a78:	70a2                	ld	ra,40(sp)
    80003a7a:	7402                	ld	s0,32(sp)
    80003a7c:	64e2                	ld	s1,24(sp)
    80003a7e:	6942                	ld	s2,16(sp)
    80003a80:	69a2                	ld	s3,8(sp)
    80003a82:	6a02                	ld	s4,0(sp)
    80003a84:	6145                	addi	sp,sp,48
    80003a86:	8082                	ret
    bp = bread(ip->dev, ip->addrs[NDIRECT]);
    80003a88:	0009a503          	lw	a0,0(s3)
    80003a8c:	fffff097          	auipc	ra,0xfffff
    80003a90:	67a080e7          	jalr	1658(ra) # 80003106 <bread>
    80003a94:	8a2a                	mv	s4,a0
    for(j = 0; j < NINDIRECT; j++){
    80003a96:	05850493          	addi	s1,a0,88
    80003a9a:	45850913          	addi	s2,a0,1112
    80003a9e:	a021                	j	80003aa6 <itrunc+0x7a>
    80003aa0:	0491                	addi	s1,s1,4
    80003aa2:	01248b63          	beq	s1,s2,80003ab8 <itrunc+0x8c>
      if(a[j])
    80003aa6:	408c                	lw	a1,0(s1)
    80003aa8:	dde5                	beqz	a1,80003aa0 <itrunc+0x74>
        bfree(ip->dev, a[j]);
    80003aaa:	0009a503          	lw	a0,0(s3)
    80003aae:	00000097          	auipc	ra,0x0
    80003ab2:	89e080e7          	jalr	-1890(ra) # 8000334c <bfree>
    80003ab6:	b7ed                	j	80003aa0 <itrunc+0x74>
    brelse(bp);
    80003ab8:	8552                	mv	a0,s4
    80003aba:	fffff097          	auipc	ra,0xfffff
    80003abe:	77c080e7          	jalr	1916(ra) # 80003236 <brelse>
    bfree(ip->dev, ip->addrs[NDIRECT]);
    80003ac2:	0809a583          	lw	a1,128(s3)
    80003ac6:	0009a503          	lw	a0,0(s3)
    80003aca:	00000097          	auipc	ra,0x0
    80003ace:	882080e7          	jalr	-1918(ra) # 8000334c <bfree>
    ip->addrs[NDIRECT] = 0;
    80003ad2:	0809a023          	sw	zero,128(s3)
    80003ad6:	bf51                	j	80003a6a <itrunc+0x3e>

0000000080003ad8 <iput>:
{
    80003ad8:	1101                	addi	sp,sp,-32
    80003ada:	ec06                	sd	ra,24(sp)
    80003adc:	e822                	sd	s0,16(sp)
    80003ade:	e426                	sd	s1,8(sp)
    80003ae0:	e04a                	sd	s2,0(sp)
    80003ae2:	1000                	addi	s0,sp,32
    80003ae4:	84aa                	mv	s1,a0
  acquire(&itable.lock);
    80003ae6:	0001b517          	auipc	a0,0x1b
    80003aea:	61250513          	addi	a0,a0,1554 # 8001f0f8 <itable>
    80003aee:	ffffd097          	auipc	ra,0xffffd
    80003af2:	0e8080e7          	jalr	232(ra) # 80000bd6 <acquire>
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003af6:	4498                	lw	a4,8(s1)
    80003af8:	4785                	li	a5,1
    80003afa:	02f70363          	beq	a4,a5,80003b20 <iput+0x48>
  ip->ref--;
    80003afe:	449c                	lw	a5,8(s1)
    80003b00:	37fd                	addiw	a5,a5,-1
    80003b02:	c49c                	sw	a5,8(s1)
  release(&itable.lock);
    80003b04:	0001b517          	auipc	a0,0x1b
    80003b08:	5f450513          	addi	a0,a0,1524 # 8001f0f8 <itable>
    80003b0c:	ffffd097          	auipc	ra,0xffffd
    80003b10:	17e080e7          	jalr	382(ra) # 80000c8a <release>
}
    80003b14:	60e2                	ld	ra,24(sp)
    80003b16:	6442                	ld	s0,16(sp)
    80003b18:	64a2                	ld	s1,8(sp)
    80003b1a:	6902                	ld	s2,0(sp)
    80003b1c:	6105                	addi	sp,sp,32
    80003b1e:	8082                	ret
  if(ip->ref == 1 && ip->valid && ip->nlink == 0){
    80003b20:	40bc                	lw	a5,64(s1)
    80003b22:	dff1                	beqz	a5,80003afe <iput+0x26>
    80003b24:	04a49783          	lh	a5,74(s1)
    80003b28:	fbf9                	bnez	a5,80003afe <iput+0x26>
    acquiresleep(&ip->lock);
    80003b2a:	01048913          	addi	s2,s1,16
    80003b2e:	854a                	mv	a0,s2
    80003b30:	00001097          	auipc	ra,0x1
    80003b34:	aae080e7          	jalr	-1362(ra) # 800045de <acquiresleep>
    release(&itable.lock);
    80003b38:	0001b517          	auipc	a0,0x1b
    80003b3c:	5c050513          	addi	a0,a0,1472 # 8001f0f8 <itable>
    80003b40:	ffffd097          	auipc	ra,0xffffd
    80003b44:	14a080e7          	jalr	330(ra) # 80000c8a <release>
    itrunc(ip);
    80003b48:	8526                	mv	a0,s1
    80003b4a:	00000097          	auipc	ra,0x0
    80003b4e:	ee2080e7          	jalr	-286(ra) # 80003a2c <itrunc>
    ip->type = 0;
    80003b52:	04049223          	sh	zero,68(s1)
    iupdate(ip);
    80003b56:	8526                	mv	a0,s1
    80003b58:	00000097          	auipc	ra,0x0
    80003b5c:	cfa080e7          	jalr	-774(ra) # 80003852 <iupdate>
    ip->valid = 0;
    80003b60:	0404a023          	sw	zero,64(s1)
    releasesleep(&ip->lock);
    80003b64:	854a                	mv	a0,s2
    80003b66:	00001097          	auipc	ra,0x1
    80003b6a:	ace080e7          	jalr	-1330(ra) # 80004634 <releasesleep>
    acquire(&itable.lock);
    80003b6e:	0001b517          	auipc	a0,0x1b
    80003b72:	58a50513          	addi	a0,a0,1418 # 8001f0f8 <itable>
    80003b76:	ffffd097          	auipc	ra,0xffffd
    80003b7a:	060080e7          	jalr	96(ra) # 80000bd6 <acquire>
    80003b7e:	b741                	j	80003afe <iput+0x26>

0000000080003b80 <iunlockput>:
{
    80003b80:	1101                	addi	sp,sp,-32
    80003b82:	ec06                	sd	ra,24(sp)
    80003b84:	e822                	sd	s0,16(sp)
    80003b86:	e426                	sd	s1,8(sp)
    80003b88:	1000                	addi	s0,sp,32
    80003b8a:	84aa                	mv	s1,a0
  iunlock(ip);
    80003b8c:	00000097          	auipc	ra,0x0
    80003b90:	e54080e7          	jalr	-428(ra) # 800039e0 <iunlock>
  iput(ip);
    80003b94:	8526                	mv	a0,s1
    80003b96:	00000097          	auipc	ra,0x0
    80003b9a:	f42080e7          	jalr	-190(ra) # 80003ad8 <iput>
}
    80003b9e:	60e2                	ld	ra,24(sp)
    80003ba0:	6442                	ld	s0,16(sp)
    80003ba2:	64a2                	ld	s1,8(sp)
    80003ba4:	6105                	addi	sp,sp,32
    80003ba6:	8082                	ret

0000000080003ba8 <stati>:

// Copy stat information from inode.
// Caller must hold ip->lock.
void
stati(struct inode *ip, struct stat *st)
{
    80003ba8:	1141                	addi	sp,sp,-16
    80003baa:	e422                	sd	s0,8(sp)
    80003bac:	0800                	addi	s0,sp,16
  st->dev = ip->dev;
    80003bae:	411c                	lw	a5,0(a0)
    80003bb0:	c19c                	sw	a5,0(a1)
  st->ino = ip->inum;
    80003bb2:	415c                	lw	a5,4(a0)
    80003bb4:	c1dc                	sw	a5,4(a1)
  st->type = ip->type;
    80003bb6:	04451783          	lh	a5,68(a0)
    80003bba:	00f59423          	sh	a5,8(a1)
  st->nlink = ip->nlink;
    80003bbe:	04a51783          	lh	a5,74(a0)
    80003bc2:	00f59523          	sh	a5,10(a1)
  st->size = ip->size;
    80003bc6:	04c56783          	lwu	a5,76(a0)
    80003bca:	e99c                	sd	a5,16(a1)
}
    80003bcc:	6422                	ld	s0,8(sp)
    80003bce:	0141                	addi	sp,sp,16
    80003bd0:	8082                	ret

0000000080003bd2 <readi>:
readi(struct inode *ip, int user_dst, uint64 dst, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003bd2:	457c                	lw	a5,76(a0)
    80003bd4:	0ed7e963          	bltu	a5,a3,80003cc6 <readi+0xf4>
{
    80003bd8:	7159                	addi	sp,sp,-112
    80003bda:	f486                	sd	ra,104(sp)
    80003bdc:	f0a2                	sd	s0,96(sp)
    80003bde:	eca6                	sd	s1,88(sp)
    80003be0:	e8ca                	sd	s2,80(sp)
    80003be2:	e4ce                	sd	s3,72(sp)
    80003be4:	e0d2                	sd	s4,64(sp)
    80003be6:	fc56                	sd	s5,56(sp)
    80003be8:	f85a                	sd	s6,48(sp)
    80003bea:	f45e                	sd	s7,40(sp)
    80003bec:	f062                	sd	s8,32(sp)
    80003bee:	ec66                	sd	s9,24(sp)
    80003bf0:	e86a                	sd	s10,16(sp)
    80003bf2:	e46e                	sd	s11,8(sp)
    80003bf4:	1880                	addi	s0,sp,112
    80003bf6:	8b2a                	mv	s6,a0
    80003bf8:	8bae                	mv	s7,a1
    80003bfa:	8a32                	mv	s4,a2
    80003bfc:	84b6                	mv	s1,a3
    80003bfe:	8aba                	mv	s5,a4
  if(off > ip->size || off + n < off)
    80003c00:	9f35                	addw	a4,a4,a3
    return 0;
    80003c02:	4501                	li	a0,0
  if(off > ip->size || off + n < off)
    80003c04:	0ad76063          	bltu	a4,a3,80003ca4 <readi+0xd2>
  if(off + n > ip->size)
    80003c08:	00e7f463          	bgeu	a5,a4,80003c10 <readi+0x3e>
    n = ip->size - off;
    80003c0c:	40d78abb          	subw	s5,a5,a3

  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c10:	0a0a8963          	beqz	s5,80003cc2 <readi+0xf0>
    80003c14:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c16:	40000c93          	li	s9,1024
    if(either_copyout(user_dst, dst, bp->data + (off % BSIZE), m) == -1) {
    80003c1a:	5c7d                	li	s8,-1
    80003c1c:	a82d                	j	80003c56 <readi+0x84>
    80003c1e:	020d1d93          	slli	s11,s10,0x20
    80003c22:	020ddd93          	srli	s11,s11,0x20
    80003c26:	05890613          	addi	a2,s2,88
    80003c2a:	86ee                	mv	a3,s11
    80003c2c:	963a                	add	a2,a2,a4
    80003c2e:	85d2                	mv	a1,s4
    80003c30:	855e                	mv	a0,s7
    80003c32:	fffff097          	auipc	ra,0xfffff
    80003c36:	978080e7          	jalr	-1672(ra) # 800025aa <either_copyout>
    80003c3a:	05850d63          	beq	a0,s8,80003c94 <readi+0xc2>
      brelse(bp);
      tot = -1;
      break;
    }
    brelse(bp);
    80003c3e:	854a                	mv	a0,s2
    80003c40:	fffff097          	auipc	ra,0xfffff
    80003c44:	5f6080e7          	jalr	1526(ra) # 80003236 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003c48:	013d09bb          	addw	s3,s10,s3
    80003c4c:	009d04bb          	addw	s1,s10,s1
    80003c50:	9a6e                	add	s4,s4,s11
    80003c52:	0559f763          	bgeu	s3,s5,80003ca0 <readi+0xce>
    uint addr = bmap(ip, off/BSIZE);
    80003c56:	00a4d59b          	srliw	a1,s1,0xa
    80003c5a:	855a                	mv	a0,s6
    80003c5c:	00000097          	auipc	ra,0x0
    80003c60:	89e080e7          	jalr	-1890(ra) # 800034fa <bmap>
    80003c64:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003c68:	cd85                	beqz	a1,80003ca0 <readi+0xce>
    bp = bread(ip->dev, addr);
    80003c6a:	000b2503          	lw	a0,0(s6)
    80003c6e:	fffff097          	auipc	ra,0xfffff
    80003c72:	498080e7          	jalr	1176(ra) # 80003106 <bread>
    80003c76:	892a                	mv	s2,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003c78:	3ff4f713          	andi	a4,s1,1023
    80003c7c:	40ec87bb          	subw	a5,s9,a4
    80003c80:	413a86bb          	subw	a3,s5,s3
    80003c84:	8d3e                	mv	s10,a5
    80003c86:	2781                	sext.w	a5,a5
    80003c88:	0006861b          	sext.w	a2,a3
    80003c8c:	f8f679e3          	bgeu	a2,a5,80003c1e <readi+0x4c>
    80003c90:	8d36                	mv	s10,a3
    80003c92:	b771                	j	80003c1e <readi+0x4c>
      brelse(bp);
    80003c94:	854a                	mv	a0,s2
    80003c96:	fffff097          	auipc	ra,0xfffff
    80003c9a:	5a0080e7          	jalr	1440(ra) # 80003236 <brelse>
      tot = -1;
    80003c9e:	59fd                	li	s3,-1
  }
  return tot;
    80003ca0:	0009851b          	sext.w	a0,s3
}
    80003ca4:	70a6                	ld	ra,104(sp)
    80003ca6:	7406                	ld	s0,96(sp)
    80003ca8:	64e6                	ld	s1,88(sp)
    80003caa:	6946                	ld	s2,80(sp)
    80003cac:	69a6                	ld	s3,72(sp)
    80003cae:	6a06                	ld	s4,64(sp)
    80003cb0:	7ae2                	ld	s5,56(sp)
    80003cb2:	7b42                	ld	s6,48(sp)
    80003cb4:	7ba2                	ld	s7,40(sp)
    80003cb6:	7c02                	ld	s8,32(sp)
    80003cb8:	6ce2                	ld	s9,24(sp)
    80003cba:	6d42                	ld	s10,16(sp)
    80003cbc:	6da2                	ld	s11,8(sp)
    80003cbe:	6165                	addi	sp,sp,112
    80003cc0:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, dst+=m){
    80003cc2:	89d6                	mv	s3,s5
    80003cc4:	bff1                	j	80003ca0 <readi+0xce>
    return 0;
    80003cc6:	4501                	li	a0,0
}
    80003cc8:	8082                	ret

0000000080003cca <writei>:
writei(struct inode *ip, int user_src, uint64 src, uint off, uint n)
{
  uint tot, m;
  struct buf *bp;

  if(off > ip->size || off + n < off)
    80003cca:	457c                	lw	a5,76(a0)
    80003ccc:	10d7e863          	bltu	a5,a3,80003ddc <writei+0x112>
{
    80003cd0:	7159                	addi	sp,sp,-112
    80003cd2:	f486                	sd	ra,104(sp)
    80003cd4:	f0a2                	sd	s0,96(sp)
    80003cd6:	eca6                	sd	s1,88(sp)
    80003cd8:	e8ca                	sd	s2,80(sp)
    80003cda:	e4ce                	sd	s3,72(sp)
    80003cdc:	e0d2                	sd	s4,64(sp)
    80003cde:	fc56                	sd	s5,56(sp)
    80003ce0:	f85a                	sd	s6,48(sp)
    80003ce2:	f45e                	sd	s7,40(sp)
    80003ce4:	f062                	sd	s8,32(sp)
    80003ce6:	ec66                	sd	s9,24(sp)
    80003ce8:	e86a                	sd	s10,16(sp)
    80003cea:	e46e                	sd	s11,8(sp)
    80003cec:	1880                	addi	s0,sp,112
    80003cee:	8aaa                	mv	s5,a0
    80003cf0:	8bae                	mv	s7,a1
    80003cf2:	8a32                	mv	s4,a2
    80003cf4:	8936                	mv	s2,a3
    80003cf6:	8b3a                	mv	s6,a4
  if(off > ip->size || off + n < off)
    80003cf8:	00e687bb          	addw	a5,a3,a4
    80003cfc:	0ed7e263          	bltu	a5,a3,80003de0 <writei+0x116>
    return -1;
  if(off + n > MAXFILE*BSIZE)
    80003d00:	00043737          	lui	a4,0x43
    80003d04:	0ef76063          	bltu	a4,a5,80003de4 <writei+0x11a>
    return -1;

  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d08:	0c0b0863          	beqz	s6,80003dd8 <writei+0x10e>
    80003d0c:	4981                	li	s3,0
    uint addr = bmap(ip, off/BSIZE);
    if(addr == 0)
      break;
    bp = bread(ip->dev, addr);
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d0e:	40000c93          	li	s9,1024
    if(either_copyin(bp->data + (off % BSIZE), user_src, src, m) == -1) {
    80003d12:	5c7d                	li	s8,-1
    80003d14:	a091                	j	80003d58 <writei+0x8e>
    80003d16:	020d1d93          	slli	s11,s10,0x20
    80003d1a:	020ddd93          	srli	s11,s11,0x20
    80003d1e:	05848513          	addi	a0,s1,88
    80003d22:	86ee                	mv	a3,s11
    80003d24:	8652                	mv	a2,s4
    80003d26:	85de                	mv	a1,s7
    80003d28:	953a                	add	a0,a0,a4
    80003d2a:	fffff097          	auipc	ra,0xfffff
    80003d2e:	8d6080e7          	jalr	-1834(ra) # 80002600 <either_copyin>
    80003d32:	07850263          	beq	a0,s8,80003d96 <writei+0xcc>
      brelse(bp);
      break;
    }
    log_write(bp);
    80003d36:	8526                	mv	a0,s1
    80003d38:	00000097          	auipc	ra,0x0
    80003d3c:	788080e7          	jalr	1928(ra) # 800044c0 <log_write>
    brelse(bp);
    80003d40:	8526                	mv	a0,s1
    80003d42:	fffff097          	auipc	ra,0xfffff
    80003d46:	4f4080e7          	jalr	1268(ra) # 80003236 <brelse>
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003d4a:	013d09bb          	addw	s3,s10,s3
    80003d4e:	012d093b          	addw	s2,s10,s2
    80003d52:	9a6e                	add	s4,s4,s11
    80003d54:	0569f663          	bgeu	s3,s6,80003da0 <writei+0xd6>
    uint addr = bmap(ip, off/BSIZE);
    80003d58:	00a9559b          	srliw	a1,s2,0xa
    80003d5c:	8556                	mv	a0,s5
    80003d5e:	fffff097          	auipc	ra,0xfffff
    80003d62:	79c080e7          	jalr	1948(ra) # 800034fa <bmap>
    80003d66:	0005059b          	sext.w	a1,a0
    if(addr == 0)
    80003d6a:	c99d                	beqz	a1,80003da0 <writei+0xd6>
    bp = bread(ip->dev, addr);
    80003d6c:	000aa503          	lw	a0,0(s5)
    80003d70:	fffff097          	auipc	ra,0xfffff
    80003d74:	396080e7          	jalr	918(ra) # 80003106 <bread>
    80003d78:	84aa                	mv	s1,a0
    m = min(n - tot, BSIZE - off%BSIZE);
    80003d7a:	3ff97713          	andi	a4,s2,1023
    80003d7e:	40ec87bb          	subw	a5,s9,a4
    80003d82:	413b06bb          	subw	a3,s6,s3
    80003d86:	8d3e                	mv	s10,a5
    80003d88:	2781                	sext.w	a5,a5
    80003d8a:	0006861b          	sext.w	a2,a3
    80003d8e:	f8f674e3          	bgeu	a2,a5,80003d16 <writei+0x4c>
    80003d92:	8d36                	mv	s10,a3
    80003d94:	b749                	j	80003d16 <writei+0x4c>
      brelse(bp);
    80003d96:	8526                	mv	a0,s1
    80003d98:	fffff097          	auipc	ra,0xfffff
    80003d9c:	49e080e7          	jalr	1182(ra) # 80003236 <brelse>
  }

  if(off > ip->size)
    80003da0:	04caa783          	lw	a5,76(s5)
    80003da4:	0127f463          	bgeu	a5,s2,80003dac <writei+0xe2>
    ip->size = off;
    80003da8:	052aa623          	sw	s2,76(s5)

  // write the i-node back to disk even if the size didn't change
  // because the loop above might have called bmap() and added a new
  // block to ip->addrs[].
  iupdate(ip);
    80003dac:	8556                	mv	a0,s5
    80003dae:	00000097          	auipc	ra,0x0
    80003db2:	aa4080e7          	jalr	-1372(ra) # 80003852 <iupdate>

  return tot;
    80003db6:	0009851b          	sext.w	a0,s3
}
    80003dba:	70a6                	ld	ra,104(sp)
    80003dbc:	7406                	ld	s0,96(sp)
    80003dbe:	64e6                	ld	s1,88(sp)
    80003dc0:	6946                	ld	s2,80(sp)
    80003dc2:	69a6                	ld	s3,72(sp)
    80003dc4:	6a06                	ld	s4,64(sp)
    80003dc6:	7ae2                	ld	s5,56(sp)
    80003dc8:	7b42                	ld	s6,48(sp)
    80003dca:	7ba2                	ld	s7,40(sp)
    80003dcc:	7c02                	ld	s8,32(sp)
    80003dce:	6ce2                	ld	s9,24(sp)
    80003dd0:	6d42                	ld	s10,16(sp)
    80003dd2:	6da2                	ld	s11,8(sp)
    80003dd4:	6165                	addi	sp,sp,112
    80003dd6:	8082                	ret
  for(tot=0; tot<n; tot+=m, off+=m, src+=m){
    80003dd8:	89da                	mv	s3,s6
    80003dda:	bfc9                	j	80003dac <writei+0xe2>
    return -1;
    80003ddc:	557d                	li	a0,-1
}
    80003dde:	8082                	ret
    return -1;
    80003de0:	557d                	li	a0,-1
    80003de2:	bfe1                	j	80003dba <writei+0xf0>
    return -1;
    80003de4:	557d                	li	a0,-1
    80003de6:	bfd1                	j	80003dba <writei+0xf0>

0000000080003de8 <namecmp>:

// Directories

int
namecmp(const char *s, const char *t)
{
    80003de8:	1141                	addi	sp,sp,-16
    80003dea:	e406                	sd	ra,8(sp)
    80003dec:	e022                	sd	s0,0(sp)
    80003dee:	0800                	addi	s0,sp,16
  return strncmp(s, t, DIRSIZ);
    80003df0:	4639                	li	a2,14
    80003df2:	ffffd097          	auipc	ra,0xffffd
    80003df6:	fb0080e7          	jalr	-80(ra) # 80000da2 <strncmp>
}
    80003dfa:	60a2                	ld	ra,8(sp)
    80003dfc:	6402                	ld	s0,0(sp)
    80003dfe:	0141                	addi	sp,sp,16
    80003e00:	8082                	ret

0000000080003e02 <dirlookup>:

// Look for a directory entry in a directory.
// If found, set *poff to byte offset of entry.
struct inode*
dirlookup(struct inode *dp, char *name, uint *poff)
{
    80003e02:	7139                	addi	sp,sp,-64
    80003e04:	fc06                	sd	ra,56(sp)
    80003e06:	f822                	sd	s0,48(sp)
    80003e08:	f426                	sd	s1,40(sp)
    80003e0a:	f04a                	sd	s2,32(sp)
    80003e0c:	ec4e                	sd	s3,24(sp)
    80003e0e:	e852                	sd	s4,16(sp)
    80003e10:	0080                	addi	s0,sp,64
  uint off, inum;
  struct dirent de;

  if(dp->type != T_DIR)
    80003e12:	04451703          	lh	a4,68(a0)
    80003e16:	4785                	li	a5,1
    80003e18:	00f71a63          	bne	a4,a5,80003e2c <dirlookup+0x2a>
    80003e1c:	892a                	mv	s2,a0
    80003e1e:	89ae                	mv	s3,a1
    80003e20:	8a32                	mv	s4,a2
    panic("dirlookup not DIR");

  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e22:	457c                	lw	a5,76(a0)
    80003e24:	4481                	li	s1,0
      inum = de.inum;
      return iget(dp->dev, inum);
    }
  }

  return 0;
    80003e26:	4501                	li	a0,0
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e28:	e79d                	bnez	a5,80003e56 <dirlookup+0x54>
    80003e2a:	a8a5                	j	80003ea2 <dirlookup+0xa0>
    panic("dirlookup not DIR");
    80003e2c:	00005517          	auipc	a0,0x5
    80003e30:	83c50513          	addi	a0,a0,-1988 # 80008668 <syscalls+0x1b8>
    80003e34:	ffffc097          	auipc	ra,0xffffc
    80003e38:	70c080e7          	jalr	1804(ra) # 80000540 <panic>
      panic("dirlookup read");
    80003e3c:	00005517          	auipc	a0,0x5
    80003e40:	84450513          	addi	a0,a0,-1980 # 80008680 <syscalls+0x1d0>
    80003e44:	ffffc097          	auipc	ra,0xffffc
    80003e48:	6fc080e7          	jalr	1788(ra) # 80000540 <panic>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80003e4c:	24c1                	addiw	s1,s1,16
    80003e4e:	04c92783          	lw	a5,76(s2)
    80003e52:	04f4f763          	bgeu	s1,a5,80003ea0 <dirlookup+0x9e>
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80003e56:	4741                	li	a4,16
    80003e58:	86a6                	mv	a3,s1
    80003e5a:	fc040613          	addi	a2,s0,-64
    80003e5e:	4581                	li	a1,0
    80003e60:	854a                	mv	a0,s2
    80003e62:	00000097          	auipc	ra,0x0
    80003e66:	d70080e7          	jalr	-656(ra) # 80003bd2 <readi>
    80003e6a:	47c1                	li	a5,16
    80003e6c:	fcf518e3          	bne	a0,a5,80003e3c <dirlookup+0x3a>
    if(de.inum == 0)
    80003e70:	fc045783          	lhu	a5,-64(s0)
    80003e74:	dfe1                	beqz	a5,80003e4c <dirlookup+0x4a>
    if(namecmp(name, de.name) == 0){
    80003e76:	fc240593          	addi	a1,s0,-62
    80003e7a:	854e                	mv	a0,s3
    80003e7c:	00000097          	auipc	ra,0x0
    80003e80:	f6c080e7          	jalr	-148(ra) # 80003de8 <namecmp>
    80003e84:	f561                	bnez	a0,80003e4c <dirlookup+0x4a>
      if(poff)
    80003e86:	000a0463          	beqz	s4,80003e8e <dirlookup+0x8c>
        *poff = off;
    80003e8a:	009a2023          	sw	s1,0(s4)
      return iget(dp->dev, inum);
    80003e8e:	fc045583          	lhu	a1,-64(s0)
    80003e92:	00092503          	lw	a0,0(s2)
    80003e96:	fffff097          	auipc	ra,0xfffff
    80003e9a:	74e080e7          	jalr	1870(ra) # 800035e4 <iget>
    80003e9e:	a011                	j	80003ea2 <dirlookup+0xa0>
  return 0;
    80003ea0:	4501                	li	a0,0
}
    80003ea2:	70e2                	ld	ra,56(sp)
    80003ea4:	7442                	ld	s0,48(sp)
    80003ea6:	74a2                	ld	s1,40(sp)
    80003ea8:	7902                	ld	s2,32(sp)
    80003eaa:	69e2                	ld	s3,24(sp)
    80003eac:	6a42                	ld	s4,16(sp)
    80003eae:	6121                	addi	sp,sp,64
    80003eb0:	8082                	ret

0000000080003eb2 <namex>:
// If parent != 0, return the inode for the parent and copy the final
// path element into name, which must have room for DIRSIZ bytes.
// Must be called inside a transaction since it calls iput().
static struct inode*
namex(char *path, int nameiparent, char *name)
{
    80003eb2:	711d                	addi	sp,sp,-96
    80003eb4:	ec86                	sd	ra,88(sp)
    80003eb6:	e8a2                	sd	s0,80(sp)
    80003eb8:	e4a6                	sd	s1,72(sp)
    80003eba:	e0ca                	sd	s2,64(sp)
    80003ebc:	fc4e                	sd	s3,56(sp)
    80003ebe:	f852                	sd	s4,48(sp)
    80003ec0:	f456                	sd	s5,40(sp)
    80003ec2:	f05a                	sd	s6,32(sp)
    80003ec4:	ec5e                	sd	s7,24(sp)
    80003ec6:	e862                	sd	s8,16(sp)
    80003ec8:	e466                	sd	s9,8(sp)
    80003eca:	e06a                	sd	s10,0(sp)
    80003ecc:	1080                	addi	s0,sp,96
    80003ece:	84aa                	mv	s1,a0
    80003ed0:	8b2e                	mv	s6,a1
    80003ed2:	8ab2                	mv	s5,a2
  struct inode *ip, *next;

  if(*path == '/')
    80003ed4:	00054703          	lbu	a4,0(a0)
    80003ed8:	02f00793          	li	a5,47
    80003edc:	02f70363          	beq	a4,a5,80003f02 <namex+0x50>
    ip = iget(ROOTDEV, ROOTINO);
  else
    ip = idup(myproc()->cwd);
    80003ee0:	ffffe097          	auipc	ra,0xffffe
    80003ee4:	c1a080e7          	jalr	-998(ra) # 80001afa <myproc>
    80003ee8:	15053503          	ld	a0,336(a0)
    80003eec:	00000097          	auipc	ra,0x0
    80003ef0:	9f4080e7          	jalr	-1548(ra) # 800038e0 <idup>
    80003ef4:	8a2a                	mv	s4,a0
  while(*path == '/')
    80003ef6:	02f00913          	li	s2,47
  if(len >= DIRSIZ)
    80003efa:	4cb5                	li	s9,13
  len = path - s;
    80003efc:	4b81                	li	s7,0

  while((path = skipelem(path, name)) != 0){
    ilock(ip);
    if(ip->type != T_DIR){
    80003efe:	4c05                	li	s8,1
    80003f00:	a87d                	j	80003fbe <namex+0x10c>
    ip = iget(ROOTDEV, ROOTINO);
    80003f02:	4585                	li	a1,1
    80003f04:	4505                	li	a0,1
    80003f06:	fffff097          	auipc	ra,0xfffff
    80003f0a:	6de080e7          	jalr	1758(ra) # 800035e4 <iget>
    80003f0e:	8a2a                	mv	s4,a0
    80003f10:	b7dd                	j	80003ef6 <namex+0x44>
      iunlockput(ip);
    80003f12:	8552                	mv	a0,s4
    80003f14:	00000097          	auipc	ra,0x0
    80003f18:	c6c080e7          	jalr	-916(ra) # 80003b80 <iunlockput>
      return 0;
    80003f1c:	4a01                	li	s4,0
  if(nameiparent){
    iput(ip);
    return 0;
  }
  return ip;
}
    80003f1e:	8552                	mv	a0,s4
    80003f20:	60e6                	ld	ra,88(sp)
    80003f22:	6446                	ld	s0,80(sp)
    80003f24:	64a6                	ld	s1,72(sp)
    80003f26:	6906                	ld	s2,64(sp)
    80003f28:	79e2                	ld	s3,56(sp)
    80003f2a:	7a42                	ld	s4,48(sp)
    80003f2c:	7aa2                	ld	s5,40(sp)
    80003f2e:	7b02                	ld	s6,32(sp)
    80003f30:	6be2                	ld	s7,24(sp)
    80003f32:	6c42                	ld	s8,16(sp)
    80003f34:	6ca2                	ld	s9,8(sp)
    80003f36:	6d02                	ld	s10,0(sp)
    80003f38:	6125                	addi	sp,sp,96
    80003f3a:	8082                	ret
      iunlock(ip);
    80003f3c:	8552                	mv	a0,s4
    80003f3e:	00000097          	auipc	ra,0x0
    80003f42:	aa2080e7          	jalr	-1374(ra) # 800039e0 <iunlock>
      return ip;
    80003f46:	bfe1                	j	80003f1e <namex+0x6c>
      iunlockput(ip);
    80003f48:	8552                	mv	a0,s4
    80003f4a:	00000097          	auipc	ra,0x0
    80003f4e:	c36080e7          	jalr	-970(ra) # 80003b80 <iunlockput>
      return 0;
    80003f52:	8a4e                	mv	s4,s3
    80003f54:	b7e9                	j	80003f1e <namex+0x6c>
  len = path - s;
    80003f56:	40998633          	sub	a2,s3,s1
    80003f5a:	00060d1b          	sext.w	s10,a2
  if(len >= DIRSIZ)
    80003f5e:	09acd863          	bge	s9,s10,80003fee <namex+0x13c>
    memmove(name, s, DIRSIZ);
    80003f62:	4639                	li	a2,14
    80003f64:	85a6                	mv	a1,s1
    80003f66:	8556                	mv	a0,s5
    80003f68:	ffffd097          	auipc	ra,0xffffd
    80003f6c:	dc6080e7          	jalr	-570(ra) # 80000d2e <memmove>
    80003f70:	84ce                	mv	s1,s3
  while(*path == '/')
    80003f72:	0004c783          	lbu	a5,0(s1)
    80003f76:	01279763          	bne	a5,s2,80003f84 <namex+0xd2>
    path++;
    80003f7a:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003f7c:	0004c783          	lbu	a5,0(s1)
    80003f80:	ff278de3          	beq	a5,s2,80003f7a <namex+0xc8>
    ilock(ip);
    80003f84:	8552                	mv	a0,s4
    80003f86:	00000097          	auipc	ra,0x0
    80003f8a:	998080e7          	jalr	-1640(ra) # 8000391e <ilock>
    if(ip->type != T_DIR){
    80003f8e:	044a1783          	lh	a5,68(s4)
    80003f92:	f98790e3          	bne	a5,s8,80003f12 <namex+0x60>
    if(nameiparent && *path == '\0'){
    80003f96:	000b0563          	beqz	s6,80003fa0 <namex+0xee>
    80003f9a:	0004c783          	lbu	a5,0(s1)
    80003f9e:	dfd9                	beqz	a5,80003f3c <namex+0x8a>
    if((next = dirlookup(ip, name, 0)) == 0){
    80003fa0:	865e                	mv	a2,s7
    80003fa2:	85d6                	mv	a1,s5
    80003fa4:	8552                	mv	a0,s4
    80003fa6:	00000097          	auipc	ra,0x0
    80003faa:	e5c080e7          	jalr	-420(ra) # 80003e02 <dirlookup>
    80003fae:	89aa                	mv	s3,a0
    80003fb0:	dd41                	beqz	a0,80003f48 <namex+0x96>
    iunlockput(ip);
    80003fb2:	8552                	mv	a0,s4
    80003fb4:	00000097          	auipc	ra,0x0
    80003fb8:	bcc080e7          	jalr	-1076(ra) # 80003b80 <iunlockput>
    ip = next;
    80003fbc:	8a4e                	mv	s4,s3
  while(*path == '/')
    80003fbe:	0004c783          	lbu	a5,0(s1)
    80003fc2:	01279763          	bne	a5,s2,80003fd0 <namex+0x11e>
    path++;
    80003fc6:	0485                	addi	s1,s1,1
  while(*path == '/')
    80003fc8:	0004c783          	lbu	a5,0(s1)
    80003fcc:	ff278de3          	beq	a5,s2,80003fc6 <namex+0x114>
  if(*path == 0)
    80003fd0:	cb9d                	beqz	a5,80004006 <namex+0x154>
  while(*path != '/' && *path != 0)
    80003fd2:	0004c783          	lbu	a5,0(s1)
    80003fd6:	89a6                	mv	s3,s1
  len = path - s;
    80003fd8:	8d5e                	mv	s10,s7
    80003fda:	865e                	mv	a2,s7
  while(*path != '/' && *path != 0)
    80003fdc:	01278963          	beq	a5,s2,80003fee <namex+0x13c>
    80003fe0:	dbbd                	beqz	a5,80003f56 <namex+0xa4>
    path++;
    80003fe2:	0985                	addi	s3,s3,1
  while(*path != '/' && *path != 0)
    80003fe4:	0009c783          	lbu	a5,0(s3)
    80003fe8:	ff279ce3          	bne	a5,s2,80003fe0 <namex+0x12e>
    80003fec:	b7ad                	j	80003f56 <namex+0xa4>
    memmove(name, s, len);
    80003fee:	2601                	sext.w	a2,a2
    80003ff0:	85a6                	mv	a1,s1
    80003ff2:	8556                	mv	a0,s5
    80003ff4:	ffffd097          	auipc	ra,0xffffd
    80003ff8:	d3a080e7          	jalr	-710(ra) # 80000d2e <memmove>
    name[len] = 0;
    80003ffc:	9d56                	add	s10,s10,s5
    80003ffe:	000d0023          	sb	zero,0(s10)
    80004002:	84ce                	mv	s1,s3
    80004004:	b7bd                	j	80003f72 <namex+0xc0>
  if(nameiparent){
    80004006:	f00b0ce3          	beqz	s6,80003f1e <namex+0x6c>
    iput(ip);
    8000400a:	8552                	mv	a0,s4
    8000400c:	00000097          	auipc	ra,0x0
    80004010:	acc080e7          	jalr	-1332(ra) # 80003ad8 <iput>
    return 0;
    80004014:	4a01                	li	s4,0
    80004016:	b721                	j	80003f1e <namex+0x6c>

0000000080004018 <dirlink>:
{
    80004018:	7139                	addi	sp,sp,-64
    8000401a:	fc06                	sd	ra,56(sp)
    8000401c:	f822                	sd	s0,48(sp)
    8000401e:	f426                	sd	s1,40(sp)
    80004020:	f04a                	sd	s2,32(sp)
    80004022:	ec4e                	sd	s3,24(sp)
    80004024:	e852                	sd	s4,16(sp)
    80004026:	0080                	addi	s0,sp,64
    80004028:	892a                	mv	s2,a0
    8000402a:	8a2e                	mv	s4,a1
    8000402c:	89b2                	mv	s3,a2
  if((ip = dirlookup(dp, name, 0)) != 0){
    8000402e:	4601                	li	a2,0
    80004030:	00000097          	auipc	ra,0x0
    80004034:	dd2080e7          	jalr	-558(ra) # 80003e02 <dirlookup>
    80004038:	e93d                	bnez	a0,800040ae <dirlink+0x96>
  for(off = 0; off < dp->size; off += sizeof(de)){
    8000403a:	04c92483          	lw	s1,76(s2)
    8000403e:	c49d                	beqz	s1,8000406c <dirlink+0x54>
    80004040:	4481                	li	s1,0
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004042:	4741                	li	a4,16
    80004044:	86a6                	mv	a3,s1
    80004046:	fc040613          	addi	a2,s0,-64
    8000404a:	4581                	li	a1,0
    8000404c:	854a                	mv	a0,s2
    8000404e:	00000097          	auipc	ra,0x0
    80004052:	b84080e7          	jalr	-1148(ra) # 80003bd2 <readi>
    80004056:	47c1                	li	a5,16
    80004058:	06f51163          	bne	a0,a5,800040ba <dirlink+0xa2>
    if(de.inum == 0)
    8000405c:	fc045783          	lhu	a5,-64(s0)
    80004060:	c791                	beqz	a5,8000406c <dirlink+0x54>
  for(off = 0; off < dp->size; off += sizeof(de)){
    80004062:	24c1                	addiw	s1,s1,16
    80004064:	04c92783          	lw	a5,76(s2)
    80004068:	fcf4ede3          	bltu	s1,a5,80004042 <dirlink+0x2a>
  strncpy(de.name, name, DIRSIZ);
    8000406c:	4639                	li	a2,14
    8000406e:	85d2                	mv	a1,s4
    80004070:	fc240513          	addi	a0,s0,-62
    80004074:	ffffd097          	auipc	ra,0xffffd
    80004078:	d6a080e7          	jalr	-662(ra) # 80000dde <strncpy>
  de.inum = inum;
    8000407c:	fd341023          	sh	s3,-64(s0)
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80004080:	4741                	li	a4,16
    80004082:	86a6                	mv	a3,s1
    80004084:	fc040613          	addi	a2,s0,-64
    80004088:	4581                	li	a1,0
    8000408a:	854a                	mv	a0,s2
    8000408c:	00000097          	auipc	ra,0x0
    80004090:	c3e080e7          	jalr	-962(ra) # 80003cca <writei>
    80004094:	1541                	addi	a0,a0,-16
    80004096:	00a03533          	snez	a0,a0
    8000409a:	40a00533          	neg	a0,a0
}
    8000409e:	70e2                	ld	ra,56(sp)
    800040a0:	7442                	ld	s0,48(sp)
    800040a2:	74a2                	ld	s1,40(sp)
    800040a4:	7902                	ld	s2,32(sp)
    800040a6:	69e2                	ld	s3,24(sp)
    800040a8:	6a42                	ld	s4,16(sp)
    800040aa:	6121                	addi	sp,sp,64
    800040ac:	8082                	ret
    iput(ip);
    800040ae:	00000097          	auipc	ra,0x0
    800040b2:	a2a080e7          	jalr	-1494(ra) # 80003ad8 <iput>
    return -1;
    800040b6:	557d                	li	a0,-1
    800040b8:	b7dd                	j	8000409e <dirlink+0x86>
      panic("dirlink read");
    800040ba:	00004517          	auipc	a0,0x4
    800040be:	5d650513          	addi	a0,a0,1494 # 80008690 <syscalls+0x1e0>
    800040c2:	ffffc097          	auipc	ra,0xffffc
    800040c6:	47e080e7          	jalr	1150(ra) # 80000540 <panic>

00000000800040ca <namei>:

struct inode*
namei(char *path)
{
    800040ca:	1101                	addi	sp,sp,-32
    800040cc:	ec06                	sd	ra,24(sp)
    800040ce:	e822                	sd	s0,16(sp)
    800040d0:	1000                	addi	s0,sp,32
  char name[DIRSIZ];
  return namex(path, 0, name);
    800040d2:	fe040613          	addi	a2,s0,-32
    800040d6:	4581                	li	a1,0
    800040d8:	00000097          	auipc	ra,0x0
    800040dc:	dda080e7          	jalr	-550(ra) # 80003eb2 <namex>
}
    800040e0:	60e2                	ld	ra,24(sp)
    800040e2:	6442                	ld	s0,16(sp)
    800040e4:	6105                	addi	sp,sp,32
    800040e6:	8082                	ret

00000000800040e8 <nameiparent>:

struct inode*
nameiparent(char *path, char *name)
{
    800040e8:	1141                	addi	sp,sp,-16
    800040ea:	e406                	sd	ra,8(sp)
    800040ec:	e022                	sd	s0,0(sp)
    800040ee:	0800                	addi	s0,sp,16
    800040f0:	862e                	mv	a2,a1
  return namex(path, 1, name);
    800040f2:	4585                	li	a1,1
    800040f4:	00000097          	auipc	ra,0x0
    800040f8:	dbe080e7          	jalr	-578(ra) # 80003eb2 <namex>
}
    800040fc:	60a2                	ld	ra,8(sp)
    800040fe:	6402                	ld	s0,0(sp)
    80004100:	0141                	addi	sp,sp,16
    80004102:	8082                	ret

0000000080004104 <write_head>:
// Write in-memory log header to disk.
// This is the true point at which the
// current transaction commits.
static void
write_head(void)
{
    80004104:	1101                	addi	sp,sp,-32
    80004106:	ec06                	sd	ra,24(sp)
    80004108:	e822                	sd	s0,16(sp)
    8000410a:	e426                	sd	s1,8(sp)
    8000410c:	e04a                	sd	s2,0(sp)
    8000410e:	1000                	addi	s0,sp,32
  struct buf *buf = bread(log.dev, log.start);
    80004110:	0001d917          	auipc	s2,0x1d
    80004114:	a9090913          	addi	s2,s2,-1392 # 80020ba0 <log>
    80004118:	01892583          	lw	a1,24(s2)
    8000411c:	02892503          	lw	a0,40(s2)
    80004120:	fffff097          	auipc	ra,0xfffff
    80004124:	fe6080e7          	jalr	-26(ra) # 80003106 <bread>
    80004128:	84aa                	mv	s1,a0
  struct logheader *hb = (struct logheader *) (buf->data);
  int i;
  hb->n = log.lh.n;
    8000412a:	02c92683          	lw	a3,44(s2)
    8000412e:	cd34                	sw	a3,88(a0)
  for (i = 0; i < log.lh.n; i++) {
    80004130:	02d05863          	blez	a3,80004160 <write_head+0x5c>
    80004134:	0001d797          	auipc	a5,0x1d
    80004138:	a9c78793          	addi	a5,a5,-1380 # 80020bd0 <log+0x30>
    8000413c:	05c50713          	addi	a4,a0,92
    80004140:	36fd                	addiw	a3,a3,-1
    80004142:	02069613          	slli	a2,a3,0x20
    80004146:	01e65693          	srli	a3,a2,0x1e
    8000414a:	0001d617          	auipc	a2,0x1d
    8000414e:	a8a60613          	addi	a2,a2,-1398 # 80020bd4 <log+0x34>
    80004152:	96b2                	add	a3,a3,a2
    hb->block[i] = log.lh.block[i];
    80004154:	4390                	lw	a2,0(a5)
    80004156:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    80004158:	0791                	addi	a5,a5,4
    8000415a:	0711                	addi	a4,a4,4 # 43004 <_entry-0x7ffbcffc>
    8000415c:	fed79ce3          	bne	a5,a3,80004154 <write_head+0x50>
  }
  bwrite(buf);
    80004160:	8526                	mv	a0,s1
    80004162:	fffff097          	auipc	ra,0xfffff
    80004166:	096080e7          	jalr	150(ra) # 800031f8 <bwrite>
  brelse(buf);
    8000416a:	8526                	mv	a0,s1
    8000416c:	fffff097          	auipc	ra,0xfffff
    80004170:	0ca080e7          	jalr	202(ra) # 80003236 <brelse>
}
    80004174:	60e2                	ld	ra,24(sp)
    80004176:	6442                	ld	s0,16(sp)
    80004178:	64a2                	ld	s1,8(sp)
    8000417a:	6902                	ld	s2,0(sp)
    8000417c:	6105                	addi	sp,sp,32
    8000417e:	8082                	ret

0000000080004180 <install_trans>:
  for (tail = 0; tail < log.lh.n; tail++) {
    80004180:	0001d797          	auipc	a5,0x1d
    80004184:	a4c7a783          	lw	a5,-1460(a5) # 80020bcc <log+0x2c>
    80004188:	0af05d63          	blez	a5,80004242 <install_trans+0xc2>
{
    8000418c:	7139                	addi	sp,sp,-64
    8000418e:	fc06                	sd	ra,56(sp)
    80004190:	f822                	sd	s0,48(sp)
    80004192:	f426                	sd	s1,40(sp)
    80004194:	f04a                	sd	s2,32(sp)
    80004196:	ec4e                	sd	s3,24(sp)
    80004198:	e852                	sd	s4,16(sp)
    8000419a:	e456                	sd	s5,8(sp)
    8000419c:	e05a                	sd	s6,0(sp)
    8000419e:	0080                	addi	s0,sp,64
    800041a0:	8b2a                	mv	s6,a0
    800041a2:	0001da97          	auipc	s5,0x1d
    800041a6:	a2ea8a93          	addi	s5,s5,-1490 # 80020bd0 <log+0x30>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041aa:	4a01                	li	s4,0
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800041ac:	0001d997          	auipc	s3,0x1d
    800041b0:	9f498993          	addi	s3,s3,-1548 # 80020ba0 <log>
    800041b4:	a00d                	j	800041d6 <install_trans+0x56>
    brelse(lbuf);
    800041b6:	854a                	mv	a0,s2
    800041b8:	fffff097          	auipc	ra,0xfffff
    800041bc:	07e080e7          	jalr	126(ra) # 80003236 <brelse>
    brelse(dbuf);
    800041c0:	8526                	mv	a0,s1
    800041c2:	fffff097          	auipc	ra,0xfffff
    800041c6:	074080e7          	jalr	116(ra) # 80003236 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    800041ca:	2a05                	addiw	s4,s4,1
    800041cc:	0a91                	addi	s5,s5,4
    800041ce:	02c9a783          	lw	a5,44(s3)
    800041d2:	04fa5e63          	bge	s4,a5,8000422e <install_trans+0xae>
    struct buf *lbuf = bread(log.dev, log.start+tail+1); // read log block
    800041d6:	0189a583          	lw	a1,24(s3)
    800041da:	014585bb          	addw	a1,a1,s4
    800041de:	2585                	addiw	a1,a1,1
    800041e0:	0289a503          	lw	a0,40(s3)
    800041e4:	fffff097          	auipc	ra,0xfffff
    800041e8:	f22080e7          	jalr	-222(ra) # 80003106 <bread>
    800041ec:	892a                	mv	s2,a0
    struct buf *dbuf = bread(log.dev, log.lh.block[tail]); // read dst
    800041ee:	000aa583          	lw	a1,0(s5)
    800041f2:	0289a503          	lw	a0,40(s3)
    800041f6:	fffff097          	auipc	ra,0xfffff
    800041fa:	f10080e7          	jalr	-240(ra) # 80003106 <bread>
    800041fe:	84aa                	mv	s1,a0
    memmove(dbuf->data, lbuf->data, BSIZE);  // copy block to dst
    80004200:	40000613          	li	a2,1024
    80004204:	05890593          	addi	a1,s2,88
    80004208:	05850513          	addi	a0,a0,88
    8000420c:	ffffd097          	auipc	ra,0xffffd
    80004210:	b22080e7          	jalr	-1246(ra) # 80000d2e <memmove>
    bwrite(dbuf);  // write dst to disk
    80004214:	8526                	mv	a0,s1
    80004216:	fffff097          	auipc	ra,0xfffff
    8000421a:	fe2080e7          	jalr	-30(ra) # 800031f8 <bwrite>
    if(recovering == 0)
    8000421e:	f80b1ce3          	bnez	s6,800041b6 <install_trans+0x36>
      bunpin(dbuf);
    80004222:	8526                	mv	a0,s1
    80004224:	fffff097          	auipc	ra,0xfffff
    80004228:	0ec080e7          	jalr	236(ra) # 80003310 <bunpin>
    8000422c:	b769                	j	800041b6 <install_trans+0x36>
}
    8000422e:	70e2                	ld	ra,56(sp)
    80004230:	7442                	ld	s0,48(sp)
    80004232:	74a2                	ld	s1,40(sp)
    80004234:	7902                	ld	s2,32(sp)
    80004236:	69e2                	ld	s3,24(sp)
    80004238:	6a42                	ld	s4,16(sp)
    8000423a:	6aa2                	ld	s5,8(sp)
    8000423c:	6b02                	ld	s6,0(sp)
    8000423e:	6121                	addi	sp,sp,64
    80004240:	8082                	ret
    80004242:	8082                	ret

0000000080004244 <initlog>:
{
    80004244:	7179                	addi	sp,sp,-48
    80004246:	f406                	sd	ra,40(sp)
    80004248:	f022                	sd	s0,32(sp)
    8000424a:	ec26                	sd	s1,24(sp)
    8000424c:	e84a                	sd	s2,16(sp)
    8000424e:	e44e                	sd	s3,8(sp)
    80004250:	1800                	addi	s0,sp,48
    80004252:	892a                	mv	s2,a0
    80004254:	89ae                	mv	s3,a1
  initlock(&log.lock, "log");
    80004256:	0001d497          	auipc	s1,0x1d
    8000425a:	94a48493          	addi	s1,s1,-1718 # 80020ba0 <log>
    8000425e:	00004597          	auipc	a1,0x4
    80004262:	44258593          	addi	a1,a1,1090 # 800086a0 <syscalls+0x1f0>
    80004266:	8526                	mv	a0,s1
    80004268:	ffffd097          	auipc	ra,0xffffd
    8000426c:	8de080e7          	jalr	-1826(ra) # 80000b46 <initlock>
  log.start = sb->logstart;
    80004270:	0149a583          	lw	a1,20(s3)
    80004274:	cc8c                	sw	a1,24(s1)
  log.size = sb->nlog;
    80004276:	0109a783          	lw	a5,16(s3)
    8000427a:	ccdc                	sw	a5,28(s1)
  log.dev = dev;
    8000427c:	0324a423          	sw	s2,40(s1)
  struct buf *buf = bread(log.dev, log.start);
    80004280:	854a                	mv	a0,s2
    80004282:	fffff097          	auipc	ra,0xfffff
    80004286:	e84080e7          	jalr	-380(ra) # 80003106 <bread>
  log.lh.n = lh->n;
    8000428a:	4d34                	lw	a3,88(a0)
    8000428c:	d4d4                	sw	a3,44(s1)
  for (i = 0; i < log.lh.n; i++) {
    8000428e:	02d05663          	blez	a3,800042ba <initlog+0x76>
    80004292:	05c50793          	addi	a5,a0,92
    80004296:	0001d717          	auipc	a4,0x1d
    8000429a:	93a70713          	addi	a4,a4,-1734 # 80020bd0 <log+0x30>
    8000429e:	36fd                	addiw	a3,a3,-1
    800042a0:	02069613          	slli	a2,a3,0x20
    800042a4:	01e65693          	srli	a3,a2,0x1e
    800042a8:	06050613          	addi	a2,a0,96
    800042ac:	96b2                	add	a3,a3,a2
    log.lh.block[i] = lh->block[i];
    800042ae:	4390                	lw	a2,0(a5)
    800042b0:	c310                	sw	a2,0(a4)
  for (i = 0; i < log.lh.n; i++) {
    800042b2:	0791                	addi	a5,a5,4
    800042b4:	0711                	addi	a4,a4,4
    800042b6:	fed79ce3          	bne	a5,a3,800042ae <initlog+0x6a>
  brelse(buf);
    800042ba:	fffff097          	auipc	ra,0xfffff
    800042be:	f7c080e7          	jalr	-132(ra) # 80003236 <brelse>

static void
recover_from_log(void)
{
  read_head();
  install_trans(1); // if committed, copy from log to disk
    800042c2:	4505                	li	a0,1
    800042c4:	00000097          	auipc	ra,0x0
    800042c8:	ebc080e7          	jalr	-324(ra) # 80004180 <install_trans>
  log.lh.n = 0;
    800042cc:	0001d797          	auipc	a5,0x1d
    800042d0:	9007a023          	sw	zero,-1792(a5) # 80020bcc <log+0x2c>
  write_head(); // clear the log
    800042d4:	00000097          	auipc	ra,0x0
    800042d8:	e30080e7          	jalr	-464(ra) # 80004104 <write_head>
}
    800042dc:	70a2                	ld	ra,40(sp)
    800042de:	7402                	ld	s0,32(sp)
    800042e0:	64e2                	ld	s1,24(sp)
    800042e2:	6942                	ld	s2,16(sp)
    800042e4:	69a2                	ld	s3,8(sp)
    800042e6:	6145                	addi	sp,sp,48
    800042e8:	8082                	ret

00000000800042ea <begin_op>:
}

// called at the start of each FS system call.
void
begin_op(void)
{
    800042ea:	1101                	addi	sp,sp,-32
    800042ec:	ec06                	sd	ra,24(sp)
    800042ee:	e822                	sd	s0,16(sp)
    800042f0:	e426                	sd	s1,8(sp)
    800042f2:	e04a                	sd	s2,0(sp)
    800042f4:	1000                	addi	s0,sp,32
  acquire(&log.lock);
    800042f6:	0001d517          	auipc	a0,0x1d
    800042fa:	8aa50513          	addi	a0,a0,-1878 # 80020ba0 <log>
    800042fe:	ffffd097          	auipc	ra,0xffffd
    80004302:	8d8080e7          	jalr	-1832(ra) # 80000bd6 <acquire>
  while(1){
    if(log.committing){
    80004306:	0001d497          	auipc	s1,0x1d
    8000430a:	89a48493          	addi	s1,s1,-1894 # 80020ba0 <log>
      sleep(&log, &log.lock);
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    8000430e:	4979                	li	s2,30
    80004310:	a039                	j	8000431e <begin_op+0x34>
      sleep(&log, &log.lock);
    80004312:	85a6                	mv	a1,s1
    80004314:	8526                	mv	a0,s1
    80004316:	ffffe097          	auipc	ra,0xffffe
    8000431a:	e8c080e7          	jalr	-372(ra) # 800021a2 <sleep>
    if(log.committing){
    8000431e:	50dc                	lw	a5,36(s1)
    80004320:	fbed                	bnez	a5,80004312 <begin_op+0x28>
    } else if(log.lh.n + (log.outstanding+1)*MAXOPBLOCKS > LOGSIZE){
    80004322:	5098                	lw	a4,32(s1)
    80004324:	2705                	addiw	a4,a4,1
    80004326:	0007069b          	sext.w	a3,a4
    8000432a:	0027179b          	slliw	a5,a4,0x2
    8000432e:	9fb9                	addw	a5,a5,a4
    80004330:	0017979b          	slliw	a5,a5,0x1
    80004334:	54d8                	lw	a4,44(s1)
    80004336:	9fb9                	addw	a5,a5,a4
    80004338:	00f95963          	bge	s2,a5,8000434a <begin_op+0x60>
      // this op might exhaust log space; wait for commit.
      sleep(&log, &log.lock);
    8000433c:	85a6                	mv	a1,s1
    8000433e:	8526                	mv	a0,s1
    80004340:	ffffe097          	auipc	ra,0xffffe
    80004344:	e62080e7          	jalr	-414(ra) # 800021a2 <sleep>
    80004348:	bfd9                	j	8000431e <begin_op+0x34>
    } else {
      log.outstanding += 1;
    8000434a:	0001d517          	auipc	a0,0x1d
    8000434e:	85650513          	addi	a0,a0,-1962 # 80020ba0 <log>
    80004352:	d114                	sw	a3,32(a0)
      release(&log.lock);
    80004354:	ffffd097          	auipc	ra,0xffffd
    80004358:	936080e7          	jalr	-1738(ra) # 80000c8a <release>
      break;
    }
  }
}
    8000435c:	60e2                	ld	ra,24(sp)
    8000435e:	6442                	ld	s0,16(sp)
    80004360:	64a2                	ld	s1,8(sp)
    80004362:	6902                	ld	s2,0(sp)
    80004364:	6105                	addi	sp,sp,32
    80004366:	8082                	ret

0000000080004368 <end_op>:

// called at the end of each FS system call.
// commits if this was the last outstanding operation.
void
end_op(void)
{
    80004368:	7139                	addi	sp,sp,-64
    8000436a:	fc06                	sd	ra,56(sp)
    8000436c:	f822                	sd	s0,48(sp)
    8000436e:	f426                	sd	s1,40(sp)
    80004370:	f04a                	sd	s2,32(sp)
    80004372:	ec4e                	sd	s3,24(sp)
    80004374:	e852                	sd	s4,16(sp)
    80004376:	e456                	sd	s5,8(sp)
    80004378:	0080                	addi	s0,sp,64
  int do_commit = 0;

  acquire(&log.lock);
    8000437a:	0001d497          	auipc	s1,0x1d
    8000437e:	82648493          	addi	s1,s1,-2010 # 80020ba0 <log>
    80004382:	8526                	mv	a0,s1
    80004384:	ffffd097          	auipc	ra,0xffffd
    80004388:	852080e7          	jalr	-1966(ra) # 80000bd6 <acquire>
  log.outstanding -= 1;
    8000438c:	509c                	lw	a5,32(s1)
    8000438e:	37fd                	addiw	a5,a5,-1
    80004390:	0007891b          	sext.w	s2,a5
    80004394:	d09c                	sw	a5,32(s1)
  if(log.committing)
    80004396:	50dc                	lw	a5,36(s1)
    80004398:	e7b9                	bnez	a5,800043e6 <end_op+0x7e>
    panic("log.committing");
  if(log.outstanding == 0){
    8000439a:	04091e63          	bnez	s2,800043f6 <end_op+0x8e>
    do_commit = 1;
    log.committing = 1;
    8000439e:	0001d497          	auipc	s1,0x1d
    800043a2:	80248493          	addi	s1,s1,-2046 # 80020ba0 <log>
    800043a6:	4785                	li	a5,1
    800043a8:	d0dc                	sw	a5,36(s1)
    // begin_op() may be waiting for log space,
    // and decrementing log.outstanding has decreased
    // the amount of reserved space.
    wakeup(&log);
  }
  release(&log.lock);
    800043aa:	8526                	mv	a0,s1
    800043ac:	ffffd097          	auipc	ra,0xffffd
    800043b0:	8de080e7          	jalr	-1826(ra) # 80000c8a <release>
}

static void
commit()
{
  if (log.lh.n > 0) {
    800043b4:	54dc                	lw	a5,44(s1)
    800043b6:	06f04763          	bgtz	a5,80004424 <end_op+0xbc>
    acquire(&log.lock);
    800043ba:	0001c497          	auipc	s1,0x1c
    800043be:	7e648493          	addi	s1,s1,2022 # 80020ba0 <log>
    800043c2:	8526                	mv	a0,s1
    800043c4:	ffffd097          	auipc	ra,0xffffd
    800043c8:	812080e7          	jalr	-2030(ra) # 80000bd6 <acquire>
    log.committing = 0;
    800043cc:	0204a223          	sw	zero,36(s1)
    wakeup(&log);
    800043d0:	8526                	mv	a0,s1
    800043d2:	ffffe097          	auipc	ra,0xffffe
    800043d6:	e34080e7          	jalr	-460(ra) # 80002206 <wakeup>
    release(&log.lock);
    800043da:	8526                	mv	a0,s1
    800043dc:	ffffd097          	auipc	ra,0xffffd
    800043e0:	8ae080e7          	jalr	-1874(ra) # 80000c8a <release>
}
    800043e4:	a03d                	j	80004412 <end_op+0xaa>
    panic("log.committing");
    800043e6:	00004517          	auipc	a0,0x4
    800043ea:	2c250513          	addi	a0,a0,706 # 800086a8 <syscalls+0x1f8>
    800043ee:	ffffc097          	auipc	ra,0xffffc
    800043f2:	152080e7          	jalr	338(ra) # 80000540 <panic>
    wakeup(&log);
    800043f6:	0001c497          	auipc	s1,0x1c
    800043fa:	7aa48493          	addi	s1,s1,1962 # 80020ba0 <log>
    800043fe:	8526                	mv	a0,s1
    80004400:	ffffe097          	auipc	ra,0xffffe
    80004404:	e06080e7          	jalr	-506(ra) # 80002206 <wakeup>
  release(&log.lock);
    80004408:	8526                	mv	a0,s1
    8000440a:	ffffd097          	auipc	ra,0xffffd
    8000440e:	880080e7          	jalr	-1920(ra) # 80000c8a <release>
}
    80004412:	70e2                	ld	ra,56(sp)
    80004414:	7442                	ld	s0,48(sp)
    80004416:	74a2                	ld	s1,40(sp)
    80004418:	7902                	ld	s2,32(sp)
    8000441a:	69e2                	ld	s3,24(sp)
    8000441c:	6a42                	ld	s4,16(sp)
    8000441e:	6aa2                	ld	s5,8(sp)
    80004420:	6121                	addi	sp,sp,64
    80004422:	8082                	ret
  for (tail = 0; tail < log.lh.n; tail++) {
    80004424:	0001ca97          	auipc	s5,0x1c
    80004428:	7aca8a93          	addi	s5,s5,1964 # 80020bd0 <log+0x30>
    struct buf *to = bread(log.dev, log.start+tail+1); // log block
    8000442c:	0001ca17          	auipc	s4,0x1c
    80004430:	774a0a13          	addi	s4,s4,1908 # 80020ba0 <log>
    80004434:	018a2583          	lw	a1,24(s4)
    80004438:	012585bb          	addw	a1,a1,s2
    8000443c:	2585                	addiw	a1,a1,1
    8000443e:	028a2503          	lw	a0,40(s4)
    80004442:	fffff097          	auipc	ra,0xfffff
    80004446:	cc4080e7          	jalr	-828(ra) # 80003106 <bread>
    8000444a:	84aa                	mv	s1,a0
    struct buf *from = bread(log.dev, log.lh.block[tail]); // cache block
    8000444c:	000aa583          	lw	a1,0(s5)
    80004450:	028a2503          	lw	a0,40(s4)
    80004454:	fffff097          	auipc	ra,0xfffff
    80004458:	cb2080e7          	jalr	-846(ra) # 80003106 <bread>
    8000445c:	89aa                	mv	s3,a0
    memmove(to->data, from->data, BSIZE);
    8000445e:	40000613          	li	a2,1024
    80004462:	05850593          	addi	a1,a0,88
    80004466:	05848513          	addi	a0,s1,88
    8000446a:	ffffd097          	auipc	ra,0xffffd
    8000446e:	8c4080e7          	jalr	-1852(ra) # 80000d2e <memmove>
    bwrite(to);  // write the log
    80004472:	8526                	mv	a0,s1
    80004474:	fffff097          	auipc	ra,0xfffff
    80004478:	d84080e7          	jalr	-636(ra) # 800031f8 <bwrite>
    brelse(from);
    8000447c:	854e                	mv	a0,s3
    8000447e:	fffff097          	auipc	ra,0xfffff
    80004482:	db8080e7          	jalr	-584(ra) # 80003236 <brelse>
    brelse(to);
    80004486:	8526                	mv	a0,s1
    80004488:	fffff097          	auipc	ra,0xfffff
    8000448c:	dae080e7          	jalr	-594(ra) # 80003236 <brelse>
  for (tail = 0; tail < log.lh.n; tail++) {
    80004490:	2905                	addiw	s2,s2,1
    80004492:	0a91                	addi	s5,s5,4
    80004494:	02ca2783          	lw	a5,44(s4)
    80004498:	f8f94ee3          	blt	s2,a5,80004434 <end_op+0xcc>
    write_log();     // Write modified blocks from cache to log
    write_head();    // Write header to disk -- the real commit
    8000449c:	00000097          	auipc	ra,0x0
    800044a0:	c68080e7          	jalr	-920(ra) # 80004104 <write_head>
    install_trans(0); // Now install writes to home locations
    800044a4:	4501                	li	a0,0
    800044a6:	00000097          	auipc	ra,0x0
    800044aa:	cda080e7          	jalr	-806(ra) # 80004180 <install_trans>
    log.lh.n = 0;
    800044ae:	0001c797          	auipc	a5,0x1c
    800044b2:	7007af23          	sw	zero,1822(a5) # 80020bcc <log+0x2c>
    write_head();    // Erase the transaction from the log
    800044b6:	00000097          	auipc	ra,0x0
    800044ba:	c4e080e7          	jalr	-946(ra) # 80004104 <write_head>
    800044be:	bdf5                	j	800043ba <end_op+0x52>

00000000800044c0 <log_write>:
//   modify bp->data[]
//   log_write(bp)
//   brelse(bp)
void
log_write(struct buf *b)
{
    800044c0:	1101                	addi	sp,sp,-32
    800044c2:	ec06                	sd	ra,24(sp)
    800044c4:	e822                	sd	s0,16(sp)
    800044c6:	e426                	sd	s1,8(sp)
    800044c8:	e04a                	sd	s2,0(sp)
    800044ca:	1000                	addi	s0,sp,32
    800044cc:	84aa                	mv	s1,a0
  int i;

  acquire(&log.lock);
    800044ce:	0001c917          	auipc	s2,0x1c
    800044d2:	6d290913          	addi	s2,s2,1746 # 80020ba0 <log>
    800044d6:	854a                	mv	a0,s2
    800044d8:	ffffc097          	auipc	ra,0xffffc
    800044dc:	6fe080e7          	jalr	1790(ra) # 80000bd6 <acquire>
  if (log.lh.n >= LOGSIZE || log.lh.n >= log.size - 1)
    800044e0:	02c92603          	lw	a2,44(s2)
    800044e4:	47f5                	li	a5,29
    800044e6:	06c7c563          	blt	a5,a2,80004550 <log_write+0x90>
    800044ea:	0001c797          	auipc	a5,0x1c
    800044ee:	6d27a783          	lw	a5,1746(a5) # 80020bbc <log+0x1c>
    800044f2:	37fd                	addiw	a5,a5,-1
    800044f4:	04f65e63          	bge	a2,a5,80004550 <log_write+0x90>
    panic("too big a transaction");
  if (log.outstanding < 1)
    800044f8:	0001c797          	auipc	a5,0x1c
    800044fc:	6c87a783          	lw	a5,1736(a5) # 80020bc0 <log+0x20>
    80004500:	06f05063          	blez	a5,80004560 <log_write+0xa0>
    panic("log_write outside of trans");

  for (i = 0; i < log.lh.n; i++) {
    80004504:	4781                	li	a5,0
    80004506:	06c05563          	blez	a2,80004570 <log_write+0xb0>
    if (log.lh.block[i] == b->blockno)   // log absorption
    8000450a:	44cc                	lw	a1,12(s1)
    8000450c:	0001c717          	auipc	a4,0x1c
    80004510:	6c470713          	addi	a4,a4,1732 # 80020bd0 <log+0x30>
  for (i = 0; i < log.lh.n; i++) {
    80004514:	4781                	li	a5,0
    if (log.lh.block[i] == b->blockno)   // log absorption
    80004516:	4314                	lw	a3,0(a4)
    80004518:	04b68c63          	beq	a3,a1,80004570 <log_write+0xb0>
  for (i = 0; i < log.lh.n; i++) {
    8000451c:	2785                	addiw	a5,a5,1
    8000451e:	0711                	addi	a4,a4,4
    80004520:	fef61be3          	bne	a2,a5,80004516 <log_write+0x56>
      break;
  }
  log.lh.block[i] = b->blockno;
    80004524:	0621                	addi	a2,a2,8
    80004526:	060a                	slli	a2,a2,0x2
    80004528:	0001c797          	auipc	a5,0x1c
    8000452c:	67878793          	addi	a5,a5,1656 # 80020ba0 <log>
    80004530:	97b2                	add	a5,a5,a2
    80004532:	44d8                	lw	a4,12(s1)
    80004534:	cb98                	sw	a4,16(a5)
  if (i == log.lh.n) {  // Add new block to log?
    bpin(b);
    80004536:	8526                	mv	a0,s1
    80004538:	fffff097          	auipc	ra,0xfffff
    8000453c:	d9c080e7          	jalr	-612(ra) # 800032d4 <bpin>
    log.lh.n++;
    80004540:	0001c717          	auipc	a4,0x1c
    80004544:	66070713          	addi	a4,a4,1632 # 80020ba0 <log>
    80004548:	575c                	lw	a5,44(a4)
    8000454a:	2785                	addiw	a5,a5,1
    8000454c:	d75c                	sw	a5,44(a4)
    8000454e:	a82d                	j	80004588 <log_write+0xc8>
    panic("too big a transaction");
    80004550:	00004517          	auipc	a0,0x4
    80004554:	16850513          	addi	a0,a0,360 # 800086b8 <syscalls+0x208>
    80004558:	ffffc097          	auipc	ra,0xffffc
    8000455c:	fe8080e7          	jalr	-24(ra) # 80000540 <panic>
    panic("log_write outside of trans");
    80004560:	00004517          	auipc	a0,0x4
    80004564:	17050513          	addi	a0,a0,368 # 800086d0 <syscalls+0x220>
    80004568:	ffffc097          	auipc	ra,0xffffc
    8000456c:	fd8080e7          	jalr	-40(ra) # 80000540 <panic>
  log.lh.block[i] = b->blockno;
    80004570:	00878693          	addi	a3,a5,8
    80004574:	068a                	slli	a3,a3,0x2
    80004576:	0001c717          	auipc	a4,0x1c
    8000457a:	62a70713          	addi	a4,a4,1578 # 80020ba0 <log>
    8000457e:	9736                	add	a4,a4,a3
    80004580:	44d4                	lw	a3,12(s1)
    80004582:	cb14                	sw	a3,16(a4)
  if (i == log.lh.n) {  // Add new block to log?
    80004584:	faf609e3          	beq	a2,a5,80004536 <log_write+0x76>
  }
  release(&log.lock);
    80004588:	0001c517          	auipc	a0,0x1c
    8000458c:	61850513          	addi	a0,a0,1560 # 80020ba0 <log>
    80004590:	ffffc097          	auipc	ra,0xffffc
    80004594:	6fa080e7          	jalr	1786(ra) # 80000c8a <release>
}
    80004598:	60e2                	ld	ra,24(sp)
    8000459a:	6442                	ld	s0,16(sp)
    8000459c:	64a2                	ld	s1,8(sp)
    8000459e:	6902                	ld	s2,0(sp)
    800045a0:	6105                	addi	sp,sp,32
    800045a2:	8082                	ret

00000000800045a4 <initsleeplock>:
#include "proc.h"
#include "sleeplock.h"

void
initsleeplock(struct sleeplock *lk, char *name)
{
    800045a4:	1101                	addi	sp,sp,-32
    800045a6:	ec06                	sd	ra,24(sp)
    800045a8:	e822                	sd	s0,16(sp)
    800045aa:	e426                	sd	s1,8(sp)
    800045ac:	e04a                	sd	s2,0(sp)
    800045ae:	1000                	addi	s0,sp,32
    800045b0:	84aa                	mv	s1,a0
    800045b2:	892e                	mv	s2,a1
  initlock(&lk->lk, "sleep lock");
    800045b4:	00004597          	auipc	a1,0x4
    800045b8:	13c58593          	addi	a1,a1,316 # 800086f0 <syscalls+0x240>
    800045bc:	0521                	addi	a0,a0,8
    800045be:	ffffc097          	auipc	ra,0xffffc
    800045c2:	588080e7          	jalr	1416(ra) # 80000b46 <initlock>
  lk->name = name;
    800045c6:	0324b023          	sd	s2,32(s1)
  lk->locked = 0;
    800045ca:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    800045ce:	0204a423          	sw	zero,40(s1)
}
    800045d2:	60e2                	ld	ra,24(sp)
    800045d4:	6442                	ld	s0,16(sp)
    800045d6:	64a2                	ld	s1,8(sp)
    800045d8:	6902                	ld	s2,0(sp)
    800045da:	6105                	addi	sp,sp,32
    800045dc:	8082                	ret

00000000800045de <acquiresleep>:

void
acquiresleep(struct sleeplock *lk)
{
    800045de:	1101                	addi	sp,sp,-32
    800045e0:	ec06                	sd	ra,24(sp)
    800045e2:	e822                	sd	s0,16(sp)
    800045e4:	e426                	sd	s1,8(sp)
    800045e6:	e04a                	sd	s2,0(sp)
    800045e8:	1000                	addi	s0,sp,32
    800045ea:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    800045ec:	00850913          	addi	s2,a0,8
    800045f0:	854a                	mv	a0,s2
    800045f2:	ffffc097          	auipc	ra,0xffffc
    800045f6:	5e4080e7          	jalr	1508(ra) # 80000bd6 <acquire>
  while (lk->locked) {
    800045fa:	409c                	lw	a5,0(s1)
    800045fc:	cb89                	beqz	a5,8000460e <acquiresleep+0x30>
    sleep(lk, &lk->lk);
    800045fe:	85ca                	mv	a1,s2
    80004600:	8526                	mv	a0,s1
    80004602:	ffffe097          	auipc	ra,0xffffe
    80004606:	ba0080e7          	jalr	-1120(ra) # 800021a2 <sleep>
  while (lk->locked) {
    8000460a:	409c                	lw	a5,0(s1)
    8000460c:	fbed                	bnez	a5,800045fe <acquiresleep+0x20>
  }
  lk->locked = 1;
    8000460e:	4785                	li	a5,1
    80004610:	c09c                	sw	a5,0(s1)
  lk->pid = myproc()->pid;
    80004612:	ffffd097          	auipc	ra,0xffffd
    80004616:	4e8080e7          	jalr	1256(ra) # 80001afa <myproc>
    8000461a:	591c                	lw	a5,48(a0)
    8000461c:	d49c                	sw	a5,40(s1)
  release(&lk->lk);
    8000461e:	854a                	mv	a0,s2
    80004620:	ffffc097          	auipc	ra,0xffffc
    80004624:	66a080e7          	jalr	1642(ra) # 80000c8a <release>
}
    80004628:	60e2                	ld	ra,24(sp)
    8000462a:	6442                	ld	s0,16(sp)
    8000462c:	64a2                	ld	s1,8(sp)
    8000462e:	6902                	ld	s2,0(sp)
    80004630:	6105                	addi	sp,sp,32
    80004632:	8082                	ret

0000000080004634 <releasesleep>:

void
releasesleep(struct sleeplock *lk)
{
    80004634:	1101                	addi	sp,sp,-32
    80004636:	ec06                	sd	ra,24(sp)
    80004638:	e822                	sd	s0,16(sp)
    8000463a:	e426                	sd	s1,8(sp)
    8000463c:	e04a                	sd	s2,0(sp)
    8000463e:	1000                	addi	s0,sp,32
    80004640:	84aa                	mv	s1,a0
  acquire(&lk->lk);
    80004642:	00850913          	addi	s2,a0,8
    80004646:	854a                	mv	a0,s2
    80004648:	ffffc097          	auipc	ra,0xffffc
    8000464c:	58e080e7          	jalr	1422(ra) # 80000bd6 <acquire>
  lk->locked = 0;
    80004650:	0004a023          	sw	zero,0(s1)
  lk->pid = 0;
    80004654:	0204a423          	sw	zero,40(s1)
  wakeup(lk);
    80004658:	8526                	mv	a0,s1
    8000465a:	ffffe097          	auipc	ra,0xffffe
    8000465e:	bac080e7          	jalr	-1108(ra) # 80002206 <wakeup>
  release(&lk->lk);
    80004662:	854a                	mv	a0,s2
    80004664:	ffffc097          	auipc	ra,0xffffc
    80004668:	626080e7          	jalr	1574(ra) # 80000c8a <release>
}
    8000466c:	60e2                	ld	ra,24(sp)
    8000466e:	6442                	ld	s0,16(sp)
    80004670:	64a2                	ld	s1,8(sp)
    80004672:	6902                	ld	s2,0(sp)
    80004674:	6105                	addi	sp,sp,32
    80004676:	8082                	ret

0000000080004678 <holdingsleep>:

int
holdingsleep(struct sleeplock *lk)
{
    80004678:	7179                	addi	sp,sp,-48
    8000467a:	f406                	sd	ra,40(sp)
    8000467c:	f022                	sd	s0,32(sp)
    8000467e:	ec26                	sd	s1,24(sp)
    80004680:	e84a                	sd	s2,16(sp)
    80004682:	e44e                	sd	s3,8(sp)
    80004684:	1800                	addi	s0,sp,48
    80004686:	84aa                	mv	s1,a0
  int r;
  
  acquire(&lk->lk);
    80004688:	00850913          	addi	s2,a0,8
    8000468c:	854a                	mv	a0,s2
    8000468e:	ffffc097          	auipc	ra,0xffffc
    80004692:	548080e7          	jalr	1352(ra) # 80000bd6 <acquire>
  r = lk->locked && (lk->pid == myproc()->pid);
    80004696:	409c                	lw	a5,0(s1)
    80004698:	ef99                	bnez	a5,800046b6 <holdingsleep+0x3e>
    8000469a:	4481                	li	s1,0
  release(&lk->lk);
    8000469c:	854a                	mv	a0,s2
    8000469e:	ffffc097          	auipc	ra,0xffffc
    800046a2:	5ec080e7          	jalr	1516(ra) # 80000c8a <release>
  return r;
}
    800046a6:	8526                	mv	a0,s1
    800046a8:	70a2                	ld	ra,40(sp)
    800046aa:	7402                	ld	s0,32(sp)
    800046ac:	64e2                	ld	s1,24(sp)
    800046ae:	6942                	ld	s2,16(sp)
    800046b0:	69a2                	ld	s3,8(sp)
    800046b2:	6145                	addi	sp,sp,48
    800046b4:	8082                	ret
  r = lk->locked && (lk->pid == myproc()->pid);
    800046b6:	0284a983          	lw	s3,40(s1)
    800046ba:	ffffd097          	auipc	ra,0xffffd
    800046be:	440080e7          	jalr	1088(ra) # 80001afa <myproc>
    800046c2:	5904                	lw	s1,48(a0)
    800046c4:	413484b3          	sub	s1,s1,s3
    800046c8:	0014b493          	seqz	s1,s1
    800046cc:	bfc1                	j	8000469c <holdingsleep+0x24>

00000000800046ce <fileinit>:
  struct file file[NFILE];
} ftable;

void
fileinit(void)
{
    800046ce:	1141                	addi	sp,sp,-16
    800046d0:	e406                	sd	ra,8(sp)
    800046d2:	e022                	sd	s0,0(sp)
    800046d4:	0800                	addi	s0,sp,16
  initlock(&ftable.lock, "ftable");
    800046d6:	00004597          	auipc	a1,0x4
    800046da:	02a58593          	addi	a1,a1,42 # 80008700 <syscalls+0x250>
    800046de:	0001c517          	auipc	a0,0x1c
    800046e2:	60a50513          	addi	a0,a0,1546 # 80020ce8 <ftable>
    800046e6:	ffffc097          	auipc	ra,0xffffc
    800046ea:	460080e7          	jalr	1120(ra) # 80000b46 <initlock>
}
    800046ee:	60a2                	ld	ra,8(sp)
    800046f0:	6402                	ld	s0,0(sp)
    800046f2:	0141                	addi	sp,sp,16
    800046f4:	8082                	ret

00000000800046f6 <filealloc>:

// Allocate a file structure.
struct file*
filealloc(void)
{
    800046f6:	1101                	addi	sp,sp,-32
    800046f8:	ec06                	sd	ra,24(sp)
    800046fa:	e822                	sd	s0,16(sp)
    800046fc:	e426                	sd	s1,8(sp)
    800046fe:	1000                	addi	s0,sp,32
  struct file *f;

  acquire(&ftable.lock);
    80004700:	0001c517          	auipc	a0,0x1c
    80004704:	5e850513          	addi	a0,a0,1512 # 80020ce8 <ftable>
    80004708:	ffffc097          	auipc	ra,0xffffc
    8000470c:	4ce080e7          	jalr	1230(ra) # 80000bd6 <acquire>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004710:	0001c497          	auipc	s1,0x1c
    80004714:	5f048493          	addi	s1,s1,1520 # 80020d00 <ftable+0x18>
    80004718:	0001d717          	auipc	a4,0x1d
    8000471c:	58870713          	addi	a4,a4,1416 # 80021ca0 <disk>
    if(f->ref == 0){
    80004720:	40dc                	lw	a5,4(s1)
    80004722:	cf99                	beqz	a5,80004740 <filealloc+0x4a>
  for(f = ftable.file; f < ftable.file + NFILE; f++){
    80004724:	02848493          	addi	s1,s1,40
    80004728:	fee49ce3          	bne	s1,a4,80004720 <filealloc+0x2a>
      f->ref = 1;
      release(&ftable.lock);
      return f;
    }
  }
  release(&ftable.lock);
    8000472c:	0001c517          	auipc	a0,0x1c
    80004730:	5bc50513          	addi	a0,a0,1468 # 80020ce8 <ftable>
    80004734:	ffffc097          	auipc	ra,0xffffc
    80004738:	556080e7          	jalr	1366(ra) # 80000c8a <release>
  return 0;
    8000473c:	4481                	li	s1,0
    8000473e:	a819                	j	80004754 <filealloc+0x5e>
      f->ref = 1;
    80004740:	4785                	li	a5,1
    80004742:	c0dc                	sw	a5,4(s1)
      release(&ftable.lock);
    80004744:	0001c517          	auipc	a0,0x1c
    80004748:	5a450513          	addi	a0,a0,1444 # 80020ce8 <ftable>
    8000474c:	ffffc097          	auipc	ra,0xffffc
    80004750:	53e080e7          	jalr	1342(ra) # 80000c8a <release>
}
    80004754:	8526                	mv	a0,s1
    80004756:	60e2                	ld	ra,24(sp)
    80004758:	6442                	ld	s0,16(sp)
    8000475a:	64a2                	ld	s1,8(sp)
    8000475c:	6105                	addi	sp,sp,32
    8000475e:	8082                	ret

0000000080004760 <filedup>:

// Increment ref count for file f.
struct file*
filedup(struct file *f)
{
    80004760:	1101                	addi	sp,sp,-32
    80004762:	ec06                	sd	ra,24(sp)
    80004764:	e822                	sd	s0,16(sp)
    80004766:	e426                	sd	s1,8(sp)
    80004768:	1000                	addi	s0,sp,32
    8000476a:	84aa                	mv	s1,a0
  acquire(&ftable.lock);
    8000476c:	0001c517          	auipc	a0,0x1c
    80004770:	57c50513          	addi	a0,a0,1404 # 80020ce8 <ftable>
    80004774:	ffffc097          	auipc	ra,0xffffc
    80004778:	462080e7          	jalr	1122(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    8000477c:	40dc                	lw	a5,4(s1)
    8000477e:	02f05263          	blez	a5,800047a2 <filedup+0x42>
    panic("filedup");
  f->ref++;
    80004782:	2785                	addiw	a5,a5,1
    80004784:	c0dc                	sw	a5,4(s1)
  release(&ftable.lock);
    80004786:	0001c517          	auipc	a0,0x1c
    8000478a:	56250513          	addi	a0,a0,1378 # 80020ce8 <ftable>
    8000478e:	ffffc097          	auipc	ra,0xffffc
    80004792:	4fc080e7          	jalr	1276(ra) # 80000c8a <release>
  return f;
}
    80004796:	8526                	mv	a0,s1
    80004798:	60e2                	ld	ra,24(sp)
    8000479a:	6442                	ld	s0,16(sp)
    8000479c:	64a2                	ld	s1,8(sp)
    8000479e:	6105                	addi	sp,sp,32
    800047a0:	8082                	ret
    panic("filedup");
    800047a2:	00004517          	auipc	a0,0x4
    800047a6:	f6650513          	addi	a0,a0,-154 # 80008708 <syscalls+0x258>
    800047aa:	ffffc097          	auipc	ra,0xffffc
    800047ae:	d96080e7          	jalr	-618(ra) # 80000540 <panic>

00000000800047b2 <fileclose>:

// Close file f.  (Decrement ref count, close when reaches 0.)
void
fileclose(struct file *f)
{
    800047b2:	7139                	addi	sp,sp,-64
    800047b4:	fc06                	sd	ra,56(sp)
    800047b6:	f822                	sd	s0,48(sp)
    800047b8:	f426                	sd	s1,40(sp)
    800047ba:	f04a                	sd	s2,32(sp)
    800047bc:	ec4e                	sd	s3,24(sp)
    800047be:	e852                	sd	s4,16(sp)
    800047c0:	e456                	sd	s5,8(sp)
    800047c2:	0080                	addi	s0,sp,64
    800047c4:	84aa                	mv	s1,a0
  struct file ff;

  acquire(&ftable.lock);
    800047c6:	0001c517          	auipc	a0,0x1c
    800047ca:	52250513          	addi	a0,a0,1314 # 80020ce8 <ftable>
    800047ce:	ffffc097          	auipc	ra,0xffffc
    800047d2:	408080e7          	jalr	1032(ra) # 80000bd6 <acquire>
  if(f->ref < 1)
    800047d6:	40dc                	lw	a5,4(s1)
    800047d8:	06f05163          	blez	a5,8000483a <fileclose+0x88>
    panic("fileclose");
  if(--f->ref > 0){
    800047dc:	37fd                	addiw	a5,a5,-1
    800047de:	0007871b          	sext.w	a4,a5
    800047e2:	c0dc                	sw	a5,4(s1)
    800047e4:	06e04363          	bgtz	a4,8000484a <fileclose+0x98>
    release(&ftable.lock);
    return;
  }
  ff = *f;
    800047e8:	0004a903          	lw	s2,0(s1)
    800047ec:	0094ca83          	lbu	s5,9(s1)
    800047f0:	0104ba03          	ld	s4,16(s1)
    800047f4:	0184b983          	ld	s3,24(s1)
  f->ref = 0;
    800047f8:	0004a223          	sw	zero,4(s1)
  f->type = FD_NONE;
    800047fc:	0004a023          	sw	zero,0(s1)
  release(&ftable.lock);
    80004800:	0001c517          	auipc	a0,0x1c
    80004804:	4e850513          	addi	a0,a0,1256 # 80020ce8 <ftable>
    80004808:	ffffc097          	auipc	ra,0xffffc
    8000480c:	482080e7          	jalr	1154(ra) # 80000c8a <release>

  if(ff.type == FD_PIPE){
    80004810:	4785                	li	a5,1
    80004812:	04f90d63          	beq	s2,a5,8000486c <fileclose+0xba>
    pipeclose(ff.pipe, ff.writable);
  } else if(ff.type == FD_INODE || ff.type == FD_DEVICE){
    80004816:	3979                	addiw	s2,s2,-2
    80004818:	4785                	li	a5,1
    8000481a:	0527e063          	bltu	a5,s2,8000485a <fileclose+0xa8>
    begin_op();
    8000481e:	00000097          	auipc	ra,0x0
    80004822:	acc080e7          	jalr	-1332(ra) # 800042ea <begin_op>
    iput(ff.ip);
    80004826:	854e                	mv	a0,s3
    80004828:	fffff097          	auipc	ra,0xfffff
    8000482c:	2b0080e7          	jalr	688(ra) # 80003ad8 <iput>
    end_op();
    80004830:	00000097          	auipc	ra,0x0
    80004834:	b38080e7          	jalr	-1224(ra) # 80004368 <end_op>
    80004838:	a00d                	j	8000485a <fileclose+0xa8>
    panic("fileclose");
    8000483a:	00004517          	auipc	a0,0x4
    8000483e:	ed650513          	addi	a0,a0,-298 # 80008710 <syscalls+0x260>
    80004842:	ffffc097          	auipc	ra,0xffffc
    80004846:	cfe080e7          	jalr	-770(ra) # 80000540 <panic>
    release(&ftable.lock);
    8000484a:	0001c517          	auipc	a0,0x1c
    8000484e:	49e50513          	addi	a0,a0,1182 # 80020ce8 <ftable>
    80004852:	ffffc097          	auipc	ra,0xffffc
    80004856:	438080e7          	jalr	1080(ra) # 80000c8a <release>
  }
}
    8000485a:	70e2                	ld	ra,56(sp)
    8000485c:	7442                	ld	s0,48(sp)
    8000485e:	74a2                	ld	s1,40(sp)
    80004860:	7902                	ld	s2,32(sp)
    80004862:	69e2                	ld	s3,24(sp)
    80004864:	6a42                	ld	s4,16(sp)
    80004866:	6aa2                	ld	s5,8(sp)
    80004868:	6121                	addi	sp,sp,64
    8000486a:	8082                	ret
    pipeclose(ff.pipe, ff.writable);
    8000486c:	85d6                	mv	a1,s5
    8000486e:	8552                	mv	a0,s4
    80004870:	00000097          	auipc	ra,0x0
    80004874:	34c080e7          	jalr	844(ra) # 80004bbc <pipeclose>
    80004878:	b7cd                	j	8000485a <fileclose+0xa8>

000000008000487a <filestat>:

// Get metadata about file f.
// addr is a user virtual address, pointing to a struct stat.
int
filestat(struct file *f, uint64 addr)
{
    8000487a:	715d                	addi	sp,sp,-80
    8000487c:	e486                	sd	ra,72(sp)
    8000487e:	e0a2                	sd	s0,64(sp)
    80004880:	fc26                	sd	s1,56(sp)
    80004882:	f84a                	sd	s2,48(sp)
    80004884:	f44e                	sd	s3,40(sp)
    80004886:	0880                	addi	s0,sp,80
    80004888:	84aa                	mv	s1,a0
    8000488a:	89ae                	mv	s3,a1
  struct proc *p = myproc();
    8000488c:	ffffd097          	auipc	ra,0xffffd
    80004890:	26e080e7          	jalr	622(ra) # 80001afa <myproc>
  struct stat st;
  
  if(f->type == FD_INODE || f->type == FD_DEVICE){
    80004894:	409c                	lw	a5,0(s1)
    80004896:	37f9                	addiw	a5,a5,-2
    80004898:	4705                	li	a4,1
    8000489a:	04f76763          	bltu	a4,a5,800048e8 <filestat+0x6e>
    8000489e:	892a                	mv	s2,a0
    ilock(f->ip);
    800048a0:	6c88                	ld	a0,24(s1)
    800048a2:	fffff097          	auipc	ra,0xfffff
    800048a6:	07c080e7          	jalr	124(ra) # 8000391e <ilock>
    stati(f->ip, &st);
    800048aa:	fb840593          	addi	a1,s0,-72
    800048ae:	6c88                	ld	a0,24(s1)
    800048b0:	fffff097          	auipc	ra,0xfffff
    800048b4:	2f8080e7          	jalr	760(ra) # 80003ba8 <stati>
    iunlock(f->ip);
    800048b8:	6c88                	ld	a0,24(s1)
    800048ba:	fffff097          	auipc	ra,0xfffff
    800048be:	126080e7          	jalr	294(ra) # 800039e0 <iunlock>
    if(copyout(p->pagetable, addr, (char *)&st, sizeof(st)) < 0)
    800048c2:	46e1                	li	a3,24
    800048c4:	fb840613          	addi	a2,s0,-72
    800048c8:	85ce                	mv	a1,s3
    800048ca:	05093503          	ld	a0,80(s2)
    800048ce:	ffffd097          	auipc	ra,0xffffd
    800048d2:	d9e080e7          	jalr	-610(ra) # 8000166c <copyout>
    800048d6:	41f5551b          	sraiw	a0,a0,0x1f
      return -1;
    return 0;
  }
  return -1;
}
    800048da:	60a6                	ld	ra,72(sp)
    800048dc:	6406                	ld	s0,64(sp)
    800048de:	74e2                	ld	s1,56(sp)
    800048e0:	7942                	ld	s2,48(sp)
    800048e2:	79a2                	ld	s3,40(sp)
    800048e4:	6161                	addi	sp,sp,80
    800048e6:	8082                	ret
  return -1;
    800048e8:	557d                	li	a0,-1
    800048ea:	bfc5                	j	800048da <filestat+0x60>

00000000800048ec <fileread>:

// Read from file f.
// addr is a user virtual address.
int
fileread(struct file *f, uint64 addr, int n)
{
    800048ec:	7179                	addi	sp,sp,-48
    800048ee:	f406                	sd	ra,40(sp)
    800048f0:	f022                	sd	s0,32(sp)
    800048f2:	ec26                	sd	s1,24(sp)
    800048f4:	e84a                	sd	s2,16(sp)
    800048f6:	e44e                	sd	s3,8(sp)
    800048f8:	1800                	addi	s0,sp,48
  int r = 0;

  if(f->readable == 0)
    800048fa:	00854783          	lbu	a5,8(a0)
    800048fe:	c3d5                	beqz	a5,800049a2 <fileread+0xb6>
    80004900:	84aa                	mv	s1,a0
    80004902:	89ae                	mv	s3,a1
    80004904:	8932                	mv	s2,a2
    return -1;

  if(f->type == FD_PIPE){
    80004906:	411c                	lw	a5,0(a0)
    80004908:	4705                	li	a4,1
    8000490a:	04e78963          	beq	a5,a4,8000495c <fileread+0x70>
    r = piperead(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    8000490e:	470d                	li	a4,3
    80004910:	04e78d63          	beq	a5,a4,8000496a <fileread+0x7e>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
      return -1;
    r = devsw[f->major].read(1, addr, n);
  } else if(f->type == FD_INODE){
    80004914:	4709                	li	a4,2
    80004916:	06e79e63          	bne	a5,a4,80004992 <fileread+0xa6>
    ilock(f->ip);
    8000491a:	6d08                	ld	a0,24(a0)
    8000491c:	fffff097          	auipc	ra,0xfffff
    80004920:	002080e7          	jalr	2(ra) # 8000391e <ilock>
    if((r = readi(f->ip, 1, addr, f->off, n)) > 0)
    80004924:	874a                	mv	a4,s2
    80004926:	5094                	lw	a3,32(s1)
    80004928:	864e                	mv	a2,s3
    8000492a:	4585                	li	a1,1
    8000492c:	6c88                	ld	a0,24(s1)
    8000492e:	fffff097          	auipc	ra,0xfffff
    80004932:	2a4080e7          	jalr	676(ra) # 80003bd2 <readi>
    80004936:	892a                	mv	s2,a0
    80004938:	00a05563          	blez	a0,80004942 <fileread+0x56>
      f->off += r;
    8000493c:	509c                	lw	a5,32(s1)
    8000493e:	9fa9                	addw	a5,a5,a0
    80004940:	d09c                	sw	a5,32(s1)
    iunlock(f->ip);
    80004942:	6c88                	ld	a0,24(s1)
    80004944:	fffff097          	auipc	ra,0xfffff
    80004948:	09c080e7          	jalr	156(ra) # 800039e0 <iunlock>
  } else {
    panic("fileread");
  }

  return r;
}
    8000494c:	854a                	mv	a0,s2
    8000494e:	70a2                	ld	ra,40(sp)
    80004950:	7402                	ld	s0,32(sp)
    80004952:	64e2                	ld	s1,24(sp)
    80004954:	6942                	ld	s2,16(sp)
    80004956:	69a2                	ld	s3,8(sp)
    80004958:	6145                	addi	sp,sp,48
    8000495a:	8082                	ret
    r = piperead(f->pipe, addr, n);
    8000495c:	6908                	ld	a0,16(a0)
    8000495e:	00000097          	auipc	ra,0x0
    80004962:	3c6080e7          	jalr	966(ra) # 80004d24 <piperead>
    80004966:	892a                	mv	s2,a0
    80004968:	b7d5                	j	8000494c <fileread+0x60>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].read)
    8000496a:	02451783          	lh	a5,36(a0)
    8000496e:	03079693          	slli	a3,a5,0x30
    80004972:	92c1                	srli	a3,a3,0x30
    80004974:	4725                	li	a4,9
    80004976:	02d76863          	bltu	a4,a3,800049a6 <fileread+0xba>
    8000497a:	0792                	slli	a5,a5,0x4
    8000497c:	0001c717          	auipc	a4,0x1c
    80004980:	2cc70713          	addi	a4,a4,716 # 80020c48 <devsw>
    80004984:	97ba                	add	a5,a5,a4
    80004986:	639c                	ld	a5,0(a5)
    80004988:	c38d                	beqz	a5,800049aa <fileread+0xbe>
    r = devsw[f->major].read(1, addr, n);
    8000498a:	4505                	li	a0,1
    8000498c:	9782                	jalr	a5
    8000498e:	892a                	mv	s2,a0
    80004990:	bf75                	j	8000494c <fileread+0x60>
    panic("fileread");
    80004992:	00004517          	auipc	a0,0x4
    80004996:	d8e50513          	addi	a0,a0,-626 # 80008720 <syscalls+0x270>
    8000499a:	ffffc097          	auipc	ra,0xffffc
    8000499e:	ba6080e7          	jalr	-1114(ra) # 80000540 <panic>
    return -1;
    800049a2:	597d                	li	s2,-1
    800049a4:	b765                	j	8000494c <fileread+0x60>
      return -1;
    800049a6:	597d                	li	s2,-1
    800049a8:	b755                	j	8000494c <fileread+0x60>
    800049aa:	597d                	li	s2,-1
    800049ac:	b745                	j	8000494c <fileread+0x60>

00000000800049ae <filewrite>:

// Write to file f.
// addr is a user virtual address.
int
filewrite(struct file *f, uint64 addr, int n)
{
    800049ae:	715d                	addi	sp,sp,-80
    800049b0:	e486                	sd	ra,72(sp)
    800049b2:	e0a2                	sd	s0,64(sp)
    800049b4:	fc26                	sd	s1,56(sp)
    800049b6:	f84a                	sd	s2,48(sp)
    800049b8:	f44e                	sd	s3,40(sp)
    800049ba:	f052                	sd	s4,32(sp)
    800049bc:	ec56                	sd	s5,24(sp)
    800049be:	e85a                	sd	s6,16(sp)
    800049c0:	e45e                	sd	s7,8(sp)
    800049c2:	e062                	sd	s8,0(sp)
    800049c4:	0880                	addi	s0,sp,80
  int r, ret = 0;

  if(f->writable == 0)
    800049c6:	00954783          	lbu	a5,9(a0)
    800049ca:	10078663          	beqz	a5,80004ad6 <filewrite+0x128>
    800049ce:	892a                	mv	s2,a0
    800049d0:	8b2e                	mv	s6,a1
    800049d2:	8a32                	mv	s4,a2
    return -1;

  if(f->type == FD_PIPE){
    800049d4:	411c                	lw	a5,0(a0)
    800049d6:	4705                	li	a4,1
    800049d8:	02e78263          	beq	a5,a4,800049fc <filewrite+0x4e>
    ret = pipewrite(f->pipe, addr, n);
  } else if(f->type == FD_DEVICE){
    800049dc:	470d                	li	a4,3
    800049de:	02e78663          	beq	a5,a4,80004a0a <filewrite+0x5c>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
      return -1;
    ret = devsw[f->major].write(1, addr, n);
  } else if(f->type == FD_INODE){
    800049e2:	4709                	li	a4,2
    800049e4:	0ee79163          	bne	a5,a4,80004ac6 <filewrite+0x118>
    // and 2 blocks of slop for non-aligned writes.
    // this really belongs lower down, since writei()
    // might be writing a device like the console.
    int max = ((MAXOPBLOCKS-1-1-2) / 2) * BSIZE;
    int i = 0;
    while(i < n){
    800049e8:	0ac05d63          	blez	a2,80004aa2 <filewrite+0xf4>
    int i = 0;
    800049ec:	4981                	li	s3,0
    800049ee:	6b85                	lui	s7,0x1
    800049f0:	c00b8b93          	addi	s7,s7,-1024 # c00 <_entry-0x7ffff400>
    800049f4:	6c05                	lui	s8,0x1
    800049f6:	c00c0c1b          	addiw	s8,s8,-1024 # c00 <_entry-0x7ffff400>
    800049fa:	a861                	j	80004a92 <filewrite+0xe4>
    ret = pipewrite(f->pipe, addr, n);
    800049fc:	6908                	ld	a0,16(a0)
    800049fe:	00000097          	auipc	ra,0x0
    80004a02:	22e080e7          	jalr	558(ra) # 80004c2c <pipewrite>
    80004a06:	8a2a                	mv	s4,a0
    80004a08:	a045                	j	80004aa8 <filewrite+0xfa>
    if(f->major < 0 || f->major >= NDEV || !devsw[f->major].write)
    80004a0a:	02451783          	lh	a5,36(a0)
    80004a0e:	03079693          	slli	a3,a5,0x30
    80004a12:	92c1                	srli	a3,a3,0x30
    80004a14:	4725                	li	a4,9
    80004a16:	0cd76263          	bltu	a4,a3,80004ada <filewrite+0x12c>
    80004a1a:	0792                	slli	a5,a5,0x4
    80004a1c:	0001c717          	auipc	a4,0x1c
    80004a20:	22c70713          	addi	a4,a4,556 # 80020c48 <devsw>
    80004a24:	97ba                	add	a5,a5,a4
    80004a26:	679c                	ld	a5,8(a5)
    80004a28:	cbdd                	beqz	a5,80004ade <filewrite+0x130>
    ret = devsw[f->major].write(1, addr, n);
    80004a2a:	4505                	li	a0,1
    80004a2c:	9782                	jalr	a5
    80004a2e:	8a2a                	mv	s4,a0
    80004a30:	a8a5                	j	80004aa8 <filewrite+0xfa>
    80004a32:	00048a9b          	sext.w	s5,s1
      int n1 = n - i;
      if(n1 > max)
        n1 = max;

      begin_op();
    80004a36:	00000097          	auipc	ra,0x0
    80004a3a:	8b4080e7          	jalr	-1868(ra) # 800042ea <begin_op>
      ilock(f->ip);
    80004a3e:	01893503          	ld	a0,24(s2)
    80004a42:	fffff097          	auipc	ra,0xfffff
    80004a46:	edc080e7          	jalr	-292(ra) # 8000391e <ilock>
      if ((r = writei(f->ip, 1, addr + i, f->off, n1)) > 0)
    80004a4a:	8756                	mv	a4,s5
    80004a4c:	02092683          	lw	a3,32(s2)
    80004a50:	01698633          	add	a2,s3,s6
    80004a54:	4585                	li	a1,1
    80004a56:	01893503          	ld	a0,24(s2)
    80004a5a:	fffff097          	auipc	ra,0xfffff
    80004a5e:	270080e7          	jalr	624(ra) # 80003cca <writei>
    80004a62:	84aa                	mv	s1,a0
    80004a64:	00a05763          	blez	a0,80004a72 <filewrite+0xc4>
        f->off += r;
    80004a68:	02092783          	lw	a5,32(s2)
    80004a6c:	9fa9                	addw	a5,a5,a0
    80004a6e:	02f92023          	sw	a5,32(s2)
      iunlock(f->ip);
    80004a72:	01893503          	ld	a0,24(s2)
    80004a76:	fffff097          	auipc	ra,0xfffff
    80004a7a:	f6a080e7          	jalr	-150(ra) # 800039e0 <iunlock>
      end_op();
    80004a7e:	00000097          	auipc	ra,0x0
    80004a82:	8ea080e7          	jalr	-1814(ra) # 80004368 <end_op>

      if(r != n1){
    80004a86:	009a9f63          	bne	s5,s1,80004aa4 <filewrite+0xf6>
        // error from writei
        break;
      }
      i += r;
    80004a8a:	013489bb          	addw	s3,s1,s3
    while(i < n){
    80004a8e:	0149db63          	bge	s3,s4,80004aa4 <filewrite+0xf6>
      int n1 = n - i;
    80004a92:	413a04bb          	subw	s1,s4,s3
    80004a96:	0004879b          	sext.w	a5,s1
    80004a9a:	f8fbdce3          	bge	s7,a5,80004a32 <filewrite+0x84>
    80004a9e:	84e2                	mv	s1,s8
    80004aa0:	bf49                	j	80004a32 <filewrite+0x84>
    int i = 0;
    80004aa2:	4981                	li	s3,0
    }
    ret = (i == n ? n : -1);
    80004aa4:	013a1f63          	bne	s4,s3,80004ac2 <filewrite+0x114>
  } else {
    panic("filewrite");
  }

  return ret;
}
    80004aa8:	8552                	mv	a0,s4
    80004aaa:	60a6                	ld	ra,72(sp)
    80004aac:	6406                	ld	s0,64(sp)
    80004aae:	74e2                	ld	s1,56(sp)
    80004ab0:	7942                	ld	s2,48(sp)
    80004ab2:	79a2                	ld	s3,40(sp)
    80004ab4:	7a02                	ld	s4,32(sp)
    80004ab6:	6ae2                	ld	s5,24(sp)
    80004ab8:	6b42                	ld	s6,16(sp)
    80004aba:	6ba2                	ld	s7,8(sp)
    80004abc:	6c02                	ld	s8,0(sp)
    80004abe:	6161                	addi	sp,sp,80
    80004ac0:	8082                	ret
    ret = (i == n ? n : -1);
    80004ac2:	5a7d                	li	s4,-1
    80004ac4:	b7d5                	j	80004aa8 <filewrite+0xfa>
    panic("filewrite");
    80004ac6:	00004517          	auipc	a0,0x4
    80004aca:	c6a50513          	addi	a0,a0,-918 # 80008730 <syscalls+0x280>
    80004ace:	ffffc097          	auipc	ra,0xffffc
    80004ad2:	a72080e7          	jalr	-1422(ra) # 80000540 <panic>
    return -1;
    80004ad6:	5a7d                	li	s4,-1
    80004ad8:	bfc1                	j	80004aa8 <filewrite+0xfa>
      return -1;
    80004ada:	5a7d                	li	s4,-1
    80004adc:	b7f1                	j	80004aa8 <filewrite+0xfa>
    80004ade:	5a7d                	li	s4,-1
    80004ae0:	b7e1                	j	80004aa8 <filewrite+0xfa>

0000000080004ae2 <pipealloc>:
  int writeopen;  // write fd is still open
};

int
pipealloc(struct file **f0, struct file **f1)
{
    80004ae2:	7179                	addi	sp,sp,-48
    80004ae4:	f406                	sd	ra,40(sp)
    80004ae6:	f022                	sd	s0,32(sp)
    80004ae8:	ec26                	sd	s1,24(sp)
    80004aea:	e84a                	sd	s2,16(sp)
    80004aec:	e44e                	sd	s3,8(sp)
    80004aee:	e052                	sd	s4,0(sp)
    80004af0:	1800                	addi	s0,sp,48
    80004af2:	84aa                	mv	s1,a0
    80004af4:	8a2e                	mv	s4,a1
  struct pipe *pi;

  pi = 0;
  *f0 = *f1 = 0;
    80004af6:	0005b023          	sd	zero,0(a1)
    80004afa:	00053023          	sd	zero,0(a0)
  if((*f0 = filealloc()) == 0 || (*f1 = filealloc()) == 0)
    80004afe:	00000097          	auipc	ra,0x0
    80004b02:	bf8080e7          	jalr	-1032(ra) # 800046f6 <filealloc>
    80004b06:	e088                	sd	a0,0(s1)
    80004b08:	c551                	beqz	a0,80004b94 <pipealloc+0xb2>
    80004b0a:	00000097          	auipc	ra,0x0
    80004b0e:	bec080e7          	jalr	-1044(ra) # 800046f6 <filealloc>
    80004b12:	00aa3023          	sd	a0,0(s4)
    80004b16:	c92d                	beqz	a0,80004b88 <pipealloc+0xa6>
    goto bad;
  if((pi = (struct pipe*)kalloc()) == 0)
    80004b18:	ffffc097          	auipc	ra,0xffffc
    80004b1c:	fce080e7          	jalr	-50(ra) # 80000ae6 <kalloc>
    80004b20:	892a                	mv	s2,a0
    80004b22:	c125                	beqz	a0,80004b82 <pipealloc+0xa0>
    goto bad;
  pi->readopen = 1;
    80004b24:	4985                	li	s3,1
    80004b26:	23352023          	sw	s3,544(a0)
  pi->writeopen = 1;
    80004b2a:	23352223          	sw	s3,548(a0)
  pi->nwrite = 0;
    80004b2e:	20052e23          	sw	zero,540(a0)
  pi->nread = 0;
    80004b32:	20052c23          	sw	zero,536(a0)
  initlock(&pi->lock, "pipe");
    80004b36:	00004597          	auipc	a1,0x4
    80004b3a:	c0a58593          	addi	a1,a1,-1014 # 80008740 <syscalls+0x290>
    80004b3e:	ffffc097          	auipc	ra,0xffffc
    80004b42:	008080e7          	jalr	8(ra) # 80000b46 <initlock>
  (*f0)->type = FD_PIPE;
    80004b46:	609c                	ld	a5,0(s1)
    80004b48:	0137a023          	sw	s3,0(a5)
  (*f0)->readable = 1;
    80004b4c:	609c                	ld	a5,0(s1)
    80004b4e:	01378423          	sb	s3,8(a5)
  (*f0)->writable = 0;
    80004b52:	609c                	ld	a5,0(s1)
    80004b54:	000784a3          	sb	zero,9(a5)
  (*f0)->pipe = pi;
    80004b58:	609c                	ld	a5,0(s1)
    80004b5a:	0127b823          	sd	s2,16(a5)
  (*f1)->type = FD_PIPE;
    80004b5e:	000a3783          	ld	a5,0(s4)
    80004b62:	0137a023          	sw	s3,0(a5)
  (*f1)->readable = 0;
    80004b66:	000a3783          	ld	a5,0(s4)
    80004b6a:	00078423          	sb	zero,8(a5)
  (*f1)->writable = 1;
    80004b6e:	000a3783          	ld	a5,0(s4)
    80004b72:	013784a3          	sb	s3,9(a5)
  (*f1)->pipe = pi;
    80004b76:	000a3783          	ld	a5,0(s4)
    80004b7a:	0127b823          	sd	s2,16(a5)
  return 0;
    80004b7e:	4501                	li	a0,0
    80004b80:	a025                	j	80004ba8 <pipealloc+0xc6>

 bad:
  if(pi)
    kfree((char*)pi);
  if(*f0)
    80004b82:	6088                	ld	a0,0(s1)
    80004b84:	e501                	bnez	a0,80004b8c <pipealloc+0xaa>
    80004b86:	a039                	j	80004b94 <pipealloc+0xb2>
    80004b88:	6088                	ld	a0,0(s1)
    80004b8a:	c51d                	beqz	a0,80004bb8 <pipealloc+0xd6>
    fileclose(*f0);
    80004b8c:	00000097          	auipc	ra,0x0
    80004b90:	c26080e7          	jalr	-986(ra) # 800047b2 <fileclose>
  if(*f1)
    80004b94:	000a3783          	ld	a5,0(s4)
    fileclose(*f1);
  return -1;
    80004b98:	557d                	li	a0,-1
  if(*f1)
    80004b9a:	c799                	beqz	a5,80004ba8 <pipealloc+0xc6>
    fileclose(*f1);
    80004b9c:	853e                	mv	a0,a5
    80004b9e:	00000097          	auipc	ra,0x0
    80004ba2:	c14080e7          	jalr	-1004(ra) # 800047b2 <fileclose>
  return -1;
    80004ba6:	557d                	li	a0,-1
}
    80004ba8:	70a2                	ld	ra,40(sp)
    80004baa:	7402                	ld	s0,32(sp)
    80004bac:	64e2                	ld	s1,24(sp)
    80004bae:	6942                	ld	s2,16(sp)
    80004bb0:	69a2                	ld	s3,8(sp)
    80004bb2:	6a02                	ld	s4,0(sp)
    80004bb4:	6145                	addi	sp,sp,48
    80004bb6:	8082                	ret
  return -1;
    80004bb8:	557d                	li	a0,-1
    80004bba:	b7fd                	j	80004ba8 <pipealloc+0xc6>

0000000080004bbc <pipeclose>:

void
pipeclose(struct pipe *pi, int writable)
{
    80004bbc:	1101                	addi	sp,sp,-32
    80004bbe:	ec06                	sd	ra,24(sp)
    80004bc0:	e822                	sd	s0,16(sp)
    80004bc2:	e426                	sd	s1,8(sp)
    80004bc4:	e04a                	sd	s2,0(sp)
    80004bc6:	1000                	addi	s0,sp,32
    80004bc8:	84aa                	mv	s1,a0
    80004bca:	892e                	mv	s2,a1
  acquire(&pi->lock);
    80004bcc:	ffffc097          	auipc	ra,0xffffc
    80004bd0:	00a080e7          	jalr	10(ra) # 80000bd6 <acquire>
  if(writable){
    80004bd4:	02090d63          	beqz	s2,80004c0e <pipeclose+0x52>
    pi->writeopen = 0;
    80004bd8:	2204a223          	sw	zero,548(s1)
    wakeup(&pi->nread);
    80004bdc:	21848513          	addi	a0,s1,536
    80004be0:	ffffd097          	auipc	ra,0xffffd
    80004be4:	626080e7          	jalr	1574(ra) # 80002206 <wakeup>
  } else {
    pi->readopen = 0;
    wakeup(&pi->nwrite);
  }
  if(pi->readopen == 0 && pi->writeopen == 0){
    80004be8:	2204b783          	ld	a5,544(s1)
    80004bec:	eb95                	bnez	a5,80004c20 <pipeclose+0x64>
    release(&pi->lock);
    80004bee:	8526                	mv	a0,s1
    80004bf0:	ffffc097          	auipc	ra,0xffffc
    80004bf4:	09a080e7          	jalr	154(ra) # 80000c8a <release>
    kfree((char*)pi);
    80004bf8:	8526                	mv	a0,s1
    80004bfa:	ffffc097          	auipc	ra,0xffffc
    80004bfe:	dee080e7          	jalr	-530(ra) # 800009e8 <kfree>
  } else
    release(&pi->lock);
}
    80004c02:	60e2                	ld	ra,24(sp)
    80004c04:	6442                	ld	s0,16(sp)
    80004c06:	64a2                	ld	s1,8(sp)
    80004c08:	6902                	ld	s2,0(sp)
    80004c0a:	6105                	addi	sp,sp,32
    80004c0c:	8082                	ret
    pi->readopen = 0;
    80004c0e:	2204a023          	sw	zero,544(s1)
    wakeup(&pi->nwrite);
    80004c12:	21c48513          	addi	a0,s1,540
    80004c16:	ffffd097          	auipc	ra,0xffffd
    80004c1a:	5f0080e7          	jalr	1520(ra) # 80002206 <wakeup>
    80004c1e:	b7e9                	j	80004be8 <pipeclose+0x2c>
    release(&pi->lock);
    80004c20:	8526                	mv	a0,s1
    80004c22:	ffffc097          	auipc	ra,0xffffc
    80004c26:	068080e7          	jalr	104(ra) # 80000c8a <release>
}
    80004c2a:	bfe1                	j	80004c02 <pipeclose+0x46>

0000000080004c2c <pipewrite>:

int
pipewrite(struct pipe *pi, uint64 addr, int n)
{
    80004c2c:	711d                	addi	sp,sp,-96
    80004c2e:	ec86                	sd	ra,88(sp)
    80004c30:	e8a2                	sd	s0,80(sp)
    80004c32:	e4a6                	sd	s1,72(sp)
    80004c34:	e0ca                	sd	s2,64(sp)
    80004c36:	fc4e                	sd	s3,56(sp)
    80004c38:	f852                	sd	s4,48(sp)
    80004c3a:	f456                	sd	s5,40(sp)
    80004c3c:	f05a                	sd	s6,32(sp)
    80004c3e:	ec5e                	sd	s7,24(sp)
    80004c40:	e862                	sd	s8,16(sp)
    80004c42:	1080                	addi	s0,sp,96
    80004c44:	84aa                	mv	s1,a0
    80004c46:	8aae                	mv	s5,a1
    80004c48:	8a32                	mv	s4,a2
  int i = 0;
  struct proc *pr = myproc();
    80004c4a:	ffffd097          	auipc	ra,0xffffd
    80004c4e:	eb0080e7          	jalr	-336(ra) # 80001afa <myproc>
    80004c52:	89aa                	mv	s3,a0

  acquire(&pi->lock);
    80004c54:	8526                	mv	a0,s1
    80004c56:	ffffc097          	auipc	ra,0xffffc
    80004c5a:	f80080e7          	jalr	-128(ra) # 80000bd6 <acquire>
  while(i < n){
    80004c5e:	0b405663          	blez	s4,80004d0a <pipewrite+0xde>
  int i = 0;
    80004c62:	4901                	li	s2,0
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
      wakeup(&pi->nread);
      sleep(&pi->nwrite, &pi->lock);
    } else {
      char ch;
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004c64:	5b7d                	li	s6,-1
      wakeup(&pi->nread);
    80004c66:	21848c13          	addi	s8,s1,536
      sleep(&pi->nwrite, &pi->lock);
    80004c6a:	21c48b93          	addi	s7,s1,540
    80004c6e:	a089                	j	80004cb0 <pipewrite+0x84>
      release(&pi->lock);
    80004c70:	8526                	mv	a0,s1
    80004c72:	ffffc097          	auipc	ra,0xffffc
    80004c76:	018080e7          	jalr	24(ra) # 80000c8a <release>
      return -1;
    80004c7a:	597d                	li	s2,-1
  }
  wakeup(&pi->nread);
  release(&pi->lock);

  return i;
}
    80004c7c:	854a                	mv	a0,s2
    80004c7e:	60e6                	ld	ra,88(sp)
    80004c80:	6446                	ld	s0,80(sp)
    80004c82:	64a6                	ld	s1,72(sp)
    80004c84:	6906                	ld	s2,64(sp)
    80004c86:	79e2                	ld	s3,56(sp)
    80004c88:	7a42                	ld	s4,48(sp)
    80004c8a:	7aa2                	ld	s5,40(sp)
    80004c8c:	7b02                	ld	s6,32(sp)
    80004c8e:	6be2                	ld	s7,24(sp)
    80004c90:	6c42                	ld	s8,16(sp)
    80004c92:	6125                	addi	sp,sp,96
    80004c94:	8082                	ret
      wakeup(&pi->nread);
    80004c96:	8562                	mv	a0,s8
    80004c98:	ffffd097          	auipc	ra,0xffffd
    80004c9c:	56e080e7          	jalr	1390(ra) # 80002206 <wakeup>
      sleep(&pi->nwrite, &pi->lock);
    80004ca0:	85a6                	mv	a1,s1
    80004ca2:	855e                	mv	a0,s7
    80004ca4:	ffffd097          	auipc	ra,0xffffd
    80004ca8:	4fe080e7          	jalr	1278(ra) # 800021a2 <sleep>
  while(i < n){
    80004cac:	07495063          	bge	s2,s4,80004d0c <pipewrite+0xe0>
    if(pi->readopen == 0 || killed(pr)){
    80004cb0:	2204a783          	lw	a5,544(s1)
    80004cb4:	dfd5                	beqz	a5,80004c70 <pipewrite+0x44>
    80004cb6:	854e                	mv	a0,s3
    80004cb8:	ffffd097          	auipc	ra,0xffffd
    80004cbc:	792080e7          	jalr	1938(ra) # 8000244a <killed>
    80004cc0:	f945                	bnez	a0,80004c70 <pipewrite+0x44>
    if(pi->nwrite == pi->nread + PIPESIZE){ //DOC: pipewrite-full
    80004cc2:	2184a783          	lw	a5,536(s1)
    80004cc6:	21c4a703          	lw	a4,540(s1)
    80004cca:	2007879b          	addiw	a5,a5,512
    80004cce:	fcf704e3          	beq	a4,a5,80004c96 <pipewrite+0x6a>
      if(copyin(pr->pagetable, &ch, addr + i, 1) == -1)
    80004cd2:	4685                	li	a3,1
    80004cd4:	01590633          	add	a2,s2,s5
    80004cd8:	faf40593          	addi	a1,s0,-81
    80004cdc:	0509b503          	ld	a0,80(s3)
    80004ce0:	ffffd097          	auipc	ra,0xffffd
    80004ce4:	a18080e7          	jalr	-1512(ra) # 800016f8 <copyin>
    80004ce8:	03650263          	beq	a0,s6,80004d0c <pipewrite+0xe0>
      pi->data[pi->nwrite++ % PIPESIZE] = ch;
    80004cec:	21c4a783          	lw	a5,540(s1)
    80004cf0:	0017871b          	addiw	a4,a5,1
    80004cf4:	20e4ae23          	sw	a4,540(s1)
    80004cf8:	1ff7f793          	andi	a5,a5,511
    80004cfc:	97a6                	add	a5,a5,s1
    80004cfe:	faf44703          	lbu	a4,-81(s0)
    80004d02:	00e78c23          	sb	a4,24(a5)
      i++;
    80004d06:	2905                	addiw	s2,s2,1
    80004d08:	b755                	j	80004cac <pipewrite+0x80>
  int i = 0;
    80004d0a:	4901                	li	s2,0
  wakeup(&pi->nread);
    80004d0c:	21848513          	addi	a0,s1,536
    80004d10:	ffffd097          	auipc	ra,0xffffd
    80004d14:	4f6080e7          	jalr	1270(ra) # 80002206 <wakeup>
  release(&pi->lock);
    80004d18:	8526                	mv	a0,s1
    80004d1a:	ffffc097          	auipc	ra,0xffffc
    80004d1e:	f70080e7          	jalr	-144(ra) # 80000c8a <release>
  return i;
    80004d22:	bfa9                	j	80004c7c <pipewrite+0x50>

0000000080004d24 <piperead>:

int
piperead(struct pipe *pi, uint64 addr, int n)
{
    80004d24:	715d                	addi	sp,sp,-80
    80004d26:	e486                	sd	ra,72(sp)
    80004d28:	e0a2                	sd	s0,64(sp)
    80004d2a:	fc26                	sd	s1,56(sp)
    80004d2c:	f84a                	sd	s2,48(sp)
    80004d2e:	f44e                	sd	s3,40(sp)
    80004d30:	f052                	sd	s4,32(sp)
    80004d32:	ec56                	sd	s5,24(sp)
    80004d34:	e85a                	sd	s6,16(sp)
    80004d36:	0880                	addi	s0,sp,80
    80004d38:	84aa                	mv	s1,a0
    80004d3a:	892e                	mv	s2,a1
    80004d3c:	8ab2                	mv	s5,a2
  int i;
  struct proc *pr = myproc();
    80004d3e:	ffffd097          	auipc	ra,0xffffd
    80004d42:	dbc080e7          	jalr	-580(ra) # 80001afa <myproc>
    80004d46:	8a2a                	mv	s4,a0
  char ch;

  acquire(&pi->lock);
    80004d48:	8526                	mv	a0,s1
    80004d4a:	ffffc097          	auipc	ra,0xffffc
    80004d4e:	e8c080e7          	jalr	-372(ra) # 80000bd6 <acquire>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d52:	2184a703          	lw	a4,536(s1)
    80004d56:	21c4a783          	lw	a5,540(s1)
    if(killed(pr)){
      release(&pi->lock);
      return -1;
    }
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d5a:	21848993          	addi	s3,s1,536
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d5e:	02f71763          	bne	a4,a5,80004d8c <piperead+0x68>
    80004d62:	2244a783          	lw	a5,548(s1)
    80004d66:	c39d                	beqz	a5,80004d8c <piperead+0x68>
    if(killed(pr)){
    80004d68:	8552                	mv	a0,s4
    80004d6a:	ffffd097          	auipc	ra,0xffffd
    80004d6e:	6e0080e7          	jalr	1760(ra) # 8000244a <killed>
    80004d72:	e949                	bnez	a0,80004e04 <piperead+0xe0>
    sleep(&pi->nread, &pi->lock); //DOC: piperead-sleep
    80004d74:	85a6                	mv	a1,s1
    80004d76:	854e                	mv	a0,s3
    80004d78:	ffffd097          	auipc	ra,0xffffd
    80004d7c:	42a080e7          	jalr	1066(ra) # 800021a2 <sleep>
  while(pi->nread == pi->nwrite && pi->writeopen){  //DOC: pipe-empty
    80004d80:	2184a703          	lw	a4,536(s1)
    80004d84:	21c4a783          	lw	a5,540(s1)
    80004d88:	fcf70de3          	beq	a4,a5,80004d62 <piperead+0x3e>
  }
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d8c:	4981                	li	s3,0
    if(pi->nread == pi->nwrite)
      break;
    ch = pi->data[pi->nread++ % PIPESIZE];
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004d8e:	5b7d                	li	s6,-1
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004d90:	05505463          	blez	s5,80004dd8 <piperead+0xb4>
    if(pi->nread == pi->nwrite)
    80004d94:	2184a783          	lw	a5,536(s1)
    80004d98:	21c4a703          	lw	a4,540(s1)
    80004d9c:	02f70e63          	beq	a4,a5,80004dd8 <piperead+0xb4>
    ch = pi->data[pi->nread++ % PIPESIZE];
    80004da0:	0017871b          	addiw	a4,a5,1
    80004da4:	20e4ac23          	sw	a4,536(s1)
    80004da8:	1ff7f793          	andi	a5,a5,511
    80004dac:	97a6                	add	a5,a5,s1
    80004dae:	0187c783          	lbu	a5,24(a5)
    80004db2:	faf40fa3          	sb	a5,-65(s0)
    if(copyout(pr->pagetable, addr + i, &ch, 1) == -1)
    80004db6:	4685                	li	a3,1
    80004db8:	fbf40613          	addi	a2,s0,-65
    80004dbc:	85ca                	mv	a1,s2
    80004dbe:	050a3503          	ld	a0,80(s4)
    80004dc2:	ffffd097          	auipc	ra,0xffffd
    80004dc6:	8aa080e7          	jalr	-1878(ra) # 8000166c <copyout>
    80004dca:	01650763          	beq	a0,s6,80004dd8 <piperead+0xb4>
  for(i = 0; i < n; i++){  //DOC: piperead-copy
    80004dce:	2985                	addiw	s3,s3,1
    80004dd0:	0905                	addi	s2,s2,1
    80004dd2:	fd3a91e3          	bne	s5,s3,80004d94 <piperead+0x70>
    80004dd6:	89d6                	mv	s3,s5
      break;
  }
  wakeup(&pi->nwrite);  //DOC: piperead-wakeup
    80004dd8:	21c48513          	addi	a0,s1,540
    80004ddc:	ffffd097          	auipc	ra,0xffffd
    80004de0:	42a080e7          	jalr	1066(ra) # 80002206 <wakeup>
  release(&pi->lock);
    80004de4:	8526                	mv	a0,s1
    80004de6:	ffffc097          	auipc	ra,0xffffc
    80004dea:	ea4080e7          	jalr	-348(ra) # 80000c8a <release>
  return i;
}
    80004dee:	854e                	mv	a0,s3
    80004df0:	60a6                	ld	ra,72(sp)
    80004df2:	6406                	ld	s0,64(sp)
    80004df4:	74e2                	ld	s1,56(sp)
    80004df6:	7942                	ld	s2,48(sp)
    80004df8:	79a2                	ld	s3,40(sp)
    80004dfa:	7a02                	ld	s4,32(sp)
    80004dfc:	6ae2                	ld	s5,24(sp)
    80004dfe:	6b42                	ld	s6,16(sp)
    80004e00:	6161                	addi	sp,sp,80
    80004e02:	8082                	ret
      release(&pi->lock);
    80004e04:	8526                	mv	a0,s1
    80004e06:	ffffc097          	auipc	ra,0xffffc
    80004e0a:	e84080e7          	jalr	-380(ra) # 80000c8a <release>
      return -1;
    80004e0e:	59fd                	li	s3,-1
    80004e10:	bff9                	j	80004dee <piperead+0xca>

0000000080004e12 <flags2perm>:
#include "elf.h"

static int loadseg(pde_t *, uint64, struct inode *, uint, uint);

int flags2perm(int flags)
{
    80004e12:	1141                	addi	sp,sp,-16
    80004e14:	e422                	sd	s0,8(sp)
    80004e16:	0800                	addi	s0,sp,16
    80004e18:	87aa                	mv	a5,a0
    int perm = 0;
    if(flags & 0x1)
    80004e1a:	8905                	andi	a0,a0,1
    80004e1c:	050e                	slli	a0,a0,0x3
      perm = PTE_X;
    if(flags & 0x2)
    80004e1e:	8b89                	andi	a5,a5,2
    80004e20:	c399                	beqz	a5,80004e26 <flags2perm+0x14>
      perm |= PTE_W;
    80004e22:	00456513          	ori	a0,a0,4
    return perm;
}
    80004e26:	6422                	ld	s0,8(sp)
    80004e28:	0141                	addi	sp,sp,16
    80004e2a:	8082                	ret

0000000080004e2c <exec>:

int
exec(char *path, char **argv)
{
    80004e2c:	de010113          	addi	sp,sp,-544
    80004e30:	20113c23          	sd	ra,536(sp)
    80004e34:	20813823          	sd	s0,528(sp)
    80004e38:	20913423          	sd	s1,520(sp)
    80004e3c:	21213023          	sd	s2,512(sp)
    80004e40:	ffce                	sd	s3,504(sp)
    80004e42:	fbd2                	sd	s4,496(sp)
    80004e44:	f7d6                	sd	s5,488(sp)
    80004e46:	f3da                	sd	s6,480(sp)
    80004e48:	efde                	sd	s7,472(sp)
    80004e4a:	ebe2                	sd	s8,464(sp)
    80004e4c:	e7e6                	sd	s9,456(sp)
    80004e4e:	e3ea                	sd	s10,448(sp)
    80004e50:	ff6e                	sd	s11,440(sp)
    80004e52:	1400                	addi	s0,sp,544
    80004e54:	892a                	mv	s2,a0
    80004e56:	dea43423          	sd	a0,-536(s0)
    80004e5a:	deb43823          	sd	a1,-528(s0)
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
  struct elfhdr elf;
  struct inode *ip;
  struct proghdr ph;
  pagetable_t pagetable = 0, oldpagetable;
  struct proc *p = myproc();
    80004e5e:	ffffd097          	auipc	ra,0xffffd
    80004e62:	c9c080e7          	jalr	-868(ra) # 80001afa <myproc>
    80004e66:	84aa                	mv	s1,a0

  begin_op();
    80004e68:	fffff097          	auipc	ra,0xfffff
    80004e6c:	482080e7          	jalr	1154(ra) # 800042ea <begin_op>

  if((ip = namei(path)) == 0){
    80004e70:	854a                	mv	a0,s2
    80004e72:	fffff097          	auipc	ra,0xfffff
    80004e76:	258080e7          	jalr	600(ra) # 800040ca <namei>
    80004e7a:	c93d                	beqz	a0,80004ef0 <exec+0xc4>
    80004e7c:	8aaa                	mv	s5,a0
    end_op();
    return -1;
  }
  ilock(ip);
    80004e7e:	fffff097          	auipc	ra,0xfffff
    80004e82:	aa0080e7          	jalr	-1376(ra) # 8000391e <ilock>

  // Check ELF header
  if(readi(ip, 0, (uint64)&elf, 0, sizeof(elf)) != sizeof(elf))
    80004e86:	04000713          	li	a4,64
    80004e8a:	4681                	li	a3,0
    80004e8c:	e5040613          	addi	a2,s0,-432
    80004e90:	4581                	li	a1,0
    80004e92:	8556                	mv	a0,s5
    80004e94:	fffff097          	auipc	ra,0xfffff
    80004e98:	d3e080e7          	jalr	-706(ra) # 80003bd2 <readi>
    80004e9c:	04000793          	li	a5,64
    80004ea0:	00f51a63          	bne	a0,a5,80004eb4 <exec+0x88>
    goto bad;

  if(elf.magic != ELF_MAGIC)
    80004ea4:	e5042703          	lw	a4,-432(s0)
    80004ea8:	464c47b7          	lui	a5,0x464c4
    80004eac:	57f78793          	addi	a5,a5,1407 # 464c457f <_entry-0x39b3ba81>
    80004eb0:	04f70663          	beq	a4,a5,80004efc <exec+0xd0>

 bad:
  if(pagetable)
    proc_freepagetable(pagetable, sz);
  if(ip){
    iunlockput(ip);
    80004eb4:	8556                	mv	a0,s5
    80004eb6:	fffff097          	auipc	ra,0xfffff
    80004eba:	cca080e7          	jalr	-822(ra) # 80003b80 <iunlockput>
    end_op();
    80004ebe:	fffff097          	auipc	ra,0xfffff
    80004ec2:	4aa080e7          	jalr	1194(ra) # 80004368 <end_op>
  }
  return -1;
    80004ec6:	557d                	li	a0,-1
}
    80004ec8:	21813083          	ld	ra,536(sp)
    80004ecc:	21013403          	ld	s0,528(sp)
    80004ed0:	20813483          	ld	s1,520(sp)
    80004ed4:	20013903          	ld	s2,512(sp)
    80004ed8:	79fe                	ld	s3,504(sp)
    80004eda:	7a5e                	ld	s4,496(sp)
    80004edc:	7abe                	ld	s5,488(sp)
    80004ede:	7b1e                	ld	s6,480(sp)
    80004ee0:	6bfe                	ld	s7,472(sp)
    80004ee2:	6c5e                	ld	s8,464(sp)
    80004ee4:	6cbe                	ld	s9,456(sp)
    80004ee6:	6d1e                	ld	s10,448(sp)
    80004ee8:	7dfa                	ld	s11,440(sp)
    80004eea:	22010113          	addi	sp,sp,544
    80004eee:	8082                	ret
    end_op();
    80004ef0:	fffff097          	auipc	ra,0xfffff
    80004ef4:	478080e7          	jalr	1144(ra) # 80004368 <end_op>
    return -1;
    80004ef8:	557d                	li	a0,-1
    80004efa:	b7f9                	j	80004ec8 <exec+0x9c>
  if((pagetable = proc_pagetable(p)) == 0)
    80004efc:	8526                	mv	a0,s1
    80004efe:	ffffd097          	auipc	ra,0xffffd
    80004f02:	cc0080e7          	jalr	-832(ra) # 80001bbe <proc_pagetable>
    80004f06:	8b2a                	mv	s6,a0
    80004f08:	d555                	beqz	a0,80004eb4 <exec+0x88>
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f0a:	e7042783          	lw	a5,-400(s0)
    80004f0e:	e8845703          	lhu	a4,-376(s0)
    80004f12:	c735                	beqz	a4,80004f7e <exec+0x152>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f14:	4901                	li	s2,0
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    80004f16:	e0043423          	sd	zero,-504(s0)
    if(ph.vaddr % PGSIZE != 0)
    80004f1a:	6a05                	lui	s4,0x1
    80004f1c:	fffa0713          	addi	a4,s4,-1 # fff <_entry-0x7ffff001>
    80004f20:	dee43023          	sd	a4,-544(s0)
loadseg(pagetable_t pagetable, uint64 va, struct inode *ip, uint offset, uint sz)
{
  uint i, n;
  uint64 pa;

  for(i = 0; i < sz; i += PGSIZE){
    80004f24:	6d85                	lui	s11,0x1
    80004f26:	7d7d                	lui	s10,0xfffff
    80004f28:	ac3d                	j	80005166 <exec+0x33a>
    pa = walkaddr(pagetable, va + i);
    if(pa == 0)
      panic("loadseg: address should exist");
    80004f2a:	00004517          	auipc	a0,0x4
    80004f2e:	81e50513          	addi	a0,a0,-2018 # 80008748 <syscalls+0x298>
    80004f32:	ffffb097          	auipc	ra,0xffffb
    80004f36:	60e080e7          	jalr	1550(ra) # 80000540 <panic>
    if(sz - i < PGSIZE)
      n = sz - i;
    else
      n = PGSIZE;
    if(readi(ip, 0, (uint64)pa, offset+i, n) != n)
    80004f3a:	874a                	mv	a4,s2
    80004f3c:	009c86bb          	addw	a3,s9,s1
    80004f40:	4581                	li	a1,0
    80004f42:	8556                	mv	a0,s5
    80004f44:	fffff097          	auipc	ra,0xfffff
    80004f48:	c8e080e7          	jalr	-882(ra) # 80003bd2 <readi>
    80004f4c:	2501                	sext.w	a0,a0
    80004f4e:	1aa91963          	bne	s2,a0,80005100 <exec+0x2d4>
  for(i = 0; i < sz; i += PGSIZE){
    80004f52:	009d84bb          	addw	s1,s11,s1
    80004f56:	013d09bb          	addw	s3,s10,s3
    80004f5a:	1f74f663          	bgeu	s1,s7,80005146 <exec+0x31a>
    pa = walkaddr(pagetable, va + i);
    80004f5e:	02049593          	slli	a1,s1,0x20
    80004f62:	9181                	srli	a1,a1,0x20
    80004f64:	95e2                	add	a1,a1,s8
    80004f66:	855a                	mv	a0,s6
    80004f68:	ffffc097          	auipc	ra,0xffffc
    80004f6c:	0f4080e7          	jalr	244(ra) # 8000105c <walkaddr>
    80004f70:	862a                	mv	a2,a0
    if(pa == 0)
    80004f72:	dd45                	beqz	a0,80004f2a <exec+0xfe>
      n = PGSIZE;
    80004f74:	8952                	mv	s2,s4
    if(sz - i < PGSIZE)
    80004f76:	fd49f2e3          	bgeu	s3,s4,80004f3a <exec+0x10e>
      n = sz - i;
    80004f7a:	894e                	mv	s2,s3
    80004f7c:	bf7d                	j	80004f3a <exec+0x10e>
  uint64 argc, sz = 0, sp, ustack[MAXARG], stackbase;
    80004f7e:	4901                	li	s2,0
  iunlockput(ip);
    80004f80:	8556                	mv	a0,s5
    80004f82:	fffff097          	auipc	ra,0xfffff
    80004f86:	bfe080e7          	jalr	-1026(ra) # 80003b80 <iunlockput>
  end_op();
    80004f8a:	fffff097          	auipc	ra,0xfffff
    80004f8e:	3de080e7          	jalr	990(ra) # 80004368 <end_op>
  p = myproc();
    80004f92:	ffffd097          	auipc	ra,0xffffd
    80004f96:	b68080e7          	jalr	-1176(ra) # 80001afa <myproc>
    80004f9a:	8baa                	mv	s7,a0
  uint64 oldsz = p->sz;
    80004f9c:	04853d03          	ld	s10,72(a0)
  sz = PGROUNDUP(sz);
    80004fa0:	6785                	lui	a5,0x1
    80004fa2:	17fd                	addi	a5,a5,-1 # fff <_entry-0x7ffff001>
    80004fa4:	97ca                	add	a5,a5,s2
    80004fa6:	777d                	lui	a4,0xfffff
    80004fa8:	8ff9                	and	a5,a5,a4
    80004faa:	def43c23          	sd	a5,-520(s0)
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004fae:	4691                	li	a3,4
    80004fb0:	6609                	lui	a2,0x2
    80004fb2:	963e                	add	a2,a2,a5
    80004fb4:	85be                	mv	a1,a5
    80004fb6:	855a                	mv	a0,s6
    80004fb8:	ffffc097          	auipc	ra,0xffffc
    80004fbc:	458080e7          	jalr	1112(ra) # 80001410 <uvmalloc>
    80004fc0:	8c2a                	mv	s8,a0
  ip = 0;
    80004fc2:	4a81                	li	s5,0
  if((sz1 = uvmalloc(pagetable, sz, sz + 2*PGSIZE, PTE_W)) == 0)
    80004fc4:	12050e63          	beqz	a0,80005100 <exec+0x2d4>
  uvmclear(pagetable, sz-2*PGSIZE);
    80004fc8:	75f9                	lui	a1,0xffffe
    80004fca:	95aa                	add	a1,a1,a0
    80004fcc:	855a                	mv	a0,s6
    80004fce:	ffffc097          	auipc	ra,0xffffc
    80004fd2:	66c080e7          	jalr	1644(ra) # 8000163a <uvmclear>
  stackbase = sp - PGSIZE;
    80004fd6:	7afd                	lui	s5,0xfffff
    80004fd8:	9ae2                	add	s5,s5,s8
  for(argc = 0; argv[argc]; argc++) {
    80004fda:	df043783          	ld	a5,-528(s0)
    80004fde:	6388                	ld	a0,0(a5)
    80004fe0:	c925                	beqz	a0,80005050 <exec+0x224>
    80004fe2:	e9040993          	addi	s3,s0,-368
    80004fe6:	f9040c93          	addi	s9,s0,-112
  sp = sz;
    80004fea:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80004fec:	4481                	li	s1,0
    sp -= strlen(argv[argc]) + 1;
    80004fee:	ffffc097          	auipc	ra,0xffffc
    80004ff2:	e60080e7          	jalr	-416(ra) # 80000e4e <strlen>
    80004ff6:	0015079b          	addiw	a5,a0,1
    80004ffa:	40f907b3          	sub	a5,s2,a5
    sp -= sp % 16; // riscv sp must be 16-byte aligned
    80004ffe:	ff07f913          	andi	s2,a5,-16
    if(sp < stackbase)
    80005002:	13596663          	bltu	s2,s5,8000512e <exec+0x302>
    if(copyout(pagetable, sp, argv[argc], strlen(argv[argc]) + 1) < 0)
    80005006:	df043d83          	ld	s11,-528(s0)
    8000500a:	000dba03          	ld	s4,0(s11) # 1000 <_entry-0x7ffff000>
    8000500e:	8552                	mv	a0,s4
    80005010:	ffffc097          	auipc	ra,0xffffc
    80005014:	e3e080e7          	jalr	-450(ra) # 80000e4e <strlen>
    80005018:	0015069b          	addiw	a3,a0,1
    8000501c:	8652                	mv	a2,s4
    8000501e:	85ca                	mv	a1,s2
    80005020:	855a                	mv	a0,s6
    80005022:	ffffc097          	auipc	ra,0xffffc
    80005026:	64a080e7          	jalr	1610(ra) # 8000166c <copyout>
    8000502a:	10054663          	bltz	a0,80005136 <exec+0x30a>
    ustack[argc] = sp;
    8000502e:	0129b023          	sd	s2,0(s3)
  for(argc = 0; argv[argc]; argc++) {
    80005032:	0485                	addi	s1,s1,1
    80005034:	008d8793          	addi	a5,s11,8
    80005038:	def43823          	sd	a5,-528(s0)
    8000503c:	008db503          	ld	a0,8(s11)
    80005040:	c911                	beqz	a0,80005054 <exec+0x228>
    if(argc >= MAXARG)
    80005042:	09a1                	addi	s3,s3,8
    80005044:	fb3c95e3          	bne	s9,s3,80004fee <exec+0x1c2>
  sz = sz1;
    80005048:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000504c:	4a81                	li	s5,0
    8000504e:	a84d                	j	80005100 <exec+0x2d4>
  sp = sz;
    80005050:	8962                	mv	s2,s8
  for(argc = 0; argv[argc]; argc++) {
    80005052:	4481                	li	s1,0
  ustack[argc] = 0;
    80005054:	00349793          	slli	a5,s1,0x3
    80005058:	f9078793          	addi	a5,a5,-112
    8000505c:	97a2                	add	a5,a5,s0
    8000505e:	f007b023          	sd	zero,-256(a5)
  sp -= (argc+1) * sizeof(uint64);
    80005062:	00148693          	addi	a3,s1,1
    80005066:	068e                	slli	a3,a3,0x3
    80005068:	40d90933          	sub	s2,s2,a3
  sp -= sp % 16;
    8000506c:	ff097913          	andi	s2,s2,-16
  if(sp < stackbase)
    80005070:	01597663          	bgeu	s2,s5,8000507c <exec+0x250>
  sz = sz1;
    80005074:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005078:	4a81                	li	s5,0
    8000507a:	a059                	j	80005100 <exec+0x2d4>
  if(copyout(pagetable, sp, (char *)ustack, (argc+1)*sizeof(uint64)) < 0)
    8000507c:	e9040613          	addi	a2,s0,-368
    80005080:	85ca                	mv	a1,s2
    80005082:	855a                	mv	a0,s6
    80005084:	ffffc097          	auipc	ra,0xffffc
    80005088:	5e8080e7          	jalr	1512(ra) # 8000166c <copyout>
    8000508c:	0a054963          	bltz	a0,8000513e <exec+0x312>
  p->trapframe->a1 = sp;
    80005090:	058bb783          	ld	a5,88(s7)
    80005094:	0727bc23          	sd	s2,120(a5)
  for(last=s=path; *s; s++)
    80005098:	de843783          	ld	a5,-536(s0)
    8000509c:	0007c703          	lbu	a4,0(a5)
    800050a0:	cf11                	beqz	a4,800050bc <exec+0x290>
    800050a2:	0785                	addi	a5,a5,1
    if(*s == '/')
    800050a4:	02f00693          	li	a3,47
    800050a8:	a039                	j	800050b6 <exec+0x28a>
      last = s+1;
    800050aa:	def43423          	sd	a5,-536(s0)
  for(last=s=path; *s; s++)
    800050ae:	0785                	addi	a5,a5,1
    800050b0:	fff7c703          	lbu	a4,-1(a5)
    800050b4:	c701                	beqz	a4,800050bc <exec+0x290>
    if(*s == '/')
    800050b6:	fed71ce3          	bne	a4,a3,800050ae <exec+0x282>
    800050ba:	bfc5                	j	800050aa <exec+0x27e>
  safestrcpy(p->name, last, sizeof(p->name));
    800050bc:	4641                	li	a2,16
    800050be:	de843583          	ld	a1,-536(s0)
    800050c2:	158b8513          	addi	a0,s7,344
    800050c6:	ffffc097          	auipc	ra,0xffffc
    800050ca:	d56080e7          	jalr	-682(ra) # 80000e1c <safestrcpy>
  oldpagetable = p->pagetable;
    800050ce:	050bb503          	ld	a0,80(s7)
  p->pagetable = pagetable;
    800050d2:	056bb823          	sd	s6,80(s7)
  p->sz = sz;
    800050d6:	058bb423          	sd	s8,72(s7)
  p->trapframe->epc = elf.entry;  // initial program counter = main
    800050da:	058bb783          	ld	a5,88(s7)
    800050de:	e6843703          	ld	a4,-408(s0)
    800050e2:	ef98                	sd	a4,24(a5)
  p->trapframe->sp = sp; // initial stack pointer
    800050e4:	058bb783          	ld	a5,88(s7)
    800050e8:	0327b823          	sd	s2,48(a5)
  proc_freepagetable(oldpagetable, oldsz);
    800050ec:	85ea                	mv	a1,s10
    800050ee:	ffffd097          	auipc	ra,0xffffd
    800050f2:	b6c080e7          	jalr	-1172(ra) # 80001c5a <proc_freepagetable>
  return argc; // this ends up in a0, the first argument to main(argc, argv)
    800050f6:	0004851b          	sext.w	a0,s1
    800050fa:	b3f9                	j	80004ec8 <exec+0x9c>
    800050fc:	df243c23          	sd	s2,-520(s0)
    proc_freepagetable(pagetable, sz);
    80005100:	df843583          	ld	a1,-520(s0)
    80005104:	855a                	mv	a0,s6
    80005106:	ffffd097          	auipc	ra,0xffffd
    8000510a:	b54080e7          	jalr	-1196(ra) # 80001c5a <proc_freepagetable>
  if(ip){
    8000510e:	da0a93e3          	bnez	s5,80004eb4 <exec+0x88>
  return -1;
    80005112:	557d                	li	a0,-1
    80005114:	bb55                	j	80004ec8 <exec+0x9c>
    80005116:	df243c23          	sd	s2,-520(s0)
    8000511a:	b7dd                	j	80005100 <exec+0x2d4>
    8000511c:	df243c23          	sd	s2,-520(s0)
    80005120:	b7c5                	j	80005100 <exec+0x2d4>
    80005122:	df243c23          	sd	s2,-520(s0)
    80005126:	bfe9                	j	80005100 <exec+0x2d4>
    80005128:	df243c23          	sd	s2,-520(s0)
    8000512c:	bfd1                	j	80005100 <exec+0x2d4>
  sz = sz1;
    8000512e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005132:	4a81                	li	s5,0
    80005134:	b7f1                	j	80005100 <exec+0x2d4>
  sz = sz1;
    80005136:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    8000513a:	4a81                	li	s5,0
    8000513c:	b7d1                	j	80005100 <exec+0x2d4>
  sz = sz1;
    8000513e:	df843c23          	sd	s8,-520(s0)
  ip = 0;
    80005142:	4a81                	li	s5,0
    80005144:	bf75                	j	80005100 <exec+0x2d4>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    80005146:	df843903          	ld	s2,-520(s0)
  for(i=0, off=elf.phoff; i<elf.phnum; i++, off+=sizeof(ph)){
    8000514a:	e0843783          	ld	a5,-504(s0)
    8000514e:	0017869b          	addiw	a3,a5,1
    80005152:	e0d43423          	sd	a3,-504(s0)
    80005156:	e0043783          	ld	a5,-512(s0)
    8000515a:	0387879b          	addiw	a5,a5,56
    8000515e:	e8845703          	lhu	a4,-376(s0)
    80005162:	e0e6dfe3          	bge	a3,a4,80004f80 <exec+0x154>
    if(readi(ip, 0, (uint64)&ph, off, sizeof(ph)) != sizeof(ph))
    80005166:	2781                	sext.w	a5,a5
    80005168:	e0f43023          	sd	a5,-512(s0)
    8000516c:	03800713          	li	a4,56
    80005170:	86be                	mv	a3,a5
    80005172:	e1840613          	addi	a2,s0,-488
    80005176:	4581                	li	a1,0
    80005178:	8556                	mv	a0,s5
    8000517a:	fffff097          	auipc	ra,0xfffff
    8000517e:	a58080e7          	jalr	-1448(ra) # 80003bd2 <readi>
    80005182:	03800793          	li	a5,56
    80005186:	f6f51be3          	bne	a0,a5,800050fc <exec+0x2d0>
    if(ph.type != ELF_PROG_LOAD)
    8000518a:	e1842783          	lw	a5,-488(s0)
    8000518e:	4705                	li	a4,1
    80005190:	fae79de3          	bne	a5,a4,8000514a <exec+0x31e>
    if(ph.memsz < ph.filesz)
    80005194:	e4043483          	ld	s1,-448(s0)
    80005198:	e3843783          	ld	a5,-456(s0)
    8000519c:	f6f4ede3          	bltu	s1,a5,80005116 <exec+0x2ea>
    if(ph.vaddr + ph.memsz < ph.vaddr)
    800051a0:	e2843783          	ld	a5,-472(s0)
    800051a4:	94be                	add	s1,s1,a5
    800051a6:	f6f4ebe3          	bltu	s1,a5,8000511c <exec+0x2f0>
    if(ph.vaddr % PGSIZE != 0)
    800051aa:	de043703          	ld	a4,-544(s0)
    800051ae:	8ff9                	and	a5,a5,a4
    800051b0:	fbad                	bnez	a5,80005122 <exec+0x2f6>
    if((sz1 = uvmalloc(pagetable, sz, ph.vaddr + ph.memsz, flags2perm(ph.flags))) == 0)
    800051b2:	e1c42503          	lw	a0,-484(s0)
    800051b6:	00000097          	auipc	ra,0x0
    800051ba:	c5c080e7          	jalr	-932(ra) # 80004e12 <flags2perm>
    800051be:	86aa                	mv	a3,a0
    800051c0:	8626                	mv	a2,s1
    800051c2:	85ca                	mv	a1,s2
    800051c4:	855a                	mv	a0,s6
    800051c6:	ffffc097          	auipc	ra,0xffffc
    800051ca:	24a080e7          	jalr	586(ra) # 80001410 <uvmalloc>
    800051ce:	dea43c23          	sd	a0,-520(s0)
    800051d2:	d939                	beqz	a0,80005128 <exec+0x2fc>
    if(loadseg(pagetable, ph.vaddr, ip, ph.off, ph.filesz) < 0)
    800051d4:	e2843c03          	ld	s8,-472(s0)
    800051d8:	e2042c83          	lw	s9,-480(s0)
    800051dc:	e3842b83          	lw	s7,-456(s0)
  for(i = 0; i < sz; i += PGSIZE){
    800051e0:	f60b83e3          	beqz	s7,80005146 <exec+0x31a>
    800051e4:	89de                	mv	s3,s7
    800051e6:	4481                	li	s1,0
    800051e8:	bb9d                	j	80004f5e <exec+0x132>

00000000800051ea <argfd>:

// Fetch the nth word-sized system call argument as a file descriptor
// and return both the descriptor and the corresponding struct file.
static int
argfd(int n, int *pfd, struct file **pf)
{
    800051ea:	7179                	addi	sp,sp,-48
    800051ec:	f406                	sd	ra,40(sp)
    800051ee:	f022                	sd	s0,32(sp)
    800051f0:	ec26                	sd	s1,24(sp)
    800051f2:	e84a                	sd	s2,16(sp)
    800051f4:	1800                	addi	s0,sp,48
    800051f6:	892e                	mv	s2,a1
    800051f8:	84b2                	mv	s1,a2
  int fd;
  struct file *f;

  argint(n, &fd);
    800051fa:	fdc40593          	addi	a1,s0,-36
    800051fe:	ffffe097          	auipc	ra,0xffffe
    80005202:	a12080e7          	jalr	-1518(ra) # 80002c10 <argint>
  if(fd < 0 || fd >= NOFILE || (f=myproc()->ofile[fd]) == 0)
    80005206:	fdc42703          	lw	a4,-36(s0)
    8000520a:	47bd                	li	a5,15
    8000520c:	02e7eb63          	bltu	a5,a4,80005242 <argfd+0x58>
    80005210:	ffffd097          	auipc	ra,0xffffd
    80005214:	8ea080e7          	jalr	-1814(ra) # 80001afa <myproc>
    80005218:	fdc42703          	lw	a4,-36(s0)
    8000521c:	01a70793          	addi	a5,a4,26 # fffffffffffff01a <end+0xffffffff7ffdd23a>
    80005220:	078e                	slli	a5,a5,0x3
    80005222:	953e                	add	a0,a0,a5
    80005224:	611c                	ld	a5,0(a0)
    80005226:	c385                	beqz	a5,80005246 <argfd+0x5c>
    return -1;
  if(pfd)
    80005228:	00090463          	beqz	s2,80005230 <argfd+0x46>
    *pfd = fd;
    8000522c:	00e92023          	sw	a4,0(s2)
  if(pf)
    *pf = f;
  return 0;
    80005230:	4501                	li	a0,0
  if(pf)
    80005232:	c091                	beqz	s1,80005236 <argfd+0x4c>
    *pf = f;
    80005234:	e09c                	sd	a5,0(s1)
}
    80005236:	70a2                	ld	ra,40(sp)
    80005238:	7402                	ld	s0,32(sp)
    8000523a:	64e2                	ld	s1,24(sp)
    8000523c:	6942                	ld	s2,16(sp)
    8000523e:	6145                	addi	sp,sp,48
    80005240:	8082                	ret
    return -1;
    80005242:	557d                	li	a0,-1
    80005244:	bfcd                	j	80005236 <argfd+0x4c>
    80005246:	557d                	li	a0,-1
    80005248:	b7fd                	j	80005236 <argfd+0x4c>

000000008000524a <fdalloc>:

// Allocate a file descriptor for the given file.
// Takes over file reference from caller on success.
static int
fdalloc(struct file *f)
{
    8000524a:	1101                	addi	sp,sp,-32
    8000524c:	ec06                	sd	ra,24(sp)
    8000524e:	e822                	sd	s0,16(sp)
    80005250:	e426                	sd	s1,8(sp)
    80005252:	1000                	addi	s0,sp,32
    80005254:	84aa                	mv	s1,a0
  int fd;
  struct proc *p = myproc();
    80005256:	ffffd097          	auipc	ra,0xffffd
    8000525a:	8a4080e7          	jalr	-1884(ra) # 80001afa <myproc>
    8000525e:	862a                	mv	a2,a0

  for(fd = 0; fd < NOFILE; fd++){
    80005260:	0d050793          	addi	a5,a0,208
    80005264:	4501                	li	a0,0
    80005266:	46c1                	li	a3,16
    if(p->ofile[fd] == 0){
    80005268:	6398                	ld	a4,0(a5)
    8000526a:	cb19                	beqz	a4,80005280 <fdalloc+0x36>
  for(fd = 0; fd < NOFILE; fd++){
    8000526c:	2505                	addiw	a0,a0,1
    8000526e:	07a1                	addi	a5,a5,8
    80005270:	fed51ce3          	bne	a0,a3,80005268 <fdalloc+0x1e>
      p->ofile[fd] = f;
      return fd;
    }
  }
  return -1;
    80005274:	557d                	li	a0,-1
}
    80005276:	60e2                	ld	ra,24(sp)
    80005278:	6442                	ld	s0,16(sp)
    8000527a:	64a2                	ld	s1,8(sp)
    8000527c:	6105                	addi	sp,sp,32
    8000527e:	8082                	ret
      p->ofile[fd] = f;
    80005280:	01a50793          	addi	a5,a0,26
    80005284:	078e                	slli	a5,a5,0x3
    80005286:	963e                	add	a2,a2,a5
    80005288:	e204                	sd	s1,0(a2)
      return fd;
    8000528a:	b7f5                	j	80005276 <fdalloc+0x2c>

000000008000528c <create>:
  return -1;
}

static struct inode*
create(char *path, short type, short major, short minor)
{
    8000528c:	715d                	addi	sp,sp,-80
    8000528e:	e486                	sd	ra,72(sp)
    80005290:	e0a2                	sd	s0,64(sp)
    80005292:	fc26                	sd	s1,56(sp)
    80005294:	f84a                	sd	s2,48(sp)
    80005296:	f44e                	sd	s3,40(sp)
    80005298:	f052                	sd	s4,32(sp)
    8000529a:	ec56                	sd	s5,24(sp)
    8000529c:	e85a                	sd	s6,16(sp)
    8000529e:	0880                	addi	s0,sp,80
    800052a0:	8b2e                	mv	s6,a1
    800052a2:	89b2                	mv	s3,a2
    800052a4:	8936                	mv	s2,a3
  struct inode *ip, *dp;
  char name[DIRSIZ];

  if((dp = nameiparent(path, name)) == 0)
    800052a6:	fb040593          	addi	a1,s0,-80
    800052aa:	fffff097          	auipc	ra,0xfffff
    800052ae:	e3e080e7          	jalr	-450(ra) # 800040e8 <nameiparent>
    800052b2:	84aa                	mv	s1,a0
    800052b4:	14050f63          	beqz	a0,80005412 <create+0x186>
    return 0;

  ilock(dp);
    800052b8:	ffffe097          	auipc	ra,0xffffe
    800052bc:	666080e7          	jalr	1638(ra) # 8000391e <ilock>

  if((ip = dirlookup(dp, name, 0)) != 0){
    800052c0:	4601                	li	a2,0
    800052c2:	fb040593          	addi	a1,s0,-80
    800052c6:	8526                	mv	a0,s1
    800052c8:	fffff097          	auipc	ra,0xfffff
    800052cc:	b3a080e7          	jalr	-1222(ra) # 80003e02 <dirlookup>
    800052d0:	8aaa                	mv	s5,a0
    800052d2:	c931                	beqz	a0,80005326 <create+0x9a>
    iunlockput(dp);
    800052d4:	8526                	mv	a0,s1
    800052d6:	fffff097          	auipc	ra,0xfffff
    800052da:	8aa080e7          	jalr	-1878(ra) # 80003b80 <iunlockput>
    ilock(ip);
    800052de:	8556                	mv	a0,s5
    800052e0:	ffffe097          	auipc	ra,0xffffe
    800052e4:	63e080e7          	jalr	1598(ra) # 8000391e <ilock>
    if(type == T_FILE && (ip->type == T_FILE || ip->type == T_DEVICE))
    800052e8:	000b059b          	sext.w	a1,s6
    800052ec:	4789                	li	a5,2
    800052ee:	02f59563          	bne	a1,a5,80005318 <create+0x8c>
    800052f2:	044ad783          	lhu	a5,68(s5) # fffffffffffff044 <end+0xffffffff7ffdd264>
    800052f6:	37f9                	addiw	a5,a5,-2
    800052f8:	17c2                	slli	a5,a5,0x30
    800052fa:	93c1                	srli	a5,a5,0x30
    800052fc:	4705                	li	a4,1
    800052fe:	00f76d63          	bltu	a4,a5,80005318 <create+0x8c>
  ip->nlink = 0;
  iupdate(ip);
  iunlockput(ip);
  iunlockput(dp);
  return 0;
}
    80005302:	8556                	mv	a0,s5
    80005304:	60a6                	ld	ra,72(sp)
    80005306:	6406                	ld	s0,64(sp)
    80005308:	74e2                	ld	s1,56(sp)
    8000530a:	7942                	ld	s2,48(sp)
    8000530c:	79a2                	ld	s3,40(sp)
    8000530e:	7a02                	ld	s4,32(sp)
    80005310:	6ae2                	ld	s5,24(sp)
    80005312:	6b42                	ld	s6,16(sp)
    80005314:	6161                	addi	sp,sp,80
    80005316:	8082                	ret
    iunlockput(ip);
    80005318:	8556                	mv	a0,s5
    8000531a:	fffff097          	auipc	ra,0xfffff
    8000531e:	866080e7          	jalr	-1946(ra) # 80003b80 <iunlockput>
    return 0;
    80005322:	4a81                	li	s5,0
    80005324:	bff9                	j	80005302 <create+0x76>
  if((ip = ialloc(dp->dev, type)) == 0){
    80005326:	85da                	mv	a1,s6
    80005328:	4088                	lw	a0,0(s1)
    8000532a:	ffffe097          	auipc	ra,0xffffe
    8000532e:	456080e7          	jalr	1110(ra) # 80003780 <ialloc>
    80005332:	8a2a                	mv	s4,a0
    80005334:	c539                	beqz	a0,80005382 <create+0xf6>
  ilock(ip);
    80005336:	ffffe097          	auipc	ra,0xffffe
    8000533a:	5e8080e7          	jalr	1512(ra) # 8000391e <ilock>
  ip->major = major;
    8000533e:	053a1323          	sh	s3,70(s4)
  ip->minor = minor;
    80005342:	052a1423          	sh	s2,72(s4)
  ip->nlink = 1;
    80005346:	4905                	li	s2,1
    80005348:	052a1523          	sh	s2,74(s4)
  iupdate(ip);
    8000534c:	8552                	mv	a0,s4
    8000534e:	ffffe097          	auipc	ra,0xffffe
    80005352:	504080e7          	jalr	1284(ra) # 80003852 <iupdate>
  if(type == T_DIR){  // Create . and .. entries.
    80005356:	000b059b          	sext.w	a1,s6
    8000535a:	03258b63          	beq	a1,s2,80005390 <create+0x104>
  if(dirlink(dp, name, ip->inum) < 0)
    8000535e:	004a2603          	lw	a2,4(s4)
    80005362:	fb040593          	addi	a1,s0,-80
    80005366:	8526                	mv	a0,s1
    80005368:	fffff097          	auipc	ra,0xfffff
    8000536c:	cb0080e7          	jalr	-848(ra) # 80004018 <dirlink>
    80005370:	06054f63          	bltz	a0,800053ee <create+0x162>
  iunlockput(dp);
    80005374:	8526                	mv	a0,s1
    80005376:	fffff097          	auipc	ra,0xfffff
    8000537a:	80a080e7          	jalr	-2038(ra) # 80003b80 <iunlockput>
  return ip;
    8000537e:	8ad2                	mv	s5,s4
    80005380:	b749                	j	80005302 <create+0x76>
    iunlockput(dp);
    80005382:	8526                	mv	a0,s1
    80005384:	ffffe097          	auipc	ra,0xffffe
    80005388:	7fc080e7          	jalr	2044(ra) # 80003b80 <iunlockput>
    return 0;
    8000538c:	8ad2                	mv	s5,s4
    8000538e:	bf95                	j	80005302 <create+0x76>
    if(dirlink(ip, ".", ip->inum) < 0 || dirlink(ip, "..", dp->inum) < 0)
    80005390:	004a2603          	lw	a2,4(s4)
    80005394:	00003597          	auipc	a1,0x3
    80005398:	3d458593          	addi	a1,a1,980 # 80008768 <syscalls+0x2b8>
    8000539c:	8552                	mv	a0,s4
    8000539e:	fffff097          	auipc	ra,0xfffff
    800053a2:	c7a080e7          	jalr	-902(ra) # 80004018 <dirlink>
    800053a6:	04054463          	bltz	a0,800053ee <create+0x162>
    800053aa:	40d0                	lw	a2,4(s1)
    800053ac:	00003597          	auipc	a1,0x3
    800053b0:	3c458593          	addi	a1,a1,964 # 80008770 <syscalls+0x2c0>
    800053b4:	8552                	mv	a0,s4
    800053b6:	fffff097          	auipc	ra,0xfffff
    800053ba:	c62080e7          	jalr	-926(ra) # 80004018 <dirlink>
    800053be:	02054863          	bltz	a0,800053ee <create+0x162>
  if(dirlink(dp, name, ip->inum) < 0)
    800053c2:	004a2603          	lw	a2,4(s4)
    800053c6:	fb040593          	addi	a1,s0,-80
    800053ca:	8526                	mv	a0,s1
    800053cc:	fffff097          	auipc	ra,0xfffff
    800053d0:	c4c080e7          	jalr	-948(ra) # 80004018 <dirlink>
    800053d4:	00054d63          	bltz	a0,800053ee <create+0x162>
    dp->nlink++;  // for ".."
    800053d8:	04a4d783          	lhu	a5,74(s1)
    800053dc:	2785                	addiw	a5,a5,1
    800053de:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    800053e2:	8526                	mv	a0,s1
    800053e4:	ffffe097          	auipc	ra,0xffffe
    800053e8:	46e080e7          	jalr	1134(ra) # 80003852 <iupdate>
    800053ec:	b761                	j	80005374 <create+0xe8>
  ip->nlink = 0;
    800053ee:	040a1523          	sh	zero,74(s4)
  iupdate(ip);
    800053f2:	8552                	mv	a0,s4
    800053f4:	ffffe097          	auipc	ra,0xffffe
    800053f8:	45e080e7          	jalr	1118(ra) # 80003852 <iupdate>
  iunlockput(ip);
    800053fc:	8552                	mv	a0,s4
    800053fe:	ffffe097          	auipc	ra,0xffffe
    80005402:	782080e7          	jalr	1922(ra) # 80003b80 <iunlockput>
  iunlockput(dp);
    80005406:	8526                	mv	a0,s1
    80005408:	ffffe097          	auipc	ra,0xffffe
    8000540c:	778080e7          	jalr	1912(ra) # 80003b80 <iunlockput>
  return 0;
    80005410:	bdcd                	j	80005302 <create+0x76>
    return 0;
    80005412:	8aaa                	mv	s5,a0
    80005414:	b5fd                	j	80005302 <create+0x76>

0000000080005416 <sys_dup>:
{
    80005416:	7179                	addi	sp,sp,-48
    80005418:	f406                	sd	ra,40(sp)
    8000541a:	f022                	sd	s0,32(sp)
    8000541c:	ec26                	sd	s1,24(sp)
    8000541e:	e84a                	sd	s2,16(sp)
    80005420:	1800                	addi	s0,sp,48
  if(argfd(0, 0, &f) < 0)
    80005422:	fd840613          	addi	a2,s0,-40
    80005426:	4581                	li	a1,0
    80005428:	4501                	li	a0,0
    8000542a:	00000097          	auipc	ra,0x0
    8000542e:	dc0080e7          	jalr	-576(ra) # 800051ea <argfd>
    return -1;
    80005432:	57fd                	li	a5,-1
  if(argfd(0, 0, &f) < 0)
    80005434:	02054363          	bltz	a0,8000545a <sys_dup+0x44>
  if((fd=fdalloc(f)) < 0)
    80005438:	fd843903          	ld	s2,-40(s0)
    8000543c:	854a                	mv	a0,s2
    8000543e:	00000097          	auipc	ra,0x0
    80005442:	e0c080e7          	jalr	-500(ra) # 8000524a <fdalloc>
    80005446:	84aa                	mv	s1,a0
    return -1;
    80005448:	57fd                	li	a5,-1
  if((fd=fdalloc(f)) < 0)
    8000544a:	00054863          	bltz	a0,8000545a <sys_dup+0x44>
  filedup(f);
    8000544e:	854a                	mv	a0,s2
    80005450:	fffff097          	auipc	ra,0xfffff
    80005454:	310080e7          	jalr	784(ra) # 80004760 <filedup>
  return fd;
    80005458:	87a6                	mv	a5,s1
}
    8000545a:	853e                	mv	a0,a5
    8000545c:	70a2                	ld	ra,40(sp)
    8000545e:	7402                	ld	s0,32(sp)
    80005460:	64e2                	ld	s1,24(sp)
    80005462:	6942                	ld	s2,16(sp)
    80005464:	6145                	addi	sp,sp,48
    80005466:	8082                	ret

0000000080005468 <sys_read>:
{
    80005468:	7179                	addi	sp,sp,-48
    8000546a:	f406                	sd	ra,40(sp)
    8000546c:	f022                	sd	s0,32(sp)
    8000546e:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    80005470:	fd840593          	addi	a1,s0,-40
    80005474:	4505                	li	a0,1
    80005476:	ffffd097          	auipc	ra,0xffffd
    8000547a:	7ba080e7          	jalr	1978(ra) # 80002c30 <argaddr>
  argint(2, &n);
    8000547e:	fe440593          	addi	a1,s0,-28
    80005482:	4509                	li	a0,2
    80005484:	ffffd097          	auipc	ra,0xffffd
    80005488:	78c080e7          	jalr	1932(ra) # 80002c10 <argint>
  if(argfd(0, 0, &f) < 0)
    8000548c:	fe840613          	addi	a2,s0,-24
    80005490:	4581                	li	a1,0
    80005492:	4501                	li	a0,0
    80005494:	00000097          	auipc	ra,0x0
    80005498:	d56080e7          	jalr	-682(ra) # 800051ea <argfd>
    8000549c:	87aa                	mv	a5,a0
    return -1;
    8000549e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800054a0:	0007cc63          	bltz	a5,800054b8 <sys_read+0x50>
  return fileread(f, p, n);
    800054a4:	fe442603          	lw	a2,-28(s0)
    800054a8:	fd843583          	ld	a1,-40(s0)
    800054ac:	fe843503          	ld	a0,-24(s0)
    800054b0:	fffff097          	auipc	ra,0xfffff
    800054b4:	43c080e7          	jalr	1084(ra) # 800048ec <fileread>
}
    800054b8:	70a2                	ld	ra,40(sp)
    800054ba:	7402                	ld	s0,32(sp)
    800054bc:	6145                	addi	sp,sp,48
    800054be:	8082                	ret

00000000800054c0 <sys_write>:
{
    800054c0:	7179                	addi	sp,sp,-48
    800054c2:	f406                	sd	ra,40(sp)
    800054c4:	f022                	sd	s0,32(sp)
    800054c6:	1800                	addi	s0,sp,48
  argaddr(1, &p);
    800054c8:	fd840593          	addi	a1,s0,-40
    800054cc:	4505                	li	a0,1
    800054ce:	ffffd097          	auipc	ra,0xffffd
    800054d2:	762080e7          	jalr	1890(ra) # 80002c30 <argaddr>
  argint(2, &n);
    800054d6:	fe440593          	addi	a1,s0,-28
    800054da:	4509                	li	a0,2
    800054dc:	ffffd097          	auipc	ra,0xffffd
    800054e0:	734080e7          	jalr	1844(ra) # 80002c10 <argint>
  if(argfd(0, 0, &f) < 0)
    800054e4:	fe840613          	addi	a2,s0,-24
    800054e8:	4581                	li	a1,0
    800054ea:	4501                	li	a0,0
    800054ec:	00000097          	auipc	ra,0x0
    800054f0:	cfe080e7          	jalr	-770(ra) # 800051ea <argfd>
    800054f4:	87aa                	mv	a5,a0
    return -1;
    800054f6:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    800054f8:	0007cc63          	bltz	a5,80005510 <sys_write+0x50>
  return filewrite(f, p, n);
    800054fc:	fe442603          	lw	a2,-28(s0)
    80005500:	fd843583          	ld	a1,-40(s0)
    80005504:	fe843503          	ld	a0,-24(s0)
    80005508:	fffff097          	auipc	ra,0xfffff
    8000550c:	4a6080e7          	jalr	1190(ra) # 800049ae <filewrite>
}
    80005510:	70a2                	ld	ra,40(sp)
    80005512:	7402                	ld	s0,32(sp)
    80005514:	6145                	addi	sp,sp,48
    80005516:	8082                	ret

0000000080005518 <sys_close>:
{
    80005518:	1101                	addi	sp,sp,-32
    8000551a:	ec06                	sd	ra,24(sp)
    8000551c:	e822                	sd	s0,16(sp)
    8000551e:	1000                	addi	s0,sp,32
  if(argfd(0, &fd, &f) < 0)
    80005520:	fe040613          	addi	a2,s0,-32
    80005524:	fec40593          	addi	a1,s0,-20
    80005528:	4501                	li	a0,0
    8000552a:	00000097          	auipc	ra,0x0
    8000552e:	cc0080e7          	jalr	-832(ra) # 800051ea <argfd>
    return -1;
    80005532:	57fd                	li	a5,-1
  if(argfd(0, &fd, &f) < 0)
    80005534:	02054463          	bltz	a0,8000555c <sys_close+0x44>
  myproc()->ofile[fd] = 0;
    80005538:	ffffc097          	auipc	ra,0xffffc
    8000553c:	5c2080e7          	jalr	1474(ra) # 80001afa <myproc>
    80005540:	fec42783          	lw	a5,-20(s0)
    80005544:	07e9                	addi	a5,a5,26
    80005546:	078e                	slli	a5,a5,0x3
    80005548:	953e                	add	a0,a0,a5
    8000554a:	00053023          	sd	zero,0(a0)
  fileclose(f);
    8000554e:	fe043503          	ld	a0,-32(s0)
    80005552:	fffff097          	auipc	ra,0xfffff
    80005556:	260080e7          	jalr	608(ra) # 800047b2 <fileclose>
  return 0;
    8000555a:	4781                	li	a5,0
}
    8000555c:	853e                	mv	a0,a5
    8000555e:	60e2                	ld	ra,24(sp)
    80005560:	6442                	ld	s0,16(sp)
    80005562:	6105                	addi	sp,sp,32
    80005564:	8082                	ret

0000000080005566 <sys_fstat>:
{
    80005566:	1101                	addi	sp,sp,-32
    80005568:	ec06                	sd	ra,24(sp)
    8000556a:	e822                	sd	s0,16(sp)
    8000556c:	1000                	addi	s0,sp,32
  argaddr(1, &st);
    8000556e:	fe040593          	addi	a1,s0,-32
    80005572:	4505                	li	a0,1
    80005574:	ffffd097          	auipc	ra,0xffffd
    80005578:	6bc080e7          	jalr	1724(ra) # 80002c30 <argaddr>
  if(argfd(0, 0, &f) < 0)
    8000557c:	fe840613          	addi	a2,s0,-24
    80005580:	4581                	li	a1,0
    80005582:	4501                	li	a0,0
    80005584:	00000097          	auipc	ra,0x0
    80005588:	c66080e7          	jalr	-922(ra) # 800051ea <argfd>
    8000558c:	87aa                	mv	a5,a0
    return -1;
    8000558e:	557d                	li	a0,-1
  if(argfd(0, 0, &f) < 0)
    80005590:	0007ca63          	bltz	a5,800055a4 <sys_fstat+0x3e>
  return filestat(f, st);
    80005594:	fe043583          	ld	a1,-32(s0)
    80005598:	fe843503          	ld	a0,-24(s0)
    8000559c:	fffff097          	auipc	ra,0xfffff
    800055a0:	2de080e7          	jalr	734(ra) # 8000487a <filestat>
}
    800055a4:	60e2                	ld	ra,24(sp)
    800055a6:	6442                	ld	s0,16(sp)
    800055a8:	6105                	addi	sp,sp,32
    800055aa:	8082                	ret

00000000800055ac <sys_link>:
{
    800055ac:	7169                	addi	sp,sp,-304
    800055ae:	f606                	sd	ra,296(sp)
    800055b0:	f222                	sd	s0,288(sp)
    800055b2:	ee26                	sd	s1,280(sp)
    800055b4:	ea4a                	sd	s2,272(sp)
    800055b6:	1a00                	addi	s0,sp,304
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055b8:	08000613          	li	a2,128
    800055bc:	ed040593          	addi	a1,s0,-304
    800055c0:	4501                	li	a0,0
    800055c2:	ffffd097          	auipc	ra,0xffffd
    800055c6:	68e080e7          	jalr	1678(ra) # 80002c50 <argstr>
    return -1;
    800055ca:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055cc:	10054e63          	bltz	a0,800056e8 <sys_link+0x13c>
    800055d0:	08000613          	li	a2,128
    800055d4:	f5040593          	addi	a1,s0,-176
    800055d8:	4505                	li	a0,1
    800055da:	ffffd097          	auipc	ra,0xffffd
    800055de:	676080e7          	jalr	1654(ra) # 80002c50 <argstr>
    return -1;
    800055e2:	57fd                	li	a5,-1
  if(argstr(0, old, MAXPATH) < 0 || argstr(1, new, MAXPATH) < 0)
    800055e4:	10054263          	bltz	a0,800056e8 <sys_link+0x13c>
  begin_op();
    800055e8:	fffff097          	auipc	ra,0xfffff
    800055ec:	d02080e7          	jalr	-766(ra) # 800042ea <begin_op>
  if((ip = namei(old)) == 0){
    800055f0:	ed040513          	addi	a0,s0,-304
    800055f4:	fffff097          	auipc	ra,0xfffff
    800055f8:	ad6080e7          	jalr	-1322(ra) # 800040ca <namei>
    800055fc:	84aa                	mv	s1,a0
    800055fe:	c551                	beqz	a0,8000568a <sys_link+0xde>
  ilock(ip);
    80005600:	ffffe097          	auipc	ra,0xffffe
    80005604:	31e080e7          	jalr	798(ra) # 8000391e <ilock>
  if(ip->type == T_DIR){
    80005608:	04449703          	lh	a4,68(s1)
    8000560c:	4785                	li	a5,1
    8000560e:	08f70463          	beq	a4,a5,80005696 <sys_link+0xea>
  ip->nlink++;
    80005612:	04a4d783          	lhu	a5,74(s1)
    80005616:	2785                	addiw	a5,a5,1
    80005618:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    8000561c:	8526                	mv	a0,s1
    8000561e:	ffffe097          	auipc	ra,0xffffe
    80005622:	234080e7          	jalr	564(ra) # 80003852 <iupdate>
  iunlock(ip);
    80005626:	8526                	mv	a0,s1
    80005628:	ffffe097          	auipc	ra,0xffffe
    8000562c:	3b8080e7          	jalr	952(ra) # 800039e0 <iunlock>
  if((dp = nameiparent(new, name)) == 0)
    80005630:	fd040593          	addi	a1,s0,-48
    80005634:	f5040513          	addi	a0,s0,-176
    80005638:	fffff097          	auipc	ra,0xfffff
    8000563c:	ab0080e7          	jalr	-1360(ra) # 800040e8 <nameiparent>
    80005640:	892a                	mv	s2,a0
    80005642:	c935                	beqz	a0,800056b6 <sys_link+0x10a>
  ilock(dp);
    80005644:	ffffe097          	auipc	ra,0xffffe
    80005648:	2da080e7          	jalr	730(ra) # 8000391e <ilock>
  if(dp->dev != ip->dev || dirlink(dp, name, ip->inum) < 0){
    8000564c:	00092703          	lw	a4,0(s2)
    80005650:	409c                	lw	a5,0(s1)
    80005652:	04f71d63          	bne	a4,a5,800056ac <sys_link+0x100>
    80005656:	40d0                	lw	a2,4(s1)
    80005658:	fd040593          	addi	a1,s0,-48
    8000565c:	854a                	mv	a0,s2
    8000565e:	fffff097          	auipc	ra,0xfffff
    80005662:	9ba080e7          	jalr	-1606(ra) # 80004018 <dirlink>
    80005666:	04054363          	bltz	a0,800056ac <sys_link+0x100>
  iunlockput(dp);
    8000566a:	854a                	mv	a0,s2
    8000566c:	ffffe097          	auipc	ra,0xffffe
    80005670:	514080e7          	jalr	1300(ra) # 80003b80 <iunlockput>
  iput(ip);
    80005674:	8526                	mv	a0,s1
    80005676:	ffffe097          	auipc	ra,0xffffe
    8000567a:	462080e7          	jalr	1122(ra) # 80003ad8 <iput>
  end_op();
    8000567e:	fffff097          	auipc	ra,0xfffff
    80005682:	cea080e7          	jalr	-790(ra) # 80004368 <end_op>
  return 0;
    80005686:	4781                	li	a5,0
    80005688:	a085                	j	800056e8 <sys_link+0x13c>
    end_op();
    8000568a:	fffff097          	auipc	ra,0xfffff
    8000568e:	cde080e7          	jalr	-802(ra) # 80004368 <end_op>
    return -1;
    80005692:	57fd                	li	a5,-1
    80005694:	a891                	j	800056e8 <sys_link+0x13c>
    iunlockput(ip);
    80005696:	8526                	mv	a0,s1
    80005698:	ffffe097          	auipc	ra,0xffffe
    8000569c:	4e8080e7          	jalr	1256(ra) # 80003b80 <iunlockput>
    end_op();
    800056a0:	fffff097          	auipc	ra,0xfffff
    800056a4:	cc8080e7          	jalr	-824(ra) # 80004368 <end_op>
    return -1;
    800056a8:	57fd                	li	a5,-1
    800056aa:	a83d                	j	800056e8 <sys_link+0x13c>
    iunlockput(dp);
    800056ac:	854a                	mv	a0,s2
    800056ae:	ffffe097          	auipc	ra,0xffffe
    800056b2:	4d2080e7          	jalr	1234(ra) # 80003b80 <iunlockput>
  ilock(ip);
    800056b6:	8526                	mv	a0,s1
    800056b8:	ffffe097          	auipc	ra,0xffffe
    800056bc:	266080e7          	jalr	614(ra) # 8000391e <ilock>
  ip->nlink--;
    800056c0:	04a4d783          	lhu	a5,74(s1)
    800056c4:	37fd                	addiw	a5,a5,-1
    800056c6:	04f49523          	sh	a5,74(s1)
  iupdate(ip);
    800056ca:	8526                	mv	a0,s1
    800056cc:	ffffe097          	auipc	ra,0xffffe
    800056d0:	186080e7          	jalr	390(ra) # 80003852 <iupdate>
  iunlockput(ip);
    800056d4:	8526                	mv	a0,s1
    800056d6:	ffffe097          	auipc	ra,0xffffe
    800056da:	4aa080e7          	jalr	1194(ra) # 80003b80 <iunlockput>
  end_op();
    800056de:	fffff097          	auipc	ra,0xfffff
    800056e2:	c8a080e7          	jalr	-886(ra) # 80004368 <end_op>
  return -1;
    800056e6:	57fd                	li	a5,-1
}
    800056e8:	853e                	mv	a0,a5
    800056ea:	70b2                	ld	ra,296(sp)
    800056ec:	7412                	ld	s0,288(sp)
    800056ee:	64f2                	ld	s1,280(sp)
    800056f0:	6952                	ld	s2,272(sp)
    800056f2:	6155                	addi	sp,sp,304
    800056f4:	8082                	ret

00000000800056f6 <sys_unlink>:
{
    800056f6:	7151                	addi	sp,sp,-240
    800056f8:	f586                	sd	ra,232(sp)
    800056fa:	f1a2                	sd	s0,224(sp)
    800056fc:	eda6                	sd	s1,216(sp)
    800056fe:	e9ca                	sd	s2,208(sp)
    80005700:	e5ce                	sd	s3,200(sp)
    80005702:	1980                	addi	s0,sp,240
  if(argstr(0, path, MAXPATH) < 0)
    80005704:	08000613          	li	a2,128
    80005708:	f3040593          	addi	a1,s0,-208
    8000570c:	4501                	li	a0,0
    8000570e:	ffffd097          	auipc	ra,0xffffd
    80005712:	542080e7          	jalr	1346(ra) # 80002c50 <argstr>
    80005716:	18054163          	bltz	a0,80005898 <sys_unlink+0x1a2>
  begin_op();
    8000571a:	fffff097          	auipc	ra,0xfffff
    8000571e:	bd0080e7          	jalr	-1072(ra) # 800042ea <begin_op>
  if((dp = nameiparent(path, name)) == 0){
    80005722:	fb040593          	addi	a1,s0,-80
    80005726:	f3040513          	addi	a0,s0,-208
    8000572a:	fffff097          	auipc	ra,0xfffff
    8000572e:	9be080e7          	jalr	-1602(ra) # 800040e8 <nameiparent>
    80005732:	84aa                	mv	s1,a0
    80005734:	c979                	beqz	a0,8000580a <sys_unlink+0x114>
  ilock(dp);
    80005736:	ffffe097          	auipc	ra,0xffffe
    8000573a:	1e8080e7          	jalr	488(ra) # 8000391e <ilock>
  if(namecmp(name, ".") == 0 || namecmp(name, "..") == 0)
    8000573e:	00003597          	auipc	a1,0x3
    80005742:	02a58593          	addi	a1,a1,42 # 80008768 <syscalls+0x2b8>
    80005746:	fb040513          	addi	a0,s0,-80
    8000574a:	ffffe097          	auipc	ra,0xffffe
    8000574e:	69e080e7          	jalr	1694(ra) # 80003de8 <namecmp>
    80005752:	14050a63          	beqz	a0,800058a6 <sys_unlink+0x1b0>
    80005756:	00003597          	auipc	a1,0x3
    8000575a:	01a58593          	addi	a1,a1,26 # 80008770 <syscalls+0x2c0>
    8000575e:	fb040513          	addi	a0,s0,-80
    80005762:	ffffe097          	auipc	ra,0xffffe
    80005766:	686080e7          	jalr	1670(ra) # 80003de8 <namecmp>
    8000576a:	12050e63          	beqz	a0,800058a6 <sys_unlink+0x1b0>
  if((ip = dirlookup(dp, name, &off)) == 0)
    8000576e:	f2c40613          	addi	a2,s0,-212
    80005772:	fb040593          	addi	a1,s0,-80
    80005776:	8526                	mv	a0,s1
    80005778:	ffffe097          	auipc	ra,0xffffe
    8000577c:	68a080e7          	jalr	1674(ra) # 80003e02 <dirlookup>
    80005780:	892a                	mv	s2,a0
    80005782:	12050263          	beqz	a0,800058a6 <sys_unlink+0x1b0>
  ilock(ip);
    80005786:	ffffe097          	auipc	ra,0xffffe
    8000578a:	198080e7          	jalr	408(ra) # 8000391e <ilock>
  if(ip->nlink < 1)
    8000578e:	04a91783          	lh	a5,74(s2)
    80005792:	08f05263          	blez	a5,80005816 <sys_unlink+0x120>
  if(ip->type == T_DIR && !isdirempty(ip)){
    80005796:	04491703          	lh	a4,68(s2)
    8000579a:	4785                	li	a5,1
    8000579c:	08f70563          	beq	a4,a5,80005826 <sys_unlink+0x130>
  memset(&de, 0, sizeof(de));
    800057a0:	4641                	li	a2,16
    800057a2:	4581                	li	a1,0
    800057a4:	fc040513          	addi	a0,s0,-64
    800057a8:	ffffb097          	auipc	ra,0xffffb
    800057ac:	52a080e7          	jalr	1322(ra) # 80000cd2 <memset>
  if(writei(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    800057b0:	4741                	li	a4,16
    800057b2:	f2c42683          	lw	a3,-212(s0)
    800057b6:	fc040613          	addi	a2,s0,-64
    800057ba:	4581                	li	a1,0
    800057bc:	8526                	mv	a0,s1
    800057be:	ffffe097          	auipc	ra,0xffffe
    800057c2:	50c080e7          	jalr	1292(ra) # 80003cca <writei>
    800057c6:	47c1                	li	a5,16
    800057c8:	0af51563          	bne	a0,a5,80005872 <sys_unlink+0x17c>
  if(ip->type == T_DIR){
    800057cc:	04491703          	lh	a4,68(s2)
    800057d0:	4785                	li	a5,1
    800057d2:	0af70863          	beq	a4,a5,80005882 <sys_unlink+0x18c>
  iunlockput(dp);
    800057d6:	8526                	mv	a0,s1
    800057d8:	ffffe097          	auipc	ra,0xffffe
    800057dc:	3a8080e7          	jalr	936(ra) # 80003b80 <iunlockput>
  ip->nlink--;
    800057e0:	04a95783          	lhu	a5,74(s2)
    800057e4:	37fd                	addiw	a5,a5,-1
    800057e6:	04f91523          	sh	a5,74(s2)
  iupdate(ip);
    800057ea:	854a                	mv	a0,s2
    800057ec:	ffffe097          	auipc	ra,0xffffe
    800057f0:	066080e7          	jalr	102(ra) # 80003852 <iupdate>
  iunlockput(ip);
    800057f4:	854a                	mv	a0,s2
    800057f6:	ffffe097          	auipc	ra,0xffffe
    800057fa:	38a080e7          	jalr	906(ra) # 80003b80 <iunlockput>
  end_op();
    800057fe:	fffff097          	auipc	ra,0xfffff
    80005802:	b6a080e7          	jalr	-1174(ra) # 80004368 <end_op>
  return 0;
    80005806:	4501                	li	a0,0
    80005808:	a84d                	j	800058ba <sys_unlink+0x1c4>
    end_op();
    8000580a:	fffff097          	auipc	ra,0xfffff
    8000580e:	b5e080e7          	jalr	-1186(ra) # 80004368 <end_op>
    return -1;
    80005812:	557d                	li	a0,-1
    80005814:	a05d                	j	800058ba <sys_unlink+0x1c4>
    panic("unlink: nlink < 1");
    80005816:	00003517          	auipc	a0,0x3
    8000581a:	f6250513          	addi	a0,a0,-158 # 80008778 <syscalls+0x2c8>
    8000581e:	ffffb097          	auipc	ra,0xffffb
    80005822:	d22080e7          	jalr	-734(ra) # 80000540 <panic>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005826:	04c92703          	lw	a4,76(s2)
    8000582a:	02000793          	li	a5,32
    8000582e:	f6e7f9e3          	bgeu	a5,a4,800057a0 <sys_unlink+0xaa>
    80005832:	02000993          	li	s3,32
    if(readi(dp, 0, (uint64)&de, off, sizeof(de)) != sizeof(de))
    80005836:	4741                	li	a4,16
    80005838:	86ce                	mv	a3,s3
    8000583a:	f1840613          	addi	a2,s0,-232
    8000583e:	4581                	li	a1,0
    80005840:	854a                	mv	a0,s2
    80005842:	ffffe097          	auipc	ra,0xffffe
    80005846:	390080e7          	jalr	912(ra) # 80003bd2 <readi>
    8000584a:	47c1                	li	a5,16
    8000584c:	00f51b63          	bne	a0,a5,80005862 <sys_unlink+0x16c>
    if(de.inum != 0)
    80005850:	f1845783          	lhu	a5,-232(s0)
    80005854:	e7a1                	bnez	a5,8000589c <sys_unlink+0x1a6>
  for(off=2*sizeof(de); off<dp->size; off+=sizeof(de)){
    80005856:	29c1                	addiw	s3,s3,16
    80005858:	04c92783          	lw	a5,76(s2)
    8000585c:	fcf9ede3          	bltu	s3,a5,80005836 <sys_unlink+0x140>
    80005860:	b781                	j	800057a0 <sys_unlink+0xaa>
      panic("isdirempty: readi");
    80005862:	00003517          	auipc	a0,0x3
    80005866:	f2e50513          	addi	a0,a0,-210 # 80008790 <syscalls+0x2e0>
    8000586a:	ffffb097          	auipc	ra,0xffffb
    8000586e:	cd6080e7          	jalr	-810(ra) # 80000540 <panic>
    panic("unlink: writei");
    80005872:	00003517          	auipc	a0,0x3
    80005876:	f3650513          	addi	a0,a0,-202 # 800087a8 <syscalls+0x2f8>
    8000587a:	ffffb097          	auipc	ra,0xffffb
    8000587e:	cc6080e7          	jalr	-826(ra) # 80000540 <panic>
    dp->nlink--;
    80005882:	04a4d783          	lhu	a5,74(s1)
    80005886:	37fd                	addiw	a5,a5,-1
    80005888:	04f49523          	sh	a5,74(s1)
    iupdate(dp);
    8000588c:	8526                	mv	a0,s1
    8000588e:	ffffe097          	auipc	ra,0xffffe
    80005892:	fc4080e7          	jalr	-60(ra) # 80003852 <iupdate>
    80005896:	b781                	j	800057d6 <sys_unlink+0xe0>
    return -1;
    80005898:	557d                	li	a0,-1
    8000589a:	a005                	j	800058ba <sys_unlink+0x1c4>
    iunlockput(ip);
    8000589c:	854a                	mv	a0,s2
    8000589e:	ffffe097          	auipc	ra,0xffffe
    800058a2:	2e2080e7          	jalr	738(ra) # 80003b80 <iunlockput>
  iunlockput(dp);
    800058a6:	8526                	mv	a0,s1
    800058a8:	ffffe097          	auipc	ra,0xffffe
    800058ac:	2d8080e7          	jalr	728(ra) # 80003b80 <iunlockput>
  end_op();
    800058b0:	fffff097          	auipc	ra,0xfffff
    800058b4:	ab8080e7          	jalr	-1352(ra) # 80004368 <end_op>
  return -1;
    800058b8:	557d                	li	a0,-1
}
    800058ba:	70ae                	ld	ra,232(sp)
    800058bc:	740e                	ld	s0,224(sp)
    800058be:	64ee                	ld	s1,216(sp)
    800058c0:	694e                	ld	s2,208(sp)
    800058c2:	69ae                	ld	s3,200(sp)
    800058c4:	616d                	addi	sp,sp,240
    800058c6:	8082                	ret

00000000800058c8 <sys_open>:

uint64
sys_open(void)
{
    800058c8:	7131                	addi	sp,sp,-192
    800058ca:	fd06                	sd	ra,184(sp)
    800058cc:	f922                	sd	s0,176(sp)
    800058ce:	f526                	sd	s1,168(sp)
    800058d0:	f14a                	sd	s2,160(sp)
    800058d2:	ed4e                	sd	s3,152(sp)
    800058d4:	0180                	addi	s0,sp,192
  int fd, omode;
  struct file *f;
  struct inode *ip;
  int n;

  argint(1, &omode);
    800058d6:	f4c40593          	addi	a1,s0,-180
    800058da:	4505                	li	a0,1
    800058dc:	ffffd097          	auipc	ra,0xffffd
    800058e0:	334080e7          	jalr	820(ra) # 80002c10 <argint>
  if((n = argstr(0, path, MAXPATH)) < 0)
    800058e4:	08000613          	li	a2,128
    800058e8:	f5040593          	addi	a1,s0,-176
    800058ec:	4501                	li	a0,0
    800058ee:	ffffd097          	auipc	ra,0xffffd
    800058f2:	362080e7          	jalr	866(ra) # 80002c50 <argstr>
    800058f6:	87aa                	mv	a5,a0
    return -1;
    800058f8:	557d                	li	a0,-1
  if((n = argstr(0, path, MAXPATH)) < 0)
    800058fa:	0a07c963          	bltz	a5,800059ac <sys_open+0xe4>

  begin_op();
    800058fe:	fffff097          	auipc	ra,0xfffff
    80005902:	9ec080e7          	jalr	-1556(ra) # 800042ea <begin_op>

  if(omode & O_CREATE){
    80005906:	f4c42783          	lw	a5,-180(s0)
    8000590a:	2007f793          	andi	a5,a5,512
    8000590e:	cfc5                	beqz	a5,800059c6 <sys_open+0xfe>
    ip = create(path, T_FILE, 0, 0);
    80005910:	4681                	li	a3,0
    80005912:	4601                	li	a2,0
    80005914:	4589                	li	a1,2
    80005916:	f5040513          	addi	a0,s0,-176
    8000591a:	00000097          	auipc	ra,0x0
    8000591e:	972080e7          	jalr	-1678(ra) # 8000528c <create>
    80005922:	84aa                	mv	s1,a0
    if(ip == 0){
    80005924:	c959                	beqz	a0,800059ba <sys_open+0xf2>
      end_op();
      return -1;
    }
  }

  if(ip->type == T_DEVICE && (ip->major < 0 || ip->major >= NDEV)){
    80005926:	04449703          	lh	a4,68(s1)
    8000592a:	478d                	li	a5,3
    8000592c:	00f71763          	bne	a4,a5,8000593a <sys_open+0x72>
    80005930:	0464d703          	lhu	a4,70(s1)
    80005934:	47a5                	li	a5,9
    80005936:	0ce7ed63          	bltu	a5,a4,80005a10 <sys_open+0x148>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if((f = filealloc()) == 0 || (fd = fdalloc(f)) < 0){
    8000593a:	fffff097          	auipc	ra,0xfffff
    8000593e:	dbc080e7          	jalr	-580(ra) # 800046f6 <filealloc>
    80005942:	89aa                	mv	s3,a0
    80005944:	10050363          	beqz	a0,80005a4a <sys_open+0x182>
    80005948:	00000097          	auipc	ra,0x0
    8000594c:	902080e7          	jalr	-1790(ra) # 8000524a <fdalloc>
    80005950:	892a                	mv	s2,a0
    80005952:	0e054763          	bltz	a0,80005a40 <sys_open+0x178>
    iunlockput(ip);
    end_op();
    return -1;
  }

  if(ip->type == T_DEVICE){
    80005956:	04449703          	lh	a4,68(s1)
    8000595a:	478d                	li	a5,3
    8000595c:	0cf70563          	beq	a4,a5,80005a26 <sys_open+0x15e>
    f->type = FD_DEVICE;
    f->major = ip->major;
  } else {
    f->type = FD_INODE;
    80005960:	4789                	li	a5,2
    80005962:	00f9a023          	sw	a5,0(s3)
    f->off = 0;
    80005966:	0209a023          	sw	zero,32(s3)
  }
  f->ip = ip;
    8000596a:	0099bc23          	sd	s1,24(s3)
  f->readable = !(omode & O_WRONLY);
    8000596e:	f4c42783          	lw	a5,-180(s0)
    80005972:	0017c713          	xori	a4,a5,1
    80005976:	8b05                	andi	a4,a4,1
    80005978:	00e98423          	sb	a4,8(s3)
  f->writable = (omode & O_WRONLY) || (omode & O_RDWR);
    8000597c:	0037f713          	andi	a4,a5,3
    80005980:	00e03733          	snez	a4,a4
    80005984:	00e984a3          	sb	a4,9(s3)

  if((omode & O_TRUNC) && ip->type == T_FILE){
    80005988:	4007f793          	andi	a5,a5,1024
    8000598c:	c791                	beqz	a5,80005998 <sys_open+0xd0>
    8000598e:	04449703          	lh	a4,68(s1)
    80005992:	4789                	li	a5,2
    80005994:	0af70063          	beq	a4,a5,80005a34 <sys_open+0x16c>
    itrunc(ip);
  }

  iunlock(ip);
    80005998:	8526                	mv	a0,s1
    8000599a:	ffffe097          	auipc	ra,0xffffe
    8000599e:	046080e7          	jalr	70(ra) # 800039e0 <iunlock>
  end_op();
    800059a2:	fffff097          	auipc	ra,0xfffff
    800059a6:	9c6080e7          	jalr	-1594(ra) # 80004368 <end_op>

  return fd;
    800059aa:	854a                	mv	a0,s2
}
    800059ac:	70ea                	ld	ra,184(sp)
    800059ae:	744a                	ld	s0,176(sp)
    800059b0:	74aa                	ld	s1,168(sp)
    800059b2:	790a                	ld	s2,160(sp)
    800059b4:	69ea                	ld	s3,152(sp)
    800059b6:	6129                	addi	sp,sp,192
    800059b8:	8082                	ret
      end_op();
    800059ba:	fffff097          	auipc	ra,0xfffff
    800059be:	9ae080e7          	jalr	-1618(ra) # 80004368 <end_op>
      return -1;
    800059c2:	557d                	li	a0,-1
    800059c4:	b7e5                	j	800059ac <sys_open+0xe4>
    if((ip = namei(path)) == 0){
    800059c6:	f5040513          	addi	a0,s0,-176
    800059ca:	ffffe097          	auipc	ra,0xffffe
    800059ce:	700080e7          	jalr	1792(ra) # 800040ca <namei>
    800059d2:	84aa                	mv	s1,a0
    800059d4:	c905                	beqz	a0,80005a04 <sys_open+0x13c>
    ilock(ip);
    800059d6:	ffffe097          	auipc	ra,0xffffe
    800059da:	f48080e7          	jalr	-184(ra) # 8000391e <ilock>
    if(ip->type == T_DIR && omode != O_RDONLY){
    800059de:	04449703          	lh	a4,68(s1)
    800059e2:	4785                	li	a5,1
    800059e4:	f4f711e3          	bne	a4,a5,80005926 <sys_open+0x5e>
    800059e8:	f4c42783          	lw	a5,-180(s0)
    800059ec:	d7b9                	beqz	a5,8000593a <sys_open+0x72>
      iunlockput(ip);
    800059ee:	8526                	mv	a0,s1
    800059f0:	ffffe097          	auipc	ra,0xffffe
    800059f4:	190080e7          	jalr	400(ra) # 80003b80 <iunlockput>
      end_op();
    800059f8:	fffff097          	auipc	ra,0xfffff
    800059fc:	970080e7          	jalr	-1680(ra) # 80004368 <end_op>
      return -1;
    80005a00:	557d                	li	a0,-1
    80005a02:	b76d                	j	800059ac <sys_open+0xe4>
      end_op();
    80005a04:	fffff097          	auipc	ra,0xfffff
    80005a08:	964080e7          	jalr	-1692(ra) # 80004368 <end_op>
      return -1;
    80005a0c:	557d                	li	a0,-1
    80005a0e:	bf79                	j	800059ac <sys_open+0xe4>
    iunlockput(ip);
    80005a10:	8526                	mv	a0,s1
    80005a12:	ffffe097          	auipc	ra,0xffffe
    80005a16:	16e080e7          	jalr	366(ra) # 80003b80 <iunlockput>
    end_op();
    80005a1a:	fffff097          	auipc	ra,0xfffff
    80005a1e:	94e080e7          	jalr	-1714(ra) # 80004368 <end_op>
    return -1;
    80005a22:	557d                	li	a0,-1
    80005a24:	b761                	j	800059ac <sys_open+0xe4>
    f->type = FD_DEVICE;
    80005a26:	00f9a023          	sw	a5,0(s3)
    f->major = ip->major;
    80005a2a:	04649783          	lh	a5,70(s1)
    80005a2e:	02f99223          	sh	a5,36(s3)
    80005a32:	bf25                	j	8000596a <sys_open+0xa2>
    itrunc(ip);
    80005a34:	8526                	mv	a0,s1
    80005a36:	ffffe097          	auipc	ra,0xffffe
    80005a3a:	ff6080e7          	jalr	-10(ra) # 80003a2c <itrunc>
    80005a3e:	bfa9                	j	80005998 <sys_open+0xd0>
      fileclose(f);
    80005a40:	854e                	mv	a0,s3
    80005a42:	fffff097          	auipc	ra,0xfffff
    80005a46:	d70080e7          	jalr	-656(ra) # 800047b2 <fileclose>
    iunlockput(ip);
    80005a4a:	8526                	mv	a0,s1
    80005a4c:	ffffe097          	auipc	ra,0xffffe
    80005a50:	134080e7          	jalr	308(ra) # 80003b80 <iunlockput>
    end_op();
    80005a54:	fffff097          	auipc	ra,0xfffff
    80005a58:	914080e7          	jalr	-1772(ra) # 80004368 <end_op>
    return -1;
    80005a5c:	557d                	li	a0,-1
    80005a5e:	b7b9                	j	800059ac <sys_open+0xe4>

0000000080005a60 <sys_mkdir>:

uint64
sys_mkdir(void)
{
    80005a60:	7175                	addi	sp,sp,-144
    80005a62:	e506                	sd	ra,136(sp)
    80005a64:	e122                	sd	s0,128(sp)
    80005a66:	0900                	addi	s0,sp,144
  char path[MAXPATH];
  struct inode *ip;

  begin_op();
    80005a68:	fffff097          	auipc	ra,0xfffff
    80005a6c:	882080e7          	jalr	-1918(ra) # 800042ea <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = create(path, T_DIR, 0, 0)) == 0){
    80005a70:	08000613          	li	a2,128
    80005a74:	f7040593          	addi	a1,s0,-144
    80005a78:	4501                	li	a0,0
    80005a7a:	ffffd097          	auipc	ra,0xffffd
    80005a7e:	1d6080e7          	jalr	470(ra) # 80002c50 <argstr>
    80005a82:	02054963          	bltz	a0,80005ab4 <sys_mkdir+0x54>
    80005a86:	4681                	li	a3,0
    80005a88:	4601                	li	a2,0
    80005a8a:	4585                	li	a1,1
    80005a8c:	f7040513          	addi	a0,s0,-144
    80005a90:	fffff097          	auipc	ra,0xfffff
    80005a94:	7fc080e7          	jalr	2044(ra) # 8000528c <create>
    80005a98:	cd11                	beqz	a0,80005ab4 <sys_mkdir+0x54>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005a9a:	ffffe097          	auipc	ra,0xffffe
    80005a9e:	0e6080e7          	jalr	230(ra) # 80003b80 <iunlockput>
  end_op();
    80005aa2:	fffff097          	auipc	ra,0xfffff
    80005aa6:	8c6080e7          	jalr	-1850(ra) # 80004368 <end_op>
  return 0;
    80005aaa:	4501                	li	a0,0
}
    80005aac:	60aa                	ld	ra,136(sp)
    80005aae:	640a                	ld	s0,128(sp)
    80005ab0:	6149                	addi	sp,sp,144
    80005ab2:	8082                	ret
    end_op();
    80005ab4:	fffff097          	auipc	ra,0xfffff
    80005ab8:	8b4080e7          	jalr	-1868(ra) # 80004368 <end_op>
    return -1;
    80005abc:	557d                	li	a0,-1
    80005abe:	b7fd                	j	80005aac <sys_mkdir+0x4c>

0000000080005ac0 <sys_mknod>:

uint64
sys_mknod(void)
{
    80005ac0:	7135                	addi	sp,sp,-160
    80005ac2:	ed06                	sd	ra,152(sp)
    80005ac4:	e922                	sd	s0,144(sp)
    80005ac6:	1100                	addi	s0,sp,160
  struct inode *ip;
  char path[MAXPATH];
  int major, minor;

  begin_op();
    80005ac8:	fffff097          	auipc	ra,0xfffff
    80005acc:	822080e7          	jalr	-2014(ra) # 800042ea <begin_op>
  argint(1, &major);
    80005ad0:	f6c40593          	addi	a1,s0,-148
    80005ad4:	4505                	li	a0,1
    80005ad6:	ffffd097          	auipc	ra,0xffffd
    80005ada:	13a080e7          	jalr	314(ra) # 80002c10 <argint>
  argint(2, &minor);
    80005ade:	f6840593          	addi	a1,s0,-152
    80005ae2:	4509                	li	a0,2
    80005ae4:	ffffd097          	auipc	ra,0xffffd
    80005ae8:	12c080e7          	jalr	300(ra) # 80002c10 <argint>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005aec:	08000613          	li	a2,128
    80005af0:	f7040593          	addi	a1,s0,-144
    80005af4:	4501                	li	a0,0
    80005af6:	ffffd097          	auipc	ra,0xffffd
    80005afa:	15a080e7          	jalr	346(ra) # 80002c50 <argstr>
    80005afe:	02054b63          	bltz	a0,80005b34 <sys_mknod+0x74>
     (ip = create(path, T_DEVICE, major, minor)) == 0){
    80005b02:	f6841683          	lh	a3,-152(s0)
    80005b06:	f6c41603          	lh	a2,-148(s0)
    80005b0a:	458d                	li	a1,3
    80005b0c:	f7040513          	addi	a0,s0,-144
    80005b10:	fffff097          	auipc	ra,0xfffff
    80005b14:	77c080e7          	jalr	1916(ra) # 8000528c <create>
  if((argstr(0, path, MAXPATH)) < 0 ||
    80005b18:	cd11                	beqz	a0,80005b34 <sys_mknod+0x74>
    end_op();
    return -1;
  }
  iunlockput(ip);
    80005b1a:	ffffe097          	auipc	ra,0xffffe
    80005b1e:	066080e7          	jalr	102(ra) # 80003b80 <iunlockput>
  end_op();
    80005b22:	fffff097          	auipc	ra,0xfffff
    80005b26:	846080e7          	jalr	-1978(ra) # 80004368 <end_op>
  return 0;
    80005b2a:	4501                	li	a0,0
}
    80005b2c:	60ea                	ld	ra,152(sp)
    80005b2e:	644a                	ld	s0,144(sp)
    80005b30:	610d                	addi	sp,sp,160
    80005b32:	8082                	ret
    end_op();
    80005b34:	fffff097          	auipc	ra,0xfffff
    80005b38:	834080e7          	jalr	-1996(ra) # 80004368 <end_op>
    return -1;
    80005b3c:	557d                	li	a0,-1
    80005b3e:	b7fd                	j	80005b2c <sys_mknod+0x6c>

0000000080005b40 <sys_chdir>:

uint64
sys_chdir(void)
{
    80005b40:	7135                	addi	sp,sp,-160
    80005b42:	ed06                	sd	ra,152(sp)
    80005b44:	e922                	sd	s0,144(sp)
    80005b46:	e526                	sd	s1,136(sp)
    80005b48:	e14a                	sd	s2,128(sp)
    80005b4a:	1100                	addi	s0,sp,160
  char path[MAXPATH];
  struct inode *ip;
  struct proc *p = myproc();
    80005b4c:	ffffc097          	auipc	ra,0xffffc
    80005b50:	fae080e7          	jalr	-82(ra) # 80001afa <myproc>
    80005b54:	892a                	mv	s2,a0
  
  begin_op();
    80005b56:	ffffe097          	auipc	ra,0xffffe
    80005b5a:	794080e7          	jalr	1940(ra) # 800042ea <begin_op>
  if(argstr(0, path, MAXPATH) < 0 || (ip = namei(path)) == 0){
    80005b5e:	08000613          	li	a2,128
    80005b62:	f6040593          	addi	a1,s0,-160
    80005b66:	4501                	li	a0,0
    80005b68:	ffffd097          	auipc	ra,0xffffd
    80005b6c:	0e8080e7          	jalr	232(ra) # 80002c50 <argstr>
    80005b70:	04054b63          	bltz	a0,80005bc6 <sys_chdir+0x86>
    80005b74:	f6040513          	addi	a0,s0,-160
    80005b78:	ffffe097          	auipc	ra,0xffffe
    80005b7c:	552080e7          	jalr	1362(ra) # 800040ca <namei>
    80005b80:	84aa                	mv	s1,a0
    80005b82:	c131                	beqz	a0,80005bc6 <sys_chdir+0x86>
    end_op();
    return -1;
  }
  ilock(ip);
    80005b84:	ffffe097          	auipc	ra,0xffffe
    80005b88:	d9a080e7          	jalr	-614(ra) # 8000391e <ilock>
  if(ip->type != T_DIR){
    80005b8c:	04449703          	lh	a4,68(s1)
    80005b90:	4785                	li	a5,1
    80005b92:	04f71063          	bne	a4,a5,80005bd2 <sys_chdir+0x92>
    iunlockput(ip);
    end_op();
    return -1;
  }
  iunlock(ip);
    80005b96:	8526                	mv	a0,s1
    80005b98:	ffffe097          	auipc	ra,0xffffe
    80005b9c:	e48080e7          	jalr	-440(ra) # 800039e0 <iunlock>
  iput(p->cwd);
    80005ba0:	15093503          	ld	a0,336(s2)
    80005ba4:	ffffe097          	auipc	ra,0xffffe
    80005ba8:	f34080e7          	jalr	-204(ra) # 80003ad8 <iput>
  end_op();
    80005bac:	ffffe097          	auipc	ra,0xffffe
    80005bb0:	7bc080e7          	jalr	1980(ra) # 80004368 <end_op>
  p->cwd = ip;
    80005bb4:	14993823          	sd	s1,336(s2)
  return 0;
    80005bb8:	4501                	li	a0,0
}
    80005bba:	60ea                	ld	ra,152(sp)
    80005bbc:	644a                	ld	s0,144(sp)
    80005bbe:	64aa                	ld	s1,136(sp)
    80005bc0:	690a                	ld	s2,128(sp)
    80005bc2:	610d                	addi	sp,sp,160
    80005bc4:	8082                	ret
    end_op();
    80005bc6:	ffffe097          	auipc	ra,0xffffe
    80005bca:	7a2080e7          	jalr	1954(ra) # 80004368 <end_op>
    return -1;
    80005bce:	557d                	li	a0,-1
    80005bd0:	b7ed                	j	80005bba <sys_chdir+0x7a>
    iunlockput(ip);
    80005bd2:	8526                	mv	a0,s1
    80005bd4:	ffffe097          	auipc	ra,0xffffe
    80005bd8:	fac080e7          	jalr	-84(ra) # 80003b80 <iunlockput>
    end_op();
    80005bdc:	ffffe097          	auipc	ra,0xffffe
    80005be0:	78c080e7          	jalr	1932(ra) # 80004368 <end_op>
    return -1;
    80005be4:	557d                	li	a0,-1
    80005be6:	bfd1                	j	80005bba <sys_chdir+0x7a>

0000000080005be8 <sys_exec>:

uint64
sys_exec(void)
{
    80005be8:	7145                	addi	sp,sp,-464
    80005bea:	e786                	sd	ra,456(sp)
    80005bec:	e3a2                	sd	s0,448(sp)
    80005bee:	ff26                	sd	s1,440(sp)
    80005bf0:	fb4a                	sd	s2,432(sp)
    80005bf2:	f74e                	sd	s3,424(sp)
    80005bf4:	f352                	sd	s4,416(sp)
    80005bf6:	ef56                	sd	s5,408(sp)
    80005bf8:	0b80                	addi	s0,sp,464
  char path[MAXPATH], *argv[MAXARG];
  int i;
  uint64 uargv, uarg;

  argaddr(1, &uargv);
    80005bfa:	e3840593          	addi	a1,s0,-456
    80005bfe:	4505                	li	a0,1
    80005c00:	ffffd097          	auipc	ra,0xffffd
    80005c04:	030080e7          	jalr	48(ra) # 80002c30 <argaddr>
  if(argstr(0, path, MAXPATH) < 0) {
    80005c08:	08000613          	li	a2,128
    80005c0c:	f4040593          	addi	a1,s0,-192
    80005c10:	4501                	li	a0,0
    80005c12:	ffffd097          	auipc	ra,0xffffd
    80005c16:	03e080e7          	jalr	62(ra) # 80002c50 <argstr>
    80005c1a:	87aa                	mv	a5,a0
    return -1;
    80005c1c:	557d                	li	a0,-1
  if(argstr(0, path, MAXPATH) < 0) {
    80005c1e:	0c07c363          	bltz	a5,80005ce4 <sys_exec+0xfc>
  }
  memset(argv, 0, sizeof(argv));
    80005c22:	10000613          	li	a2,256
    80005c26:	4581                	li	a1,0
    80005c28:	e4040513          	addi	a0,s0,-448
    80005c2c:	ffffb097          	auipc	ra,0xffffb
    80005c30:	0a6080e7          	jalr	166(ra) # 80000cd2 <memset>
  for(i=0;; i++){
    if(i >= NELEM(argv)){
    80005c34:	e4040493          	addi	s1,s0,-448
  memset(argv, 0, sizeof(argv));
    80005c38:	89a6                	mv	s3,s1
    80005c3a:	4901                	li	s2,0
    if(i >= NELEM(argv)){
    80005c3c:	02000a13          	li	s4,32
    80005c40:	00090a9b          	sext.w	s5,s2
      goto bad;
    }
    if(fetchaddr(uargv+sizeof(uint64)*i, (uint64*)&uarg) < 0){
    80005c44:	00391513          	slli	a0,s2,0x3
    80005c48:	e3040593          	addi	a1,s0,-464
    80005c4c:	e3843783          	ld	a5,-456(s0)
    80005c50:	953e                	add	a0,a0,a5
    80005c52:	ffffd097          	auipc	ra,0xffffd
    80005c56:	f20080e7          	jalr	-224(ra) # 80002b72 <fetchaddr>
    80005c5a:	02054a63          	bltz	a0,80005c8e <sys_exec+0xa6>
      goto bad;
    }
    if(uarg == 0){
    80005c5e:	e3043783          	ld	a5,-464(s0)
    80005c62:	c3b9                	beqz	a5,80005ca8 <sys_exec+0xc0>
      argv[i] = 0;
      break;
    }
    argv[i] = kalloc();
    80005c64:	ffffb097          	auipc	ra,0xffffb
    80005c68:	e82080e7          	jalr	-382(ra) # 80000ae6 <kalloc>
    80005c6c:	85aa                	mv	a1,a0
    80005c6e:	00a9b023          	sd	a0,0(s3)
    if(argv[i] == 0)
    80005c72:	cd11                	beqz	a0,80005c8e <sys_exec+0xa6>
      goto bad;
    if(fetchstr(uarg, argv[i], PGSIZE) < 0)
    80005c74:	6605                	lui	a2,0x1
    80005c76:	e3043503          	ld	a0,-464(s0)
    80005c7a:	ffffd097          	auipc	ra,0xffffd
    80005c7e:	f4a080e7          	jalr	-182(ra) # 80002bc4 <fetchstr>
    80005c82:	00054663          	bltz	a0,80005c8e <sys_exec+0xa6>
    if(i >= NELEM(argv)){
    80005c86:	0905                	addi	s2,s2,1
    80005c88:	09a1                	addi	s3,s3,8
    80005c8a:	fb491be3          	bne	s2,s4,80005c40 <sys_exec+0x58>
    kfree(argv[i]);

  return ret;

 bad:
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c8e:	f4040913          	addi	s2,s0,-192
    80005c92:	6088                	ld	a0,0(s1)
    80005c94:	c539                	beqz	a0,80005ce2 <sys_exec+0xfa>
    kfree(argv[i]);
    80005c96:	ffffb097          	auipc	ra,0xffffb
    80005c9a:	d52080e7          	jalr	-686(ra) # 800009e8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005c9e:	04a1                	addi	s1,s1,8
    80005ca0:	ff2499e3          	bne	s1,s2,80005c92 <sys_exec+0xaa>
  return -1;
    80005ca4:	557d                	li	a0,-1
    80005ca6:	a83d                	j	80005ce4 <sys_exec+0xfc>
      argv[i] = 0;
    80005ca8:	0a8e                	slli	s5,s5,0x3
    80005caa:	fc0a8793          	addi	a5,s5,-64
    80005cae:	00878ab3          	add	s5,a5,s0
    80005cb2:	e80ab023          	sd	zero,-384(s5)
  int ret = exec(path, argv);
    80005cb6:	e4040593          	addi	a1,s0,-448
    80005cba:	f4040513          	addi	a0,s0,-192
    80005cbe:	fffff097          	auipc	ra,0xfffff
    80005cc2:	16e080e7          	jalr	366(ra) # 80004e2c <exec>
    80005cc6:	892a                	mv	s2,a0
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cc8:	f4040993          	addi	s3,s0,-192
    80005ccc:	6088                	ld	a0,0(s1)
    80005cce:	c901                	beqz	a0,80005cde <sys_exec+0xf6>
    kfree(argv[i]);
    80005cd0:	ffffb097          	auipc	ra,0xffffb
    80005cd4:	d18080e7          	jalr	-744(ra) # 800009e8 <kfree>
  for(i = 0; i < NELEM(argv) && argv[i] != 0; i++)
    80005cd8:	04a1                	addi	s1,s1,8
    80005cda:	ff3499e3          	bne	s1,s3,80005ccc <sys_exec+0xe4>
  return ret;
    80005cde:	854a                	mv	a0,s2
    80005ce0:	a011                	j	80005ce4 <sys_exec+0xfc>
  return -1;
    80005ce2:	557d                	li	a0,-1
}
    80005ce4:	60be                	ld	ra,456(sp)
    80005ce6:	641e                	ld	s0,448(sp)
    80005ce8:	74fa                	ld	s1,440(sp)
    80005cea:	795a                	ld	s2,432(sp)
    80005cec:	79ba                	ld	s3,424(sp)
    80005cee:	7a1a                	ld	s4,416(sp)
    80005cf0:	6afa                	ld	s5,408(sp)
    80005cf2:	6179                	addi	sp,sp,464
    80005cf4:	8082                	ret

0000000080005cf6 <sys_pipe>:

uint64
sys_pipe(void)
{
    80005cf6:	7139                	addi	sp,sp,-64
    80005cf8:	fc06                	sd	ra,56(sp)
    80005cfa:	f822                	sd	s0,48(sp)
    80005cfc:	f426                	sd	s1,40(sp)
    80005cfe:	0080                	addi	s0,sp,64
  uint64 fdarray; // user pointer to array of two integers
  struct file *rf, *wf;
  int fd0, fd1;
  struct proc *p = myproc();
    80005d00:	ffffc097          	auipc	ra,0xffffc
    80005d04:	dfa080e7          	jalr	-518(ra) # 80001afa <myproc>
    80005d08:	84aa                	mv	s1,a0

  argaddr(0, &fdarray);
    80005d0a:	fd840593          	addi	a1,s0,-40
    80005d0e:	4501                	li	a0,0
    80005d10:	ffffd097          	auipc	ra,0xffffd
    80005d14:	f20080e7          	jalr	-224(ra) # 80002c30 <argaddr>
  if(pipealloc(&rf, &wf) < 0)
    80005d18:	fc840593          	addi	a1,s0,-56
    80005d1c:	fd040513          	addi	a0,s0,-48
    80005d20:	fffff097          	auipc	ra,0xfffff
    80005d24:	dc2080e7          	jalr	-574(ra) # 80004ae2 <pipealloc>
    return -1;
    80005d28:	57fd                	li	a5,-1
  if(pipealloc(&rf, &wf) < 0)
    80005d2a:	0c054463          	bltz	a0,80005df2 <sys_pipe+0xfc>
  fd0 = -1;
    80005d2e:	fcf42223          	sw	a5,-60(s0)
  if((fd0 = fdalloc(rf)) < 0 || (fd1 = fdalloc(wf)) < 0){
    80005d32:	fd043503          	ld	a0,-48(s0)
    80005d36:	fffff097          	auipc	ra,0xfffff
    80005d3a:	514080e7          	jalr	1300(ra) # 8000524a <fdalloc>
    80005d3e:	fca42223          	sw	a0,-60(s0)
    80005d42:	08054b63          	bltz	a0,80005dd8 <sys_pipe+0xe2>
    80005d46:	fc843503          	ld	a0,-56(s0)
    80005d4a:	fffff097          	auipc	ra,0xfffff
    80005d4e:	500080e7          	jalr	1280(ra) # 8000524a <fdalloc>
    80005d52:	fca42023          	sw	a0,-64(s0)
    80005d56:	06054863          	bltz	a0,80005dc6 <sys_pipe+0xd0>
      p->ofile[fd0] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d5a:	4691                	li	a3,4
    80005d5c:	fc440613          	addi	a2,s0,-60
    80005d60:	fd843583          	ld	a1,-40(s0)
    80005d64:	68a8                	ld	a0,80(s1)
    80005d66:	ffffc097          	auipc	ra,0xffffc
    80005d6a:	906080e7          	jalr	-1786(ra) # 8000166c <copyout>
    80005d6e:	02054063          	bltz	a0,80005d8e <sys_pipe+0x98>
     copyout(p->pagetable, fdarray+sizeof(fd0), (char *)&fd1, sizeof(fd1)) < 0){
    80005d72:	4691                	li	a3,4
    80005d74:	fc040613          	addi	a2,s0,-64
    80005d78:	fd843583          	ld	a1,-40(s0)
    80005d7c:	0591                	addi	a1,a1,4
    80005d7e:	68a8                	ld	a0,80(s1)
    80005d80:	ffffc097          	auipc	ra,0xffffc
    80005d84:	8ec080e7          	jalr	-1812(ra) # 8000166c <copyout>
    p->ofile[fd1] = 0;
    fileclose(rf);
    fileclose(wf);
    return -1;
  }
  return 0;
    80005d88:	4781                	li	a5,0
  if(copyout(p->pagetable, fdarray, (char*)&fd0, sizeof(fd0)) < 0 ||
    80005d8a:	06055463          	bgez	a0,80005df2 <sys_pipe+0xfc>
    p->ofile[fd0] = 0;
    80005d8e:	fc442783          	lw	a5,-60(s0)
    80005d92:	07e9                	addi	a5,a5,26
    80005d94:	078e                	slli	a5,a5,0x3
    80005d96:	97a6                	add	a5,a5,s1
    80005d98:	0007b023          	sd	zero,0(a5)
    p->ofile[fd1] = 0;
    80005d9c:	fc042783          	lw	a5,-64(s0)
    80005da0:	07e9                	addi	a5,a5,26
    80005da2:	078e                	slli	a5,a5,0x3
    80005da4:	94be                	add	s1,s1,a5
    80005da6:	0004b023          	sd	zero,0(s1)
    fileclose(rf);
    80005daa:	fd043503          	ld	a0,-48(s0)
    80005dae:	fffff097          	auipc	ra,0xfffff
    80005db2:	a04080e7          	jalr	-1532(ra) # 800047b2 <fileclose>
    fileclose(wf);
    80005db6:	fc843503          	ld	a0,-56(s0)
    80005dba:	fffff097          	auipc	ra,0xfffff
    80005dbe:	9f8080e7          	jalr	-1544(ra) # 800047b2 <fileclose>
    return -1;
    80005dc2:	57fd                	li	a5,-1
    80005dc4:	a03d                	j	80005df2 <sys_pipe+0xfc>
    if(fd0 >= 0)
    80005dc6:	fc442783          	lw	a5,-60(s0)
    80005dca:	0007c763          	bltz	a5,80005dd8 <sys_pipe+0xe2>
      p->ofile[fd0] = 0;
    80005dce:	07e9                	addi	a5,a5,26
    80005dd0:	078e                	slli	a5,a5,0x3
    80005dd2:	97a6                	add	a5,a5,s1
    80005dd4:	0007b023          	sd	zero,0(a5)
    fileclose(rf);
    80005dd8:	fd043503          	ld	a0,-48(s0)
    80005ddc:	fffff097          	auipc	ra,0xfffff
    80005de0:	9d6080e7          	jalr	-1578(ra) # 800047b2 <fileclose>
    fileclose(wf);
    80005de4:	fc843503          	ld	a0,-56(s0)
    80005de8:	fffff097          	auipc	ra,0xfffff
    80005dec:	9ca080e7          	jalr	-1590(ra) # 800047b2 <fileclose>
    return -1;
    80005df0:	57fd                	li	a5,-1
}
    80005df2:	853e                	mv	a0,a5
    80005df4:	70e2                	ld	ra,56(sp)
    80005df6:	7442                	ld	s0,48(sp)
    80005df8:	74a2                	ld	s1,40(sp)
    80005dfa:	6121                	addi	sp,sp,64
    80005dfc:	8082                	ret
	...

0000000080005e00 <kernelvec>:
    80005e00:	7111                	addi	sp,sp,-256
    80005e02:	e006                	sd	ra,0(sp)
    80005e04:	e40a                	sd	sp,8(sp)
    80005e06:	e80e                	sd	gp,16(sp)
    80005e08:	ec12                	sd	tp,24(sp)
    80005e0a:	f016                	sd	t0,32(sp)
    80005e0c:	f41a                	sd	t1,40(sp)
    80005e0e:	f81e                	sd	t2,48(sp)
    80005e10:	fc22                	sd	s0,56(sp)
    80005e12:	e0a6                	sd	s1,64(sp)
    80005e14:	e4aa                	sd	a0,72(sp)
    80005e16:	e8ae                	sd	a1,80(sp)
    80005e18:	ecb2                	sd	a2,88(sp)
    80005e1a:	f0b6                	sd	a3,96(sp)
    80005e1c:	f4ba                	sd	a4,104(sp)
    80005e1e:	f8be                	sd	a5,112(sp)
    80005e20:	fcc2                	sd	a6,120(sp)
    80005e22:	e146                	sd	a7,128(sp)
    80005e24:	e54a                	sd	s2,136(sp)
    80005e26:	e94e                	sd	s3,144(sp)
    80005e28:	ed52                	sd	s4,152(sp)
    80005e2a:	f156                	sd	s5,160(sp)
    80005e2c:	f55a                	sd	s6,168(sp)
    80005e2e:	f95e                	sd	s7,176(sp)
    80005e30:	fd62                	sd	s8,184(sp)
    80005e32:	e1e6                	sd	s9,192(sp)
    80005e34:	e5ea                	sd	s10,200(sp)
    80005e36:	e9ee                	sd	s11,208(sp)
    80005e38:	edf2                	sd	t3,216(sp)
    80005e3a:	f1f6                	sd	t4,224(sp)
    80005e3c:	f5fa                	sd	t5,232(sp)
    80005e3e:	f9fe                	sd	t6,240(sp)
    80005e40:	bfffc0ef          	jal	ra,80002a3e <kerneltrap>
    80005e44:	6082                	ld	ra,0(sp)
    80005e46:	6122                	ld	sp,8(sp)
    80005e48:	61c2                	ld	gp,16(sp)
    80005e4a:	7282                	ld	t0,32(sp)
    80005e4c:	7322                	ld	t1,40(sp)
    80005e4e:	73c2                	ld	t2,48(sp)
    80005e50:	7462                	ld	s0,56(sp)
    80005e52:	6486                	ld	s1,64(sp)
    80005e54:	6526                	ld	a0,72(sp)
    80005e56:	65c6                	ld	a1,80(sp)
    80005e58:	6666                	ld	a2,88(sp)
    80005e5a:	7686                	ld	a3,96(sp)
    80005e5c:	7726                	ld	a4,104(sp)
    80005e5e:	77c6                	ld	a5,112(sp)
    80005e60:	7866                	ld	a6,120(sp)
    80005e62:	688a                	ld	a7,128(sp)
    80005e64:	692a                	ld	s2,136(sp)
    80005e66:	69ca                	ld	s3,144(sp)
    80005e68:	6a6a                	ld	s4,152(sp)
    80005e6a:	7a8a                	ld	s5,160(sp)
    80005e6c:	7b2a                	ld	s6,168(sp)
    80005e6e:	7bca                	ld	s7,176(sp)
    80005e70:	7c6a                	ld	s8,184(sp)
    80005e72:	6c8e                	ld	s9,192(sp)
    80005e74:	6d2e                	ld	s10,200(sp)
    80005e76:	6dce                	ld	s11,208(sp)
    80005e78:	6e6e                	ld	t3,216(sp)
    80005e7a:	7e8e                	ld	t4,224(sp)
    80005e7c:	7f2e                	ld	t5,232(sp)
    80005e7e:	7fce                	ld	t6,240(sp)
    80005e80:	6111                	addi	sp,sp,256
    80005e82:	10200073          	sret
    80005e86:	00000013          	nop
    80005e8a:	00000013          	nop
    80005e8e:	0001                	nop

0000000080005e90 <timervec>:
    80005e90:	34051573          	csrrw	a0,mscratch,a0
    80005e94:	e10c                	sd	a1,0(a0)
    80005e96:	e510                	sd	a2,8(a0)
    80005e98:	e914                	sd	a3,16(a0)
    80005e9a:	6d0c                	ld	a1,24(a0)
    80005e9c:	7110                	ld	a2,32(a0)
    80005e9e:	6194                	ld	a3,0(a1)
    80005ea0:	96b2                	add	a3,a3,a2
    80005ea2:	e194                	sd	a3,0(a1)
    80005ea4:	4589                	li	a1,2
    80005ea6:	14459073          	csrw	sip,a1
    80005eaa:	6914                	ld	a3,16(a0)
    80005eac:	6510                	ld	a2,8(a0)
    80005eae:	610c                	ld	a1,0(a0)
    80005eb0:	34051573          	csrrw	a0,mscratch,a0
    80005eb4:	30200073          	mret
	...

0000000080005eba <plicinit>:
// the riscv Platform Level Interrupt Controller (PLIC).
//

void
plicinit(void)
{
    80005eba:	1141                	addi	sp,sp,-16
    80005ebc:	e422                	sd	s0,8(sp)
    80005ebe:	0800                	addi	s0,sp,16
  // set desired IRQ priorities non-zero (otherwise disabled).
  *(uint32*)(PLIC + UART0_IRQ*4) = 1;
    80005ec0:	0c0007b7          	lui	a5,0xc000
    80005ec4:	4705                	li	a4,1
    80005ec6:	d798                	sw	a4,40(a5)
  *(uint32*)(PLIC + VIRTIO0_IRQ*4) = 1;
    80005ec8:	c3d8                	sw	a4,4(a5)
}
    80005eca:	6422                	ld	s0,8(sp)
    80005ecc:	0141                	addi	sp,sp,16
    80005ece:	8082                	ret

0000000080005ed0 <plicinithart>:

void
plicinithart(void)
{
    80005ed0:	1141                	addi	sp,sp,-16
    80005ed2:	e406                	sd	ra,8(sp)
    80005ed4:	e022                	sd	s0,0(sp)
    80005ed6:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005ed8:	ffffc097          	auipc	ra,0xffffc
    80005edc:	bf6080e7          	jalr	-1034(ra) # 80001ace <cpuid>
  
  // set enable bits for this hart's S-mode
  // for the uart and virtio disk.
  *(uint32*)PLIC_SENABLE(hart) = (1 << UART0_IRQ) | (1 << VIRTIO0_IRQ);
    80005ee0:	0085171b          	slliw	a4,a0,0x8
    80005ee4:	0c0027b7          	lui	a5,0xc002
    80005ee8:	97ba                	add	a5,a5,a4
    80005eea:	40200713          	li	a4,1026
    80005eee:	08e7a023          	sw	a4,128(a5) # c002080 <_entry-0x73ffdf80>

  // set this hart's S-mode priority threshold to 0.
  *(uint32*)PLIC_SPRIORITY(hart) = 0;
    80005ef2:	00d5151b          	slliw	a0,a0,0xd
    80005ef6:	0c2017b7          	lui	a5,0xc201
    80005efa:	97aa                	add	a5,a5,a0
    80005efc:	0007a023          	sw	zero,0(a5) # c201000 <_entry-0x73dff000>
}
    80005f00:	60a2                	ld	ra,8(sp)
    80005f02:	6402                	ld	s0,0(sp)
    80005f04:	0141                	addi	sp,sp,16
    80005f06:	8082                	ret

0000000080005f08 <plic_claim>:

// ask the PLIC what interrupt we should serve.
int
plic_claim(void)
{
    80005f08:	1141                	addi	sp,sp,-16
    80005f0a:	e406                	sd	ra,8(sp)
    80005f0c:	e022                	sd	s0,0(sp)
    80005f0e:	0800                	addi	s0,sp,16
  int hart = cpuid();
    80005f10:	ffffc097          	auipc	ra,0xffffc
    80005f14:	bbe080e7          	jalr	-1090(ra) # 80001ace <cpuid>
  int irq = *(uint32*)PLIC_SCLAIM(hart);
    80005f18:	00d5151b          	slliw	a0,a0,0xd
    80005f1c:	0c2017b7          	lui	a5,0xc201
    80005f20:	97aa                	add	a5,a5,a0
  return irq;
}
    80005f22:	43c8                	lw	a0,4(a5)
    80005f24:	60a2                	ld	ra,8(sp)
    80005f26:	6402                	ld	s0,0(sp)
    80005f28:	0141                	addi	sp,sp,16
    80005f2a:	8082                	ret

0000000080005f2c <plic_complete>:

// tell the PLIC we've served this IRQ.
void
plic_complete(int irq)
{
    80005f2c:	1101                	addi	sp,sp,-32
    80005f2e:	ec06                	sd	ra,24(sp)
    80005f30:	e822                	sd	s0,16(sp)
    80005f32:	e426                	sd	s1,8(sp)
    80005f34:	1000                	addi	s0,sp,32
    80005f36:	84aa                	mv	s1,a0
  int hart = cpuid();
    80005f38:	ffffc097          	auipc	ra,0xffffc
    80005f3c:	b96080e7          	jalr	-1130(ra) # 80001ace <cpuid>
  *(uint32*)PLIC_SCLAIM(hart) = irq;
    80005f40:	00d5151b          	slliw	a0,a0,0xd
    80005f44:	0c2017b7          	lui	a5,0xc201
    80005f48:	97aa                	add	a5,a5,a0
    80005f4a:	c3c4                	sw	s1,4(a5)
}
    80005f4c:	60e2                	ld	ra,24(sp)
    80005f4e:	6442                	ld	s0,16(sp)
    80005f50:	64a2                	ld	s1,8(sp)
    80005f52:	6105                	addi	sp,sp,32
    80005f54:	8082                	ret

0000000080005f56 <free_desc>:
}

// mark a descriptor as free.
static void
free_desc(int i)
{
    80005f56:	1141                	addi	sp,sp,-16
    80005f58:	e406                	sd	ra,8(sp)
    80005f5a:	e022                	sd	s0,0(sp)
    80005f5c:	0800                	addi	s0,sp,16
  if(i >= NUM)
    80005f5e:	479d                	li	a5,7
    80005f60:	04a7cc63          	blt	a5,a0,80005fb8 <free_desc+0x62>
    panic("free_desc 1");
  if(disk.free[i])
    80005f64:	0001c797          	auipc	a5,0x1c
    80005f68:	d3c78793          	addi	a5,a5,-708 # 80021ca0 <disk>
    80005f6c:	97aa                	add	a5,a5,a0
    80005f6e:	0187c783          	lbu	a5,24(a5)
    80005f72:	ebb9                	bnez	a5,80005fc8 <free_desc+0x72>
    panic("free_desc 2");
  disk.desc[i].addr = 0;
    80005f74:	00451693          	slli	a3,a0,0x4
    80005f78:	0001c797          	auipc	a5,0x1c
    80005f7c:	d2878793          	addi	a5,a5,-728 # 80021ca0 <disk>
    80005f80:	6398                	ld	a4,0(a5)
    80005f82:	9736                	add	a4,a4,a3
    80005f84:	00073023          	sd	zero,0(a4)
  disk.desc[i].len = 0;
    80005f88:	6398                	ld	a4,0(a5)
    80005f8a:	9736                	add	a4,a4,a3
    80005f8c:	00072423          	sw	zero,8(a4)
  disk.desc[i].flags = 0;
    80005f90:	00071623          	sh	zero,12(a4)
  disk.desc[i].next = 0;
    80005f94:	00071723          	sh	zero,14(a4)
  disk.free[i] = 1;
    80005f98:	97aa                	add	a5,a5,a0
    80005f9a:	4705                	li	a4,1
    80005f9c:	00e78c23          	sb	a4,24(a5)
  wakeup(&disk.free[0]);
    80005fa0:	0001c517          	auipc	a0,0x1c
    80005fa4:	d1850513          	addi	a0,a0,-744 # 80021cb8 <disk+0x18>
    80005fa8:	ffffc097          	auipc	ra,0xffffc
    80005fac:	25e080e7          	jalr	606(ra) # 80002206 <wakeup>
}
    80005fb0:	60a2                	ld	ra,8(sp)
    80005fb2:	6402                	ld	s0,0(sp)
    80005fb4:	0141                	addi	sp,sp,16
    80005fb6:	8082                	ret
    panic("free_desc 1");
    80005fb8:	00003517          	auipc	a0,0x3
    80005fbc:	80050513          	addi	a0,a0,-2048 # 800087b8 <syscalls+0x308>
    80005fc0:	ffffa097          	auipc	ra,0xffffa
    80005fc4:	580080e7          	jalr	1408(ra) # 80000540 <panic>
    panic("free_desc 2");
    80005fc8:	00003517          	auipc	a0,0x3
    80005fcc:	80050513          	addi	a0,a0,-2048 # 800087c8 <syscalls+0x318>
    80005fd0:	ffffa097          	auipc	ra,0xffffa
    80005fd4:	570080e7          	jalr	1392(ra) # 80000540 <panic>

0000000080005fd8 <virtio_disk_init>:
{
    80005fd8:	1101                	addi	sp,sp,-32
    80005fda:	ec06                	sd	ra,24(sp)
    80005fdc:	e822                	sd	s0,16(sp)
    80005fde:	e426                	sd	s1,8(sp)
    80005fe0:	e04a                	sd	s2,0(sp)
    80005fe2:	1000                	addi	s0,sp,32
  initlock(&disk.vdisk_lock, "virtio_disk");
    80005fe4:	00002597          	auipc	a1,0x2
    80005fe8:	7f458593          	addi	a1,a1,2036 # 800087d8 <syscalls+0x328>
    80005fec:	0001c517          	auipc	a0,0x1c
    80005ff0:	ddc50513          	addi	a0,a0,-548 # 80021dc8 <disk+0x128>
    80005ff4:	ffffb097          	auipc	ra,0xffffb
    80005ff8:	b52080e7          	jalr	-1198(ra) # 80000b46 <initlock>
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80005ffc:	100017b7          	lui	a5,0x10001
    80006000:	4398                	lw	a4,0(a5)
    80006002:	2701                	sext.w	a4,a4
    80006004:	747277b7          	lui	a5,0x74727
    80006008:	97678793          	addi	a5,a5,-1674 # 74726976 <_entry-0xb8d968a>
    8000600c:	14f71b63          	bne	a4,a5,80006162 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006010:	100017b7          	lui	a5,0x10001
    80006014:	43dc                	lw	a5,4(a5)
    80006016:	2781                	sext.w	a5,a5
  if(*R(VIRTIO_MMIO_MAGIC_VALUE) != 0x74726976 ||
    80006018:	4709                	li	a4,2
    8000601a:	14e79463          	bne	a5,a4,80006162 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    8000601e:	100017b7          	lui	a5,0x10001
    80006022:	479c                	lw	a5,8(a5)
    80006024:	2781                	sext.w	a5,a5
     *R(VIRTIO_MMIO_VERSION) != 2 ||
    80006026:	12e79e63          	bne	a5,a4,80006162 <virtio_disk_init+0x18a>
     *R(VIRTIO_MMIO_VENDOR_ID) != 0x554d4551){
    8000602a:	100017b7          	lui	a5,0x10001
    8000602e:	47d8                	lw	a4,12(a5)
    80006030:	2701                	sext.w	a4,a4
     *R(VIRTIO_MMIO_DEVICE_ID) != 2 ||
    80006032:	554d47b7          	lui	a5,0x554d4
    80006036:	55178793          	addi	a5,a5,1361 # 554d4551 <_entry-0x2ab2baaf>
    8000603a:	12f71463          	bne	a4,a5,80006162 <virtio_disk_init+0x18a>
  *R(VIRTIO_MMIO_STATUS) = status;
    8000603e:	100017b7          	lui	a5,0x10001
    80006042:	0607a823          	sw	zero,112(a5) # 10001070 <_entry-0x6fffef90>
  *R(VIRTIO_MMIO_STATUS) = status;
    80006046:	4705                	li	a4,1
    80006048:	dbb8                	sw	a4,112(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000604a:	470d                	li	a4,3
    8000604c:	dbb8                	sw	a4,112(a5)
  uint64 features = *R(VIRTIO_MMIO_DEVICE_FEATURES);
    8000604e:	4b98                	lw	a4,16(a5)
  *R(VIRTIO_MMIO_DRIVER_FEATURES) = features;
    80006050:	c7ffe6b7          	lui	a3,0xc7ffe
    80006054:	75f68693          	addi	a3,a3,1887 # ffffffffc7ffe75f <end+0xffffffff47fdc97f>
    80006058:	8f75                	and	a4,a4,a3
    8000605a:	d398                	sw	a4,32(a5)
  *R(VIRTIO_MMIO_STATUS) = status;
    8000605c:	472d                	li	a4,11
    8000605e:	dbb8                	sw	a4,112(a5)
  status = *R(VIRTIO_MMIO_STATUS);
    80006060:	5bbc                	lw	a5,112(a5)
    80006062:	0007891b          	sext.w	s2,a5
  if(!(status & VIRTIO_CONFIG_S_FEATURES_OK))
    80006066:	8ba1                	andi	a5,a5,8
    80006068:	10078563          	beqz	a5,80006172 <virtio_disk_init+0x19a>
  *R(VIRTIO_MMIO_QUEUE_SEL) = 0;
    8000606c:	100017b7          	lui	a5,0x10001
    80006070:	0207a823          	sw	zero,48(a5) # 10001030 <_entry-0x6fffefd0>
  if(*R(VIRTIO_MMIO_QUEUE_READY))
    80006074:	43fc                	lw	a5,68(a5)
    80006076:	2781                	sext.w	a5,a5
    80006078:	10079563          	bnez	a5,80006182 <virtio_disk_init+0x1aa>
  uint32 max = *R(VIRTIO_MMIO_QUEUE_NUM_MAX);
    8000607c:	100017b7          	lui	a5,0x10001
    80006080:	5bdc                	lw	a5,52(a5)
    80006082:	2781                	sext.w	a5,a5
  if(max == 0)
    80006084:	10078763          	beqz	a5,80006192 <virtio_disk_init+0x1ba>
  if(max < NUM)
    80006088:	471d                	li	a4,7
    8000608a:	10f77c63          	bgeu	a4,a5,800061a2 <virtio_disk_init+0x1ca>
  disk.desc = kalloc();
    8000608e:	ffffb097          	auipc	ra,0xffffb
    80006092:	a58080e7          	jalr	-1448(ra) # 80000ae6 <kalloc>
    80006096:	0001c497          	auipc	s1,0x1c
    8000609a:	c0a48493          	addi	s1,s1,-1014 # 80021ca0 <disk>
    8000609e:	e088                	sd	a0,0(s1)
  disk.avail = kalloc();
    800060a0:	ffffb097          	auipc	ra,0xffffb
    800060a4:	a46080e7          	jalr	-1466(ra) # 80000ae6 <kalloc>
    800060a8:	e488                	sd	a0,8(s1)
  disk.used = kalloc();
    800060aa:	ffffb097          	auipc	ra,0xffffb
    800060ae:	a3c080e7          	jalr	-1476(ra) # 80000ae6 <kalloc>
    800060b2:	87aa                	mv	a5,a0
    800060b4:	e888                	sd	a0,16(s1)
  if(!disk.desc || !disk.avail || !disk.used)
    800060b6:	6088                	ld	a0,0(s1)
    800060b8:	cd6d                	beqz	a0,800061b2 <virtio_disk_init+0x1da>
    800060ba:	0001c717          	auipc	a4,0x1c
    800060be:	bee73703          	ld	a4,-1042(a4) # 80021ca8 <disk+0x8>
    800060c2:	cb65                	beqz	a4,800061b2 <virtio_disk_init+0x1da>
    800060c4:	c7fd                	beqz	a5,800061b2 <virtio_disk_init+0x1da>
  memset(disk.desc, 0, PGSIZE);
    800060c6:	6605                	lui	a2,0x1
    800060c8:	4581                	li	a1,0
    800060ca:	ffffb097          	auipc	ra,0xffffb
    800060ce:	c08080e7          	jalr	-1016(ra) # 80000cd2 <memset>
  memset(disk.avail, 0, PGSIZE);
    800060d2:	0001c497          	auipc	s1,0x1c
    800060d6:	bce48493          	addi	s1,s1,-1074 # 80021ca0 <disk>
    800060da:	6605                	lui	a2,0x1
    800060dc:	4581                	li	a1,0
    800060de:	6488                	ld	a0,8(s1)
    800060e0:	ffffb097          	auipc	ra,0xffffb
    800060e4:	bf2080e7          	jalr	-1038(ra) # 80000cd2 <memset>
  memset(disk.used, 0, PGSIZE);
    800060e8:	6605                	lui	a2,0x1
    800060ea:	4581                	li	a1,0
    800060ec:	6888                	ld	a0,16(s1)
    800060ee:	ffffb097          	auipc	ra,0xffffb
    800060f2:	be4080e7          	jalr	-1052(ra) # 80000cd2 <memset>
  *R(VIRTIO_MMIO_QUEUE_NUM) = NUM;
    800060f6:	100017b7          	lui	a5,0x10001
    800060fa:	4721                	li	a4,8
    800060fc:	df98                	sw	a4,56(a5)
  *R(VIRTIO_MMIO_QUEUE_DESC_LOW) = (uint64)disk.desc;
    800060fe:	4098                	lw	a4,0(s1)
    80006100:	08e7a023          	sw	a4,128(a5) # 10001080 <_entry-0x6fffef80>
  *R(VIRTIO_MMIO_QUEUE_DESC_HIGH) = (uint64)disk.desc >> 32;
    80006104:	40d8                	lw	a4,4(s1)
    80006106:	08e7a223          	sw	a4,132(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_LOW) = (uint64)disk.avail;
    8000610a:	6498                	ld	a4,8(s1)
    8000610c:	0007069b          	sext.w	a3,a4
    80006110:	08d7a823          	sw	a3,144(a5)
  *R(VIRTIO_MMIO_DRIVER_DESC_HIGH) = (uint64)disk.avail >> 32;
    80006114:	9701                	srai	a4,a4,0x20
    80006116:	08e7aa23          	sw	a4,148(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_LOW) = (uint64)disk.used;
    8000611a:	6898                	ld	a4,16(s1)
    8000611c:	0007069b          	sext.w	a3,a4
    80006120:	0ad7a023          	sw	a3,160(a5)
  *R(VIRTIO_MMIO_DEVICE_DESC_HIGH) = (uint64)disk.used >> 32;
    80006124:	9701                	srai	a4,a4,0x20
    80006126:	0ae7a223          	sw	a4,164(a5)
  *R(VIRTIO_MMIO_QUEUE_READY) = 0x1;
    8000612a:	4705                	li	a4,1
    8000612c:	c3f8                	sw	a4,68(a5)
    disk.free[i] = 1;
    8000612e:	00e48c23          	sb	a4,24(s1)
    80006132:	00e48ca3          	sb	a4,25(s1)
    80006136:	00e48d23          	sb	a4,26(s1)
    8000613a:	00e48da3          	sb	a4,27(s1)
    8000613e:	00e48e23          	sb	a4,28(s1)
    80006142:	00e48ea3          	sb	a4,29(s1)
    80006146:	00e48f23          	sb	a4,30(s1)
    8000614a:	00e48fa3          	sb	a4,31(s1)
  status |= VIRTIO_CONFIG_S_DRIVER_OK;
    8000614e:	00496913          	ori	s2,s2,4
  *R(VIRTIO_MMIO_STATUS) = status;
    80006152:	0727a823          	sw	s2,112(a5)
}
    80006156:	60e2                	ld	ra,24(sp)
    80006158:	6442                	ld	s0,16(sp)
    8000615a:	64a2                	ld	s1,8(sp)
    8000615c:	6902                	ld	s2,0(sp)
    8000615e:	6105                	addi	sp,sp,32
    80006160:	8082                	ret
    panic("could not find virtio disk");
    80006162:	00002517          	auipc	a0,0x2
    80006166:	68650513          	addi	a0,a0,1670 # 800087e8 <syscalls+0x338>
    8000616a:	ffffa097          	auipc	ra,0xffffa
    8000616e:	3d6080e7          	jalr	982(ra) # 80000540 <panic>
    panic("virtio disk FEATURES_OK unset");
    80006172:	00002517          	auipc	a0,0x2
    80006176:	69650513          	addi	a0,a0,1686 # 80008808 <syscalls+0x358>
    8000617a:	ffffa097          	auipc	ra,0xffffa
    8000617e:	3c6080e7          	jalr	966(ra) # 80000540 <panic>
    panic("virtio disk should not be ready");
    80006182:	00002517          	auipc	a0,0x2
    80006186:	6a650513          	addi	a0,a0,1702 # 80008828 <syscalls+0x378>
    8000618a:	ffffa097          	auipc	ra,0xffffa
    8000618e:	3b6080e7          	jalr	950(ra) # 80000540 <panic>
    panic("virtio disk has no queue 0");
    80006192:	00002517          	auipc	a0,0x2
    80006196:	6b650513          	addi	a0,a0,1718 # 80008848 <syscalls+0x398>
    8000619a:	ffffa097          	auipc	ra,0xffffa
    8000619e:	3a6080e7          	jalr	934(ra) # 80000540 <panic>
    panic("virtio disk max queue too short");
    800061a2:	00002517          	auipc	a0,0x2
    800061a6:	6c650513          	addi	a0,a0,1734 # 80008868 <syscalls+0x3b8>
    800061aa:	ffffa097          	auipc	ra,0xffffa
    800061ae:	396080e7          	jalr	918(ra) # 80000540 <panic>
    panic("virtio disk kalloc");
    800061b2:	00002517          	auipc	a0,0x2
    800061b6:	6d650513          	addi	a0,a0,1750 # 80008888 <syscalls+0x3d8>
    800061ba:	ffffa097          	auipc	ra,0xffffa
    800061be:	386080e7          	jalr	902(ra) # 80000540 <panic>

00000000800061c2 <virtio_disk_rw>:
  return 0;
}

void
virtio_disk_rw(struct buf *b, int write)
{
    800061c2:	7119                	addi	sp,sp,-128
    800061c4:	fc86                	sd	ra,120(sp)
    800061c6:	f8a2                	sd	s0,112(sp)
    800061c8:	f4a6                	sd	s1,104(sp)
    800061ca:	f0ca                	sd	s2,96(sp)
    800061cc:	ecce                	sd	s3,88(sp)
    800061ce:	e8d2                	sd	s4,80(sp)
    800061d0:	e4d6                	sd	s5,72(sp)
    800061d2:	e0da                	sd	s6,64(sp)
    800061d4:	fc5e                	sd	s7,56(sp)
    800061d6:	f862                	sd	s8,48(sp)
    800061d8:	f466                	sd	s9,40(sp)
    800061da:	f06a                	sd	s10,32(sp)
    800061dc:	ec6e                	sd	s11,24(sp)
    800061de:	0100                	addi	s0,sp,128
    800061e0:	8aaa                	mv	s5,a0
    800061e2:	8c2e                	mv	s8,a1
  uint64 sector = b->blockno * (BSIZE / 512);
    800061e4:	00c52d03          	lw	s10,12(a0)
    800061e8:	001d1d1b          	slliw	s10,s10,0x1
    800061ec:	1d02                	slli	s10,s10,0x20
    800061ee:	020d5d13          	srli	s10,s10,0x20

  acquire(&disk.vdisk_lock);
    800061f2:	0001c517          	auipc	a0,0x1c
    800061f6:	bd650513          	addi	a0,a0,-1066 # 80021dc8 <disk+0x128>
    800061fa:	ffffb097          	auipc	ra,0xffffb
    800061fe:	9dc080e7          	jalr	-1572(ra) # 80000bd6 <acquire>
  for(int i = 0; i < 3; i++){
    80006202:	4981                	li	s3,0
  for(int i = 0; i < NUM; i++){
    80006204:	44a1                	li	s1,8
      disk.free[i] = 0;
    80006206:	0001cb97          	auipc	s7,0x1c
    8000620a:	a9ab8b93          	addi	s7,s7,-1382 # 80021ca0 <disk>
  for(int i = 0; i < 3; i++){
    8000620e:	4b0d                	li	s6,3
  int idx[3];
  while(1){
    if(alloc3_desc(idx) == 0) {
      break;
    }
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006210:	0001cc97          	auipc	s9,0x1c
    80006214:	bb8c8c93          	addi	s9,s9,-1096 # 80021dc8 <disk+0x128>
    80006218:	a08d                	j	8000627a <virtio_disk_rw+0xb8>
      disk.free[i] = 0;
    8000621a:	00fb8733          	add	a4,s7,a5
    8000621e:	00070c23          	sb	zero,24(a4)
    idx[i] = alloc_desc();
    80006222:	c19c                	sw	a5,0(a1)
    if(idx[i] < 0){
    80006224:	0207c563          	bltz	a5,8000624e <virtio_disk_rw+0x8c>
  for(int i = 0; i < 3; i++){
    80006228:	2905                	addiw	s2,s2,1
    8000622a:	0611                	addi	a2,a2,4 # 1004 <_entry-0x7fffeffc>
    8000622c:	05690c63          	beq	s2,s6,80006284 <virtio_disk_rw+0xc2>
    idx[i] = alloc_desc();
    80006230:	85b2                	mv	a1,a2
  for(int i = 0; i < NUM; i++){
    80006232:	0001c717          	auipc	a4,0x1c
    80006236:	a6e70713          	addi	a4,a4,-1426 # 80021ca0 <disk>
    8000623a:	87ce                	mv	a5,s3
    if(disk.free[i]){
    8000623c:	01874683          	lbu	a3,24(a4)
    80006240:	fee9                	bnez	a3,8000621a <virtio_disk_rw+0x58>
  for(int i = 0; i < NUM; i++){
    80006242:	2785                	addiw	a5,a5,1
    80006244:	0705                	addi	a4,a4,1
    80006246:	fe979be3          	bne	a5,s1,8000623c <virtio_disk_rw+0x7a>
    idx[i] = alloc_desc();
    8000624a:	57fd                	li	a5,-1
    8000624c:	c19c                	sw	a5,0(a1)
      for(int j = 0; j < i; j++)
    8000624e:	01205d63          	blez	s2,80006268 <virtio_disk_rw+0xa6>
    80006252:	8dce                	mv	s11,s3
        free_desc(idx[j]);
    80006254:	000a2503          	lw	a0,0(s4)
    80006258:	00000097          	auipc	ra,0x0
    8000625c:	cfe080e7          	jalr	-770(ra) # 80005f56 <free_desc>
      for(int j = 0; j < i; j++)
    80006260:	2d85                	addiw	s11,s11,1
    80006262:	0a11                	addi	s4,s4,4
    80006264:	ff2d98e3          	bne	s11,s2,80006254 <virtio_disk_rw+0x92>
    sleep(&disk.free[0], &disk.vdisk_lock);
    80006268:	85e6                	mv	a1,s9
    8000626a:	0001c517          	auipc	a0,0x1c
    8000626e:	a4e50513          	addi	a0,a0,-1458 # 80021cb8 <disk+0x18>
    80006272:	ffffc097          	auipc	ra,0xffffc
    80006276:	f30080e7          	jalr	-208(ra) # 800021a2 <sleep>
  for(int i = 0; i < 3; i++){
    8000627a:	f8040a13          	addi	s4,s0,-128
{
    8000627e:	8652                	mv	a2,s4
  for(int i = 0; i < 3; i++){
    80006280:	894e                	mv	s2,s3
    80006282:	b77d                	j	80006230 <virtio_disk_rw+0x6e>
  }

  // format the three descriptors.
  // qemu's virtio-blk.c reads them.

  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    80006284:	f8042503          	lw	a0,-128(s0)
    80006288:	00a50713          	addi	a4,a0,10
    8000628c:	0712                	slli	a4,a4,0x4

  if(write)
    8000628e:	0001c797          	auipc	a5,0x1c
    80006292:	a1278793          	addi	a5,a5,-1518 # 80021ca0 <disk>
    80006296:	00e786b3          	add	a3,a5,a4
    8000629a:	01803633          	snez	a2,s8
    8000629e:	c690                	sw	a2,8(a3)
    buf0->type = VIRTIO_BLK_T_OUT; // write the disk
  else
    buf0->type = VIRTIO_BLK_T_IN; // read the disk
  buf0->reserved = 0;
    800062a0:	0006a623          	sw	zero,12(a3)
  buf0->sector = sector;
    800062a4:	01a6b823          	sd	s10,16(a3)

  disk.desc[idx[0]].addr = (uint64) buf0;
    800062a8:	f6070613          	addi	a2,a4,-160
    800062ac:	6394                	ld	a3,0(a5)
    800062ae:	96b2                	add	a3,a3,a2
  struct virtio_blk_req *buf0 = &disk.ops[idx[0]];
    800062b0:	00870593          	addi	a1,a4,8
    800062b4:	95be                	add	a1,a1,a5
  disk.desc[idx[0]].addr = (uint64) buf0;
    800062b6:	e28c                	sd	a1,0(a3)
  disk.desc[idx[0]].len = sizeof(struct virtio_blk_req);
    800062b8:	0007b803          	ld	a6,0(a5)
    800062bc:	9642                	add	a2,a2,a6
    800062be:	46c1                	li	a3,16
    800062c0:	c614                	sw	a3,8(a2)
  disk.desc[idx[0]].flags = VRING_DESC_F_NEXT;
    800062c2:	4585                	li	a1,1
    800062c4:	00b61623          	sh	a1,12(a2)
  disk.desc[idx[0]].next = idx[1];
    800062c8:	f8442683          	lw	a3,-124(s0)
    800062cc:	00d61723          	sh	a3,14(a2)

  disk.desc[idx[1]].addr = (uint64) b->data;
    800062d0:	0692                	slli	a3,a3,0x4
    800062d2:	9836                	add	a6,a6,a3
    800062d4:	058a8613          	addi	a2,s5,88
    800062d8:	00c83023          	sd	a2,0(a6)
  disk.desc[idx[1]].len = BSIZE;
    800062dc:	0007b803          	ld	a6,0(a5)
    800062e0:	96c2                	add	a3,a3,a6
    800062e2:	40000613          	li	a2,1024
    800062e6:	c690                	sw	a2,8(a3)
  if(write)
    800062e8:	001c3613          	seqz	a2,s8
    800062ec:	0016161b          	slliw	a2,a2,0x1
    disk.desc[idx[1]].flags = 0; // device reads b->data
  else
    disk.desc[idx[1]].flags = VRING_DESC_F_WRITE; // device writes b->data
  disk.desc[idx[1]].flags |= VRING_DESC_F_NEXT;
    800062f0:	00166613          	ori	a2,a2,1
    800062f4:	00c69623          	sh	a2,12(a3)
  disk.desc[idx[1]].next = idx[2];
    800062f8:	f8842603          	lw	a2,-120(s0)
    800062fc:	00c69723          	sh	a2,14(a3)

  disk.info[idx[0]].status = 0xff; // device writes 0 on success
    80006300:	00250693          	addi	a3,a0,2
    80006304:	0692                	slli	a3,a3,0x4
    80006306:	96be                	add	a3,a3,a5
    80006308:	58fd                	li	a7,-1
    8000630a:	01168823          	sb	a7,16(a3)
  disk.desc[idx[2]].addr = (uint64) &disk.info[idx[0]].status;
    8000630e:	0612                	slli	a2,a2,0x4
    80006310:	9832                	add	a6,a6,a2
    80006312:	f9070713          	addi	a4,a4,-112
    80006316:	973e                	add	a4,a4,a5
    80006318:	00e83023          	sd	a4,0(a6)
  disk.desc[idx[2]].len = 1;
    8000631c:	6398                	ld	a4,0(a5)
    8000631e:	9732                	add	a4,a4,a2
    80006320:	c70c                	sw	a1,8(a4)
  disk.desc[idx[2]].flags = VRING_DESC_F_WRITE; // device writes the status
    80006322:	4609                	li	a2,2
    80006324:	00c71623          	sh	a2,12(a4)
  disk.desc[idx[2]].next = 0;
    80006328:	00071723          	sh	zero,14(a4)

  // record struct buf for virtio_disk_intr().
  b->disk = 1;
    8000632c:	00baa223          	sw	a1,4(s5)
  disk.info[idx[0]].b = b;
    80006330:	0156b423          	sd	s5,8(a3)

  // tell the device the first index in our chain of descriptors.
  disk.avail->ring[disk.avail->idx % NUM] = idx[0];
    80006334:	6794                	ld	a3,8(a5)
    80006336:	0026d703          	lhu	a4,2(a3)
    8000633a:	8b1d                	andi	a4,a4,7
    8000633c:	0706                	slli	a4,a4,0x1
    8000633e:	96ba                	add	a3,a3,a4
    80006340:	00a69223          	sh	a0,4(a3)

  __sync_synchronize();
    80006344:	0ff0000f          	fence

  // tell the device another avail ring entry is available.
  disk.avail->idx += 1; // not % NUM ...
    80006348:	6798                	ld	a4,8(a5)
    8000634a:	00275783          	lhu	a5,2(a4)
    8000634e:	2785                	addiw	a5,a5,1
    80006350:	00f71123          	sh	a5,2(a4)

  __sync_synchronize();
    80006354:	0ff0000f          	fence

  *R(VIRTIO_MMIO_QUEUE_NOTIFY) = 0; // value is queue number
    80006358:	100017b7          	lui	a5,0x10001
    8000635c:	0407a823          	sw	zero,80(a5) # 10001050 <_entry-0x6fffefb0>

  // Wait for virtio_disk_intr() to say request has finished.
  while(b->disk == 1) {
    80006360:	004aa783          	lw	a5,4(s5)
    sleep(b, &disk.vdisk_lock);
    80006364:	0001c917          	auipc	s2,0x1c
    80006368:	a6490913          	addi	s2,s2,-1436 # 80021dc8 <disk+0x128>
  while(b->disk == 1) {
    8000636c:	4485                	li	s1,1
    8000636e:	00b79c63          	bne	a5,a1,80006386 <virtio_disk_rw+0x1c4>
    sleep(b, &disk.vdisk_lock);
    80006372:	85ca                	mv	a1,s2
    80006374:	8556                	mv	a0,s5
    80006376:	ffffc097          	auipc	ra,0xffffc
    8000637a:	e2c080e7          	jalr	-468(ra) # 800021a2 <sleep>
  while(b->disk == 1) {
    8000637e:	004aa783          	lw	a5,4(s5)
    80006382:	fe9788e3          	beq	a5,s1,80006372 <virtio_disk_rw+0x1b0>
  }

  disk.info[idx[0]].b = 0;
    80006386:	f8042903          	lw	s2,-128(s0)
    8000638a:	00290713          	addi	a4,s2,2
    8000638e:	0712                	slli	a4,a4,0x4
    80006390:	0001c797          	auipc	a5,0x1c
    80006394:	91078793          	addi	a5,a5,-1776 # 80021ca0 <disk>
    80006398:	97ba                	add	a5,a5,a4
    8000639a:	0007b423          	sd	zero,8(a5)
    int flag = disk.desc[i].flags;
    8000639e:	0001c997          	auipc	s3,0x1c
    800063a2:	90298993          	addi	s3,s3,-1790 # 80021ca0 <disk>
    800063a6:	00491713          	slli	a4,s2,0x4
    800063aa:	0009b783          	ld	a5,0(s3)
    800063ae:	97ba                	add	a5,a5,a4
    800063b0:	00c7d483          	lhu	s1,12(a5)
    int nxt = disk.desc[i].next;
    800063b4:	854a                	mv	a0,s2
    800063b6:	00e7d903          	lhu	s2,14(a5)
    free_desc(i);
    800063ba:	00000097          	auipc	ra,0x0
    800063be:	b9c080e7          	jalr	-1124(ra) # 80005f56 <free_desc>
    if(flag & VRING_DESC_F_NEXT)
    800063c2:	8885                	andi	s1,s1,1
    800063c4:	f0ed                	bnez	s1,800063a6 <virtio_disk_rw+0x1e4>
  free_chain(idx[0]);

  release(&disk.vdisk_lock);
    800063c6:	0001c517          	auipc	a0,0x1c
    800063ca:	a0250513          	addi	a0,a0,-1534 # 80021dc8 <disk+0x128>
    800063ce:	ffffb097          	auipc	ra,0xffffb
    800063d2:	8bc080e7          	jalr	-1860(ra) # 80000c8a <release>
}
    800063d6:	70e6                	ld	ra,120(sp)
    800063d8:	7446                	ld	s0,112(sp)
    800063da:	74a6                	ld	s1,104(sp)
    800063dc:	7906                	ld	s2,96(sp)
    800063de:	69e6                	ld	s3,88(sp)
    800063e0:	6a46                	ld	s4,80(sp)
    800063e2:	6aa6                	ld	s5,72(sp)
    800063e4:	6b06                	ld	s6,64(sp)
    800063e6:	7be2                	ld	s7,56(sp)
    800063e8:	7c42                	ld	s8,48(sp)
    800063ea:	7ca2                	ld	s9,40(sp)
    800063ec:	7d02                	ld	s10,32(sp)
    800063ee:	6de2                	ld	s11,24(sp)
    800063f0:	6109                	addi	sp,sp,128
    800063f2:	8082                	ret

00000000800063f4 <virtio_disk_intr>:

void
virtio_disk_intr()
{
    800063f4:	1101                	addi	sp,sp,-32
    800063f6:	ec06                	sd	ra,24(sp)
    800063f8:	e822                	sd	s0,16(sp)
    800063fa:	e426                	sd	s1,8(sp)
    800063fc:	1000                	addi	s0,sp,32
  acquire(&disk.vdisk_lock);
    800063fe:	0001c497          	auipc	s1,0x1c
    80006402:	8a248493          	addi	s1,s1,-1886 # 80021ca0 <disk>
    80006406:	0001c517          	auipc	a0,0x1c
    8000640a:	9c250513          	addi	a0,a0,-1598 # 80021dc8 <disk+0x128>
    8000640e:	ffffa097          	auipc	ra,0xffffa
    80006412:	7c8080e7          	jalr	1992(ra) # 80000bd6 <acquire>
  // we've seen this interrupt, which the following line does.
  // this may race with the device writing new entries to
  // the "used" ring, in which case we may process the new
  // completion entries in this interrupt, and have nothing to do
  // in the next interrupt, which is harmless.
  *R(VIRTIO_MMIO_INTERRUPT_ACK) = *R(VIRTIO_MMIO_INTERRUPT_STATUS) & 0x3;
    80006416:	10001737          	lui	a4,0x10001
    8000641a:	533c                	lw	a5,96(a4)
    8000641c:	8b8d                	andi	a5,a5,3
    8000641e:	d37c                	sw	a5,100(a4)

  __sync_synchronize();
    80006420:	0ff0000f          	fence

  // the device increments disk.used->idx when it
  // adds an entry to the used ring.

  while(disk.used_idx != disk.used->idx){
    80006424:	689c                	ld	a5,16(s1)
    80006426:	0204d703          	lhu	a4,32(s1)
    8000642a:	0027d783          	lhu	a5,2(a5)
    8000642e:	04f70863          	beq	a4,a5,8000647e <virtio_disk_intr+0x8a>
    __sync_synchronize();
    80006432:	0ff0000f          	fence
    int id = disk.used->ring[disk.used_idx % NUM].id;
    80006436:	6898                	ld	a4,16(s1)
    80006438:	0204d783          	lhu	a5,32(s1)
    8000643c:	8b9d                	andi	a5,a5,7
    8000643e:	078e                	slli	a5,a5,0x3
    80006440:	97ba                	add	a5,a5,a4
    80006442:	43dc                	lw	a5,4(a5)

    if(disk.info[id].status != 0)
    80006444:	00278713          	addi	a4,a5,2
    80006448:	0712                	slli	a4,a4,0x4
    8000644a:	9726                	add	a4,a4,s1
    8000644c:	01074703          	lbu	a4,16(a4) # 10001010 <_entry-0x6fffeff0>
    80006450:	e721                	bnez	a4,80006498 <virtio_disk_intr+0xa4>
      panic("virtio_disk_intr status");

    struct buf *b = disk.info[id].b;
    80006452:	0789                	addi	a5,a5,2
    80006454:	0792                	slli	a5,a5,0x4
    80006456:	97a6                	add	a5,a5,s1
    80006458:	6788                	ld	a0,8(a5)
    b->disk = 0;   // disk is done with buf
    8000645a:	00052223          	sw	zero,4(a0)
    wakeup(b);
    8000645e:	ffffc097          	auipc	ra,0xffffc
    80006462:	da8080e7          	jalr	-600(ra) # 80002206 <wakeup>

    disk.used_idx += 1;
    80006466:	0204d783          	lhu	a5,32(s1)
    8000646a:	2785                	addiw	a5,a5,1
    8000646c:	17c2                	slli	a5,a5,0x30
    8000646e:	93c1                	srli	a5,a5,0x30
    80006470:	02f49023          	sh	a5,32(s1)
  while(disk.used_idx != disk.used->idx){
    80006474:	6898                	ld	a4,16(s1)
    80006476:	00275703          	lhu	a4,2(a4)
    8000647a:	faf71ce3          	bne	a4,a5,80006432 <virtio_disk_intr+0x3e>
  }

  release(&disk.vdisk_lock);
    8000647e:	0001c517          	auipc	a0,0x1c
    80006482:	94a50513          	addi	a0,a0,-1718 # 80021dc8 <disk+0x128>
    80006486:	ffffb097          	auipc	ra,0xffffb
    8000648a:	804080e7          	jalr	-2044(ra) # 80000c8a <release>
}
    8000648e:	60e2                	ld	ra,24(sp)
    80006490:	6442                	ld	s0,16(sp)
    80006492:	64a2                	ld	s1,8(sp)
    80006494:	6105                	addi	sp,sp,32
    80006496:	8082                	ret
      panic("virtio_disk_intr status");
    80006498:	00002517          	auipc	a0,0x2
    8000649c:	40850513          	addi	a0,a0,1032 # 800088a0 <syscalls+0x3f0>
    800064a0:	ffffa097          	auipc	ra,0xffffa
    800064a4:	0a0080e7          	jalr	160(ra) # 80000540 <panic>
	...

0000000080007000 <_trampoline>:
    80007000:	14051073          	csrw	sscratch,a0
    80007004:	02000537          	lui	a0,0x2000
    80007008:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    8000700a:	0536                	slli	a0,a0,0xd
    8000700c:	02153423          	sd	ra,40(a0)
    80007010:	02253823          	sd	sp,48(a0)
    80007014:	02353c23          	sd	gp,56(a0)
    80007018:	04453023          	sd	tp,64(a0)
    8000701c:	04553423          	sd	t0,72(a0)
    80007020:	04653823          	sd	t1,80(a0)
    80007024:	04753c23          	sd	t2,88(a0)
    80007028:	f120                	sd	s0,96(a0)
    8000702a:	f524                	sd	s1,104(a0)
    8000702c:	fd2c                	sd	a1,120(a0)
    8000702e:	e150                	sd	a2,128(a0)
    80007030:	e554                	sd	a3,136(a0)
    80007032:	e958                	sd	a4,144(a0)
    80007034:	ed5c                	sd	a5,152(a0)
    80007036:	0b053023          	sd	a6,160(a0)
    8000703a:	0b153423          	sd	a7,168(a0)
    8000703e:	0b253823          	sd	s2,176(a0)
    80007042:	0b353c23          	sd	s3,184(a0)
    80007046:	0d453023          	sd	s4,192(a0)
    8000704a:	0d553423          	sd	s5,200(a0)
    8000704e:	0d653823          	sd	s6,208(a0)
    80007052:	0d753c23          	sd	s7,216(a0)
    80007056:	0f853023          	sd	s8,224(a0)
    8000705a:	0f953423          	sd	s9,232(a0)
    8000705e:	0fa53823          	sd	s10,240(a0)
    80007062:	0fb53c23          	sd	s11,248(a0)
    80007066:	11c53023          	sd	t3,256(a0)
    8000706a:	11d53423          	sd	t4,264(a0)
    8000706e:	11e53823          	sd	t5,272(a0)
    80007072:	11f53c23          	sd	t6,280(a0)
    80007076:	140022f3          	csrr	t0,sscratch
    8000707a:	06553823          	sd	t0,112(a0)
    8000707e:	00853103          	ld	sp,8(a0)
    80007082:	02053203          	ld	tp,32(a0)
    80007086:	01053283          	ld	t0,16(a0)
    8000708a:	00053303          	ld	t1,0(a0)
    8000708e:	12000073          	sfence.vma
    80007092:	18031073          	csrw	satp,t1
    80007096:	12000073          	sfence.vma
    8000709a:	8282                	jr	t0

000000008000709c <userret>:
    8000709c:	12000073          	sfence.vma
    800070a0:	18051073          	csrw	satp,a0
    800070a4:	12000073          	sfence.vma
    800070a8:	02000537          	lui	a0,0x2000
    800070ac:	357d                	addiw	a0,a0,-1 # 1ffffff <_entry-0x7e000001>
    800070ae:	0536                	slli	a0,a0,0xd
    800070b0:	02853083          	ld	ra,40(a0)
    800070b4:	03053103          	ld	sp,48(a0)
    800070b8:	03853183          	ld	gp,56(a0)
    800070bc:	04053203          	ld	tp,64(a0)
    800070c0:	04853283          	ld	t0,72(a0)
    800070c4:	05053303          	ld	t1,80(a0)
    800070c8:	05853383          	ld	t2,88(a0)
    800070cc:	7120                	ld	s0,96(a0)
    800070ce:	7524                	ld	s1,104(a0)
    800070d0:	7d2c                	ld	a1,120(a0)
    800070d2:	6150                	ld	a2,128(a0)
    800070d4:	6554                	ld	a3,136(a0)
    800070d6:	6958                	ld	a4,144(a0)
    800070d8:	6d5c                	ld	a5,152(a0)
    800070da:	0a053803          	ld	a6,160(a0)
    800070de:	0a853883          	ld	a7,168(a0)
    800070e2:	0b053903          	ld	s2,176(a0)
    800070e6:	0b853983          	ld	s3,184(a0)
    800070ea:	0c053a03          	ld	s4,192(a0)
    800070ee:	0c853a83          	ld	s5,200(a0)
    800070f2:	0d053b03          	ld	s6,208(a0)
    800070f6:	0d853b83          	ld	s7,216(a0)
    800070fa:	0e053c03          	ld	s8,224(a0)
    800070fe:	0e853c83          	ld	s9,232(a0)
    80007102:	0f053d03          	ld	s10,240(a0)
    80007106:	0f853d83          	ld	s11,248(a0)
    8000710a:	10053e03          	ld	t3,256(a0)
    8000710e:	10853e83          	ld	t4,264(a0)
    80007112:	11053f03          	ld	t5,272(a0)
    80007116:	11853f83          	ld	t6,280(a0)
    8000711a:	7928                	ld	a0,112(a0)
    8000711c:	10200073          	sret
	...
