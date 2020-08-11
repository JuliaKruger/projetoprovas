      $set sourceformat"free"
      *>Divisão de identificação do programa
       identification division.
       program-id. "P16SISC20".
       author. "Julia Krüger".
       installation. "PC".
       date-written. 06/08/2020.
       date-compiled. 06/08/2020.

      *>Divisão para configuração do ambiente
       environment division.
       configuration section.
           special-names. decimal-point is comma.

      *>-----Declaração dos recursos externos
       input-output section.
       file-control.

       i-o-control.

      *>Declaração de variáveis
       data division.

      *>----Variaveis de arquivos
       file section.

      *>----Variaveis de trabalho
       working-storage section.

       01 f-tela_resultados is external-form.
           05 f-tela.
               10 f-id-user                            pic x(08) identified by "f-id-user".
               10 f-id-disciplina                      pic 9(03) identified by "f-id-disciplina".
               10 f-escolha                            pic x(02) identified by "f-escolha".
               10 f-op-salvar                          pic x(02) identified by "f-op-salvar".
               10 f-op-deletar                         pic x(02) identified by "f-op-deletar".
               10 f-op-buscar-um                       pic x(02) identified by "f-op-buscar-um".
               10 f-op-buscar-todos                    pic x(02) identified by "f-op-buscar-todos".

      *>77 ws-escolha                               pic x(02).

       01 f-tela_resultados2 is external-form identified by "tela_resultados2.html".
           05 f-tela2.
               10 f-id-user2                           pic x(08) identified by "f-id-user".
               10 f-escolha2                           pic x(02) identified by "f-escolha".

       77 ws-escolha                               pic x(02).
      *>----Variaveis para comunicação entre programas
       linkage section.

      *>----Declaração de tela
       screen section.

      *>Declaração do corpo do programa
       procedure division.

       0000-controle section.
           perform 1000-inicializa
           perform 2000-processamento
           perform 3000-finaliza
           .
       0000-controle-exit.
           exit.

      *>------------------------------------------------------------------------
      *>  Procedimentos de inicialização
      *>------------------------------------------------------------------------
       1000-inicializa section.

           .
       1000-inicializa-exit.
           exit.

      *>------------------------------------------------------------------------
      *>  Processamento principal
      *>------------------------------------------------------------------------
       2000-processamento section.

           accept f-tela_resultados

           if   f-op-salvar = "SA" then
                move "SA" to ws-escolha
           end-if
           if   f-op-deletar = "DE" then
                move "DE" to ws-escolha
           end-if
           if   f-op-buscar-um = "BU" then
                move "BU" to ws-escolha
           end-if
           if   f-op-buscar-todos = "BT" then
                move "BT" to ws-escolha
           end-if

           call "P06SISC20" using ws-escolha, f-id-user, f-id-disciplina

           *>move f-escolha to ws-escolha

           *>move f-tela to f-tela2
           *>display f-tela_resultados2



           .
       2000-processamento-exit.
           exit.


      *>------------------------------------------------------------------------
      *>  Finalização Normal
      *>------------------------------------------------------------------------
       3000-finaliza section.
           stop run
           .
       3000-finaliza-exit.
           exit.


