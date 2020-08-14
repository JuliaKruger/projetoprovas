      $set sourceformat"free"
      *>----Divis�o de identifica��o do programa
       identification division.
       program-id. "P16SISC20".
       author. "Julia Kr�ger".
       installation. "PC".
       date-written. 06/08/2020.
       date-compiled. 06/08/2020.

      *>----Divis�o para configura��o do ambiente
       environment division.
       configuration section.
           special-names. decimal-point is comma.

      *>-----Declara��o dos recursos externos
       input-output section.
       file-control.

       i-o-control.

      *>----Declara��o de vari�veis
       data division.

      *>----Variaveis de arquivos
       file section.

      *>----Variaveis de trabalho
       working-storage section.

      *> vari�veis que vem da tela
       01 f-tela_resultados is external-form.
           05 f-user.
               10 f-id-resultado                   pic x(02)  identified by "f-id-resul".
               10 f-id-user                        pic x(08)  identified by "f-id-user".
               10 f-id-disciplina                  pic 9(03)  identified by "f-id-disciplina".
               10 f-nota                           pic -99,99 identified by "f-nota".
               10 f-data-prova                     pic x(10)  identified by "f-data".
           05 f-op-salvar                          pic x(02)  identified by "f-op-salvar".
           05 f-op-deletar                         pic x(02)  identified by "f-op-deletar".
           05 f-op-consultar                       pic x(02)  identified by "f-op-consultar".
           05 f-confirmar                          pic x(06)  identified by "f-hd-confirma".
           05 f-msn                                pic x(50)  identified by "f-hd-msn".
           05 f-cf-operacao                        pic x(02)  identified by "f-hd-operacao".
           05 f-msn-erro                           pic x(50)  identified by "f-hd-msn-erro".

       01 f-tela_resultados2 is external-form identified by "tela_resultados2.html".
           05 f-user2.
               10 f-id-resultado2                  pic x(02)  identified by "f-id-resul".
               10 f-id-user2                       pic x(08)  identified by "f-id-user".
               10 f-id-disciplina2                 pic 9(03)  identified by "f-id-disciplina".
               10 f-nota2                          pic -99,99 identified by "f-nota".
               10 f-data-prova2                    pic x(10)  identified by "f-data".
           05 f-op-salvar2                         pic x(02)  identified by "f-op-salvar".
           05 f-op-deletar2                        pic x(02)  identified by "f-op-deletar".
           05 f-op-consultar2                      pic x(02)  identified by "f-op-consultar".
           05 f-confirmar2                         pic x(06)  identified by "f-hd-confirma".
           05 f-msn2                               pic x(50)  identified by "f-hd-msn".
           05 f-cf-operacao2                       pic x(02)  identified by "f-hd-operacao".
           05 f-msn-erro2                          pic x(50)  identified by "f-hd-msn-erro".

      *> vari�veis de trabalho
       01 ws-controle.
           05 ws-operacao                          pic x(02).
           05 ws-confirmacao                       pic x(01).
               88 ws-confirmar                     value "?".
               88 ws-confirmado                    value "S".
               88 ws-nao-confirmado                value "N".
           05 ws-msn                               pic x(50).
           05 ws-retorno.
               10 ws-msn-erro-pmg                  pic x(09). *> id do pmg
               10 ws-msn-erro-offset               pic 9(03). *> local do erro
               10 ws-return-code                   pic 9(02). *> status do pmg
               10 ws-msn-erro-cod                  pic x(02). *> file status
               10 ws-msn-erro-text                 pic x(50). *> mensagem de erro

       01 ws-gp-resultado.
           05 ws-resultado.
               10 ws-chave-resul.
                   15 ws-id-resultado              pic 9(02).
                   15 ws-user-disc.
                       20 ws-user-id               pic x(08).
                       20 ws-id-disciplina         pic 9(03).
               10 ws-nota                          pic -99,99.
               10 ws-data-prova                    pic x(10).

       77 ws-ind                                   pic 9(03).

      *>----Variaveis para comunica��o entre programas
       linkage section.

      *>----Declara��o de tela
       screen section.

      *>----Declara��o do corpo do programa
       procedure division.

      *>------------------------------------------------------------------------
      *>  Controle das se��es
      *>------------------------------------------------------------------------
       0000-controle section.
           perform 1000-inicializa
           perform 2000-processamento
           perform 3000-finaliza
           .
       0000-controle-exit.
           exit.

      *>------------------------------------------------------------------------
      *>  Procedimentos de inicializa��o
      *>------------------------------------------------------------------------
       1000-inicializa section.
           next sentence
           .
       1000-inicializa-exit.
           exit.

      *>------------------------------------------------------------------------
      *>  Processamento principal
      *>------------------------------------------------------------------------
       2000-processamento section.

           accept f-tela_resultados                *> aceitando a tela

           if   f-confirmar = "true" then          *> se o usu�rio confirmou a a��o
                move "S"                           to ws-confirmacao
                move f-cf-operacao                 to ws-operacao
           else                                    *> sen�o
                move "N"                           to ws-confirmacao
           end-if

      *> movendo dados da tela para as vari�veis da working storage
           move f-user                             to ws-resultado

           if   f-op-salvar = "SA" then            *> opera��o salvar
                move "SA"                          to ws-operacao
           end-if
           if   f-op-deletar = "DE" then           *> opera��o deletar
                move "DE"                          to ws-operacao
           end-if
           if   f-op-consultar = "CO" then         *> opera��o consultar
               if f-id-user = spaces then          *> se os campos da tela estiverem vazios, consultar todos
                   move "CT"                       to ws-operacao
               else                                *> sen�o, consultar um
                   move "C1"                       to ws-operacao
               end-if
           end-if

      *> chamando o programa P06SISC20
           call "P06SISC20" using ws-controle, ws-gp-resultado

      *> movendo a confirma��o (S/N/?) para a vari�vel de tela
           move ws-confirmacao                     to f-confirmar2
      *> movendo a opera��o a ser feita (SA/DE/CT/C1) para a vari�vel de tela
           move ws-msn(1:2)                        to f-cf-operacao2
      *> movendo a mensagem de pergunta para a vari�vel de tela
           move ws-msn(4:46)                       to f-msn2
      *> movendo a mensagem de erro/sucesso para a vari�vel de tela
           move ws-msn-erro-text                   to f-msn-erro2
      *> movendo o item de grupo resultado carregado com dados do arquivo para o item de grupo da tela
           move ws-resultado                       to f-user2
      *> mostrando a tela 2 com a mensagem/os dados do arquivo
           display f-tela_resultados2              *> mostrando a segunda tela

           .
       2000-processamento-exit.
           exit.

      *>------------------------------------------------------------------------
      *>  Finaliza��o Normal
      *>------------------------------------------------------------------------
       3000-finaliza section.
           stop run
           .
       3000-finaliza-exit.
           exit.


