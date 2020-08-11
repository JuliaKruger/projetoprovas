      $set sourceformat"free"
      *>----Divisão de identificação do programa
       identification Division.
       program-id. "P06SISC20".
       author. "Julia Krüger".
       installation. "PC".
       date-written. 03/08/2020.
       date-compiled. 03/08/2020.

      *>----Divisão para configuração do ambiente
       environment division.
       configuration section.
       special-names. decimal-point is comma.

      *>----Declaração dos recursos externos
       input-output section.
       file-control.
           select arq-resultados assign to "arq-resultados.dat"
           organization is indexed
           access mode is dynamic
           lock mode is manual with lock on multiple records
           record key is fl-chave-resul
           *>alternate key is fl-user-id with duplicates
           *>alternate key is fl-id-disciplina with duplicates
           alternate key is fl-user-disc with duplicates
           file status is ws-fs-arq-resultados.

           select arq-resultados2 assign to "arq-resultados2.txt"
           organization is line sequential
           access mode is sequential
           file status is ws-fs-arq-resultados2.

           select sort-resultados assign to "sort-resultados.txt"
           sort status is ws-ss-arq-resultados.

       i-o-control.


      *>----Declaração de variáveis
       data division.

      *>----Variáveis de arquivos
       file section.
       fd arq-resultados.
       01 fl-resultado.
           05 fl-chave-resul.
               10 fl-id-resultado                  pic 9(02).
               10 fl-user-disc.
                   15 fl-user-id                   pic x(08).
                   15 fl-id-disciplina             pic 9(03).
           05 fl-nota                              pic 9(02)V99.
           05 fl-data-prova                        pic 9(10).

       fd arq-resultados2.
       01 fl-resultado2.
           05 fl-chave-resul2.
               10 fl-id-resultado2                 pic 9(02).
               10 fl-user-disc2.
                   15 fl-user-id2                  pic x(08).
                   15 fl-id-disciplina2            pic 9(03).
           05 fl-nota2                             pic 9(02)V99.
           05 fl-data-prova2                       pic 9(10).

       sd sort-resultados.
       01 ss-resultado.
           05 ss-chave-resul.
               10 ss-id-resultado                  pic 9(02).
               10 ss-user-disc.
                   15 ss-user-id                   pic x(08).
                   15 ss-id-disciplina             pic 9(03).
           05 ss-nota                              pic 9(02)V99.
           05 ss-data-prova                        pic 9(10).

      *>----Variáveis de trabalho
       working-storage section.
       77 ws-fs-arq-resultados                     pic x(02).
       77 ws-fs-arq-resultados2                    pic x(02).
       77 ws-ss-arq-resultados                     pic x(02).

       01 ws-msn-erro.
          05 ws-msn-erro-offset                    pic 9(04).
          05 filler                                pic x(01) value "-".
          05 ws-msn-erro-cod                       pic x(02).
          05 filler                                pic x(01) value space.
          05 ws-msn-erro-text                      pic x(42).
       77 ws-msn                                   pic x(39).
       77 ws-confirmacao                           pic x(01).

       01 ws-resultado.
           05 ws-chave-resul.
               10 ws-id-resultado                  pic 9(02).
               10 ws-user-disc.
                   15 ws-user-id                   pic x(08).
                   15 ws-id-disciplina             pic 9(03).
           05 ws-nota                              pic 9(02)V99.
           05 ws-data-prova                        pic x(10).


      *>----Variáveis para comunicação entre prograpic 9(02).mas
       linkage section.

       77 lnk-escolha                               pic x(02).
       77 lnk-id-user                               pic x(08).
       77 lnk-id-disciplina                         pic 9(03).

       01  lnk-controle.
           05  lnk-usuario.
               10  lnk-user-id                     pic x(08).
               10  lnk-senha                       pic x(08).
               10  lnk-nome                        pic x(25).
               10  lnk-tipo-usuario                pic x(01).
           05  lnk-tb-usuario occurs 100.
               10  lnk-tb-user-id                  pic x(08).
               10  lnk-tb-senha                    pic x(08).
               10  lnk-tb-nome                     pic x(25).
               10  lnk-tb-tipo-usuario             pic x(01).
           05  lnk-operacao                        pic x(02).
           05  lnk-confirmacao                     pic x(01).
           05  lnk-msn                             pic x(50).
           05  lnk-retorno.
               10  lnk-msn-erro-pmg                    pic x(09).
               10  lnk-msn-erro-offset                 pic 9(03).
               10  lnk-return-code                     pic 9(02).
               10  lnk-msn-erro-cod                    pic x(02).
               10  lnk-msn-erro-text                   pic x(50).

       05 lnk-modo                                 pic X(01). *> ‘P’-rova; ‘S’-imulado


      *>----Declaração de tela
       screen section.

      *>Declaração do corpo do programa
       procedure division using lnk-escolha, lnk-id-user, lnk-id-disciplina.
       0000-controle section.
           perform 1000-inicializa
           perform 2000-processamento
           perform 3000-finaliza
           .
       0000-controle-exit.
           exit.

       1000-inicializa section.
           open i-o arq-resultados                 *> open i-o abre o arquivo para leitura e escrita
           if ws-fs-arq-resultados  <> "00"
           and ws-fs-arq-resultados <> "05" then
               move 1                                   to lnk-msn-erro-offset
               move ws-fs-arq-resultados                to lnk-msn-erro-cod
               move "Erro ao abrir arq. arqresultados"  to lnk-msn-erro-text
               perform 9000-finaliza-anormal
           end-if
           .
       1000-inicializa-exit.
           exit.

       2000-processamento section.
           evaluate lnk-escolha
               when = "SA"
                   perform 2100-salvar-dados
               when = "BU"
                   perform 2200-b-um-registro
               when = "BV"
                   perform 2300-b-varios-registros
               when = "BT"
                   perform 2400-b-todos-registros
               when = "DE"
                   perform 2500-deletar-dados
           end-evaluate


      *> exemplo de ordenação
      *>    close arq-resultados
      *>    close arq-resultados2

      *>    sort sort-resultados
      *>         on ascending key ss-user-id
      *>         using arq-resultados
      *>         giving arq-resultados2
           *> tratamento sort-status
      *>    display ws-ss-arq-resultados

      *>    open i-o arq-resultados
      *>    if ws-fs-arq-resultados <> "00"
      *>    and ws-fs-arq-resultados <> "05" then
      *>         display "Erro ao abrir"
      *>    end-if

           .
       2000-processamento-exit.
           exit.

       2100-salvar-dados section.

        *>   move 10 to ws-id-resultado
        *>   move 10,00 to ws-nota
        *>   move "07/08/2020" to ws-data-prova
           move lnk-id-user to ws-user-id
           move lnk-id-disciplina to ws-id-disciplina

           move ws-resultado to fl-resultado
           write fl-resultado
           if   ws-fs-arq-resultados  = "00" then
               move "Registro salvo com sucesso" to ws-msn-erro-text
               move ws-fs-arq-resultados         to ws-msn-erro-cod
           else
               if   ws-fs-arq-resultados = 22 then *> registro já existe
                   if   ws-confirmacao = "S" then
                       move "N" to lnk-confirmacao
                       rewrite fl-resultado
                       if   ws-fs-arq-resultados = "00" then
                               move "Registro alterado com sucesso"   to ws-msn-erro-text
                               move ws-fs-arq-resultados              to ws-msn-erro-cod
                       else
                               move "Erro ao alterar registro"        to ws-msn-erro-text
                               move ws-fs-arq-resultados              to ws-msn-erro-cod
                               perform 9000-finaliza-anormal
                       end-if
                   else
                       move "?" to ws-confirmacao
                       move "Confirmar a alteracao de resultado?"  to ws-msn
                   end-if
               else
                   move "Erro ao escrever registro"                 to ws-msn-erro-text
                   move ws-fs-arq-resultados                        to ws-msn-erro-cod
                   perform 9000-finaliza-anormal
               end-if
           end-if
           .
       2100-salvar-dados-exit.
           exit.


       2200-b-um-registro section.
           move lnk-id-user to fl-user-id
           move lnk-id-disciplina to fl-id-disciplina
           read arq-resultados key fl-user-id
           if   ws-fs-arq-resultados = "00" then
               move fl-resultado to ws-resultado
               move "Registro lido com sucesso"    to ws-msn-erro-text
               move ws-fs-arq-resultados           to ws-msn-erro-cod
           else
               if   ws-fs-arq-resultados = "23" then
                       move "Codigo inexistente"   to ws-msn-erro-text
                       move ws-fs-arq-resultados   to ws-msn-erro-cod
               else
                       move "Erro ao ler registro" to lnk-msn-erro-text
                       move ws-fs-arq-resultados   to lnk-msn-erro-cod
                       perform 9000-finaliza-anormal
               end-if
           end-if
           .
       2200-b-um-registro-exit.
           exit.


       2300-b-varios-registros section.
           move ws-user-id to fl-user-id
           start arq-resultados key = fl-user-disc
           if   ws-fs-arq-resultados = "00" then
               perform until ws-fs-arq-resultados <> "10"
                               or fl-user-disc > ws-user-disc
                       read arq-resultados next record
                       if   (ws-fs-arq-resultados = "00" or ws-fs-arq-resultados = "02")
                       and fl-user-disc = ws-user-disc then
                           move fl-resultado   to ws-resultado
                       else
                           if   ws-fs-arq-resultados <> 10
                               move "Erro ao ler registro" to ws-msn-erro-text
                               move ws-fs-arq-resultados   to ws-msn-erro-cod
                               perform 9000-finaliza-anormal
                           end-if
                       end-if
               end-perform
           else
               if   ws-fs-arq-resultados = "23" then
                       move "Codigo inexistente"   to ws-msn-erro-text
                       move ws-fs-arq-resultados   to ws-msn-erro-cod
               else
                       move "Erro ao ler registro" to ws-msn-erro-text
                       move ws-fs-arq-resultados   to ws-msn-erro-cod
                       perform 9000-finaliza-anormal
               end-if
           end-if
           .
       2300-b-varios-registros-exit.
           exit.

       2400-b-todos-registros section.
           perform until ws-fs-arq-resultados = 10
               read arq-resultados next
               if   ws-fs-arq-resultados = "00" then
                   move fl-resultado   to ws-resultado
               else
                   if   ws-fs-arq-resultados <> 10
                           move "Erro ao ler registro" to ws-msn-erro-text
                           move ws-fs-arq-resultados   to ws-msn-erro-cod
                           perform 9000-finaliza-anormal
                   end-if
               end-if
           end-perform
           .
       2400-b-todos-registros-exit.
           exit.

       2500-deletar-dados section.
           move ws-user-id to fl-user-id
           read arq-resultados
           if   ws-fs-arq-resultados = "00" then
               if   lnk-confirmacao = "S"
                   move "N"    to lnk-confirmacao
                   delete arq-resultados
                   if   ws-fs-arq-resultados = "00" then
                           move "Registro excluido com sucesso" to ws-msn-erro-text
                           move ws-fs-arq-resultados            to ws-msn-erro-cod
                   else
                           move "Erro ao excluir registro"      to ws-msn-erro-text
                           move ws-fs-arq-resultados            to ws-msn-erro-cod
                           perform 9000-finaliza-anormal
                   end-if
               else
                   move "?" to lnk-confirmacao
                   move "Confirma a exclusao de registro?" to ws-msn
               end-if
           else
               if   ws-fs-arq-resultados = "23" then
                   move "Codigo inexistente"   to ws-msn-erro-text
                   move ws-fs-arq-resultados   to ws-msn-erro-cod
               else
                   move "Erro ao ler registro" to ws-msn-erro-text
                   move ws-fs-arq-resultados   to ws-msn-erro-cod
                   perform 9000-finaliza-anormal
               end-if
           end-if
           .
       2500-deletar-dados-exit.
           exit.


      *>------------------------------------------------------------------------
      *>  Finalização  Anormal
      *>------------------------------------------------------------------------
       9000-finaliza-anormal section.
           display erase
           display lnk-retorno.
           stop run
           .
       9000-finaliza-anormal-exit.
           exit.

      *>------------------------------------------------------------------------
      *> Finalização Normal
      *>------------------------------------------------------------------------
       3000-finaliza section.
           close arq-resultados
           if ws-fs-arq-resultados  <> "00" then
               move 4                                     to ws-msn-erro-offset
               move ws-fs-arq-resultados                  to ws-msn-erro-cod
               move "Erro ao fechar arq. arq-resultados"  to ws-msn-erro-text
               perform 9000-finaliza-anormal
           end-if
           exit program
           .
       3000-finaliza-exit.
           exit.

