# xv6-stride-scheduling
Escalonador Determinístico Stride Scheduling — xv6-riscv

Participantes:
Arthur Henrique Paulini Grasnievicz - 2311100002
Paula Frison Padilha - 2311100034

Objetivo:
Implementar o escalonador de processos determinístico Stride Scheduling no sistema operacional didático xv6 (versão RISC-V), como parte dos requisitos da disciplina de Sistemas Operacionais. O projeto visa aprofundar o conhecimento prático sobre o funcionamento do kernel, especificamente na gestão e escalonamento de processos.

Funcionamento do Escalonador:
O Stride Scheduling é um algoritmo determinístico que aloca o tempo de CPU de forma proporcional ao número de "bilhetes" (tickets) que cada processo possui.

- Tickets: Cada processo possui um número de bilhetes, que representa sua prioridade.
- Stride (Passo): Para cada processo, um valor de "passo" é calculado com a fórmula: Passo = Constante / Tickets. Foi utilizada uma constante de 10.000.
- Pass (Passada): Cada processo mantém um contador chamado "passada", que começa em zero e acumula o valor do seu passo a cada vez que é executado.
- Seleção: O escalonador sempre escolherá o processo pronto para executar (RUNNABLE) que tiver o menor valor de passada atual.
- Desempate: Caso dois ou mais processos possuam o mesmo valor de passada, o critério de desempate é a escolha do processo com o maior PID.

Modificações Realizadas:

kernel/param.h:
- Adicionada a STRIDE_CONSTANT para ser visível por múltiplos arquivos do kernel.

kernel/proc.h:
- Removido o campo priority_class da struct proc.
- Adicionados os campos int tickets, uint64 stride e uint64 pass à struct proc.

kernel/proc.c:
- allocproc(): Modificado para inicializar os valores de tickets, stride e pass para novos processos.
- fork(): Alterado para que o processo filho herde os tickets, stride e pass do processo pai.
- scheduler(): A função foi completamente substituída para implementar a lógica do Stride Scheduling.

kernel/sysproc.c:
- sys_fork(): Revertida para a sua implementação padrão no xv6, sem aceitar argumentos.
- sys_settickets(): Adicionada uma nova função para implementar a chamada de sistema settickets.

Ativação da Nova Syscall:
- kernel/syscall.h: Adicionado o número da nova syscall (SYS_settickets).
- kernel/syscall.c: Adicionada a função sys_settickets ao array de chamadas de sistema.
- user/user.h: Adicionado o protótipo da função settickets(int).

Makefile:
- Adicionado o programa de teste (stridetest) à lista de arquivos a serem compilados.

Como Testar:
Para avaliar o escalonador, siga os passos abaixo:

1. Compile e execute o xv6 a partir do terminal:
   make clean
   make qemu

2. Dentro do xv6, execute o programa de teste:
   stridetest

O programa stridetest deve criar múltiplos processos filhos, onde cada um utiliza a chamada de sistema settickets() para definir uma quantidade diferente de bilhetes. Ao observar a saída, será possível notar que os processos com mais bilhetes executam com uma frequência maior.
