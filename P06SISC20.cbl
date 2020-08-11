      $set sourceformat"free"
       *>----Divisão de identificação do programa
       identification division.
       program-id. "P06SISC20".
       author. "Julia Krüger".
       installation. "PC".
       date-written. 03/08/2020.
       date-compiled. 03/08/2020.
       *>----Divisão para configuração do ambiente
       environment division.
       configuration section.
       special-names.
       decimal-point is comma.
       *>----Declaração dos recursos externos
       input-output section.
       file-control.
           select arq-resultados assign to "arq-resultados.dat"
           organization is indexed
           access mode is dynamic
           lock mode is manual with lock on multiple records
           record key is fl-chave-resul
           alternate key is fl-user-id with duplicates
           alternate key is fl-id-disciplina with duplicates
           file status is ws-fs-arq-resultados.
       i-o-control.
       *> SABER SE QUER REGISTRAR UM REDULTADO OU LER UM RESULTADO
       *>----Declaração de variáveis
       data division.
       *>----Variáveis de arquivos
       file section.
       fd arq-resultados.
       01 fl-resultado.
           05 fl-chave-resul.
               10 fl-id-resultado                  pic 9(02).
               10 fl-user-id                       pic x(10).
           05 fl-id-disciplina                     pic x(10).
           05 fl-nota                              pic 9(02)V99.
           05 fl-data-prova                        pic 9(10).
       *>----Variáveis de trabalho
       working-storage section.
       77 ws-fs-arq-resultados                     pic x(02).
       01 ws-resultado.
           05 ws-resul-chave-resul.
               10 ws-resul-id-resultado            pic 9(02).
               10 ws-resul-user-id                 pic x(08).
           05 ws-resul-id-disciplina               pic x(10).
           05 ws-resul-nota                        pic 9(02)V99.
           05 ws-resul-data-prova                  pic 9(10).

       77 ws-resul-msn                             pic x(39).
       77 ws-resul-sair                            pic x(01).
       77 ws-resul-proximo                         pic x(01).
       *>----Variáveis para comunicação entre programas
       linkage section.
       77 lnk-tipo-usuario-adm                      pic x(01).
       77 lnk-tipo-usuario-f                        pic x(01).
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
               10  lnk-msn-erro-pmg                pic x(09).
               10  lnk-msn-erro-offset             pic 9(03).
               10  lnk-return-code                 pic 9(02).
               10  lnk-msn-erro-cod                pic x(02).
               10  lnk-msn-erro-text               pic x(50).

       *>----Declaração de tela
       screen section.
       *> TELA PARA RECEBER OS DADOS DO FUNCIONARIO QUE O ADM QUER CONSULTAR OS RESULTADOS (USER-ID)
       *> TELA PARA MOSTRAR OS RESULTADOS DO FUNCIONARIO (USER-ID, ID-RESUL, ID-DISCIPLINA(VAI MOSTRAR OS RESULTADOS DE TODAS AS DISCIPLINAS,
       *> NOTA E DATA DA PROVA)
       *>                                0    1    1    2    2    3    3    4    4    5    5    6    6    7    7    8
       *>                                5    0    5    0    5    0    5    0    5    0    5    0    5    0    5    0
       *>                            ----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+
       01 sc-tela.
           05 blank screen.
           05 line 01 col 01 value "          CONSULTA DE RESULTADOS                                                "
           foreground-color 12.
           05 line 03 col 01 value "********************************************                                    ".
           05 line 04 col 01 value "********************************************                                    ".
           05 line 05 col 01 value "**                                        **                                    ".
           05 line 06 col 01 value "**                                        **                                    ".
           05 line 07 col 01 value "**  ID DO FUNCIONARIO:                    **                                    ".
           05 line 08 col 01 value "**                                        **                                    ".
           05 line 09 col 01 value "**                                        **                                    ".
           05 line 10 col 01 value "**                                        **                                    ".
           05 line 11 col 01 value "********************************************                                    ".
           05 line 12 col 01 value "********************************************                                    ".
       *>                                0    1    1    2    2    3    3    4    4    5    5    6    6    7    7    8
       *>                                5    0    5    0    5    0    5    0    5    0    5    0    5    0    5    0
       *>                            ----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+----+
       01 sc-tela.
           05 blank screen.
           05 line 01 col 01 value "                        CONSULTA DE RESULTADOS                                  "
           foreground-color 12.
           05 line 03 col 01 value "  ID DO FUNCIONARIO:                                                            ".
           05 line 05 col 01 value "  DISCIPLINA:                                                                   ".
           05 line 07 col 01 value "  QUANTIDADE DE ACERTOS:                                                        ".
           05 line 09 col 01 value "  NOTA DA PROVA:                                                                ".
           05 line 11 col 01 value "  DATA DA PROVA:                                                                ".
           05 line 12 col 01 value "                                                          [ ]Proxima Disciplina ".
           05 line 13 col 01 value "                                                          [ ]Sair               ".
       *>Declaração do corpo do programa
       procedure division.
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
               perform finaliza-anormal
           end-if
           .
       1000-inicializa-exit.
           exit.

       2000-processamento section.
       *> move "x" to ws-tipo-usuario-adm
       *> testando se o usuário é adm ou funcionario
           if   lnk-tipo-usuario-adm = "x" or lnk-tipo-usuario-adm = "X" then
               perform until ws-resul-sair = "x" or ws-resul-sair = "X"
                       evaluate lnk-operacao
                       when "Buscar um resgistro"
                           move lnk-user-id to fl-user-id
                           read arq-resultados
                           if   ws-fs-arq-resultados = "00" then
                                move fl-resultado to ws-resultado
                                move "Registro lido com sucesso"    to lnk-msn-erro-text
                                move ws-fs-arq-resultados           to lnk-msn-erro-cod
                           else
                                if   ws-fs-arq-resultados = "23" then
                                     move "Codigo inexistente"      to lnk-msn-erro-text
                                     move ws-fs-arq-resultados      to lnk-msn-erro-cod
                               else
                                     move "Erro ao ler registro"    to lnk-msn-erro-text
                                     move ws-fs-arq-resultados      to lnk-msn-erro-cod
                                     perform finaliza-anormal
                               end-if
                           end-if
                       when "Buscar varios registros"
                           move ws-resul-user-id to fl-user-id
                           start arq-resultados
                           if   ws-fs-arq-resultados = "00" then
                               perform until ws-fs-arq-resultados <> "10"
                                   read arq-resultados next
                                   if   ws-fs-arq-resultados = "00" then
                                       move fl-resultado   to ws-resultado
                                   else
                                       if   ws-fs-arq-resultados <> 10
                                           move "Erro ao ler registro" to lnk-msn-erro-text
                                           move ws-fs-arq-resultados   to lnk-msn-erro-cod
                                           perform finaliza-anormal
                                       end-if
                                   end-if
                               end-perform
                           else
                               if   ws-fs-arq-resultados = "23" then
                                       move "Codigo inexistente"   to lnk-msn-erro-text
                                       move ws-fs-arq-resultados   to lnk-msn-erro-cod
                               else
                                       move "Erro ao ler registro" to lnk-msn-erro-text
                                       move ws-fs-arq-resultados   to lnk-msn-erro-cod
                                       perform finaliza-anormal
                               end-if
                           end-if
                       when "Buscar todos os registros"
                           perform until ws-fs-arq-resultados <> 10
                               read arq-resultados next
                               if   ws-fs-arq-resultados = "00" then
                                   move fl-resultado   to ws-resultado
                               else
                                   if   ws-fs-arq-resultados <> 10
                                       move "Erro ao ler registro" to lnk-msn-erro-text
                                       move ws-fs-arq-resultados   to lnk-msn-erro-cod
                                       perform finaliza-anormal
                                   end-if
                               end-if
                           end-perform
                       when "Deletar um registro"
                           move ws-resul-user-id to fl-user-id
                           read arq-resultados
                           if   ws-fs-arq-resultados = "00" then
                               if   lnk-confirmacao = "S"
                                   move "N"    to lnk-confirmacao
                                   delete arq-resultados
                                   if   ws-fs-arq-resultados = "00" then
                                       move "Registro excluido com sucesso" to lnk-msn-erro-text
                                       move ws-fs-arq-resultados            to lnk-msn-erro-cod
                                   else
                                       move "Erro ao excluir registro"      to lnk-msn-erro-text
                                       move ws-fs-arq-resultados            to lnk-msn-erro-cod
                                       perform finaliza-anormal
                                   end-if
                               else
                                   move "?" to lnk-confirmacao
                                   move "Confirma a exclusao de registro?" to lnk-msn
                               end-if
                           else
                               if   ws-fs-arq-resultados = "23" then
                                   move "Codigo inexistente"   to lnk-msn-erro-text
                                   move ws-fs-arq-resultados   to lnk-msn-erro-cod
                               else
                                   move "Erro ao ler registro" to lnk-msn-erro-text
                                   move ws-fs-arq-resultados   to lnk-msn-erro-cod
                                   perform finaliza-anormal
                               end-if
                           end-if
                       end-evaluate
                  end-if

           if   lnk-tipo-usuario-f = "x" or lnk-tipo-usuario-f = "X" then
               move ws-resultado to fl-resultado
               write fl-resultado
               if   ws-fs-arq-resultados  = "00" then
                   move "Registro salvo com sucesso" to lnk-msn-erro-text
                   move ws-fs-arq-resultados         to lnk-msn-erro-cod
               else
                   if   ws-fs-arq-resultados = 22 *> registro já existe
                           if   lnk-confirmacao = "S"
                               move "N" to lnk-confirmacao
                               rewrite fl-resultado
                               if   ws-fs-arq-resultados = "00"
                                   move "Registro alterado com sucesso"   to lnk-msn-erro-text
                                   move ws-fs-arq-resultados              to lnk-msn-erro-cod
                               else
                                   move "Erro ao alterar registro"        to lnk-msn-erro-text
                                   move ws-fs-arq-resultados              to lnk-msn-erro-cod
                                   perform finaliza-anormal
                               end-if
                           else
                               move "?" to lnk-confirmacao
                               move "Confirmar a alteracao de resultado?"  to lnk-msn
                           end-if
                   else
                           move "Erro ao escrever registro"                 to lnk-msn-erro-text
                           move ws-fs-arq-resultados                        to lnk-msn-erro-cod
                           perform finaliza-anormal
                   end-if
               end-if
           end-if
       *> SE O USUARIO FOR ADMIN ELE VAI PODER CONSULTAR AS RESPOSTAS DOS FUNCIONARIOS COLOCANDO O ID DO FUNCIONARIO
       *> O QUE VAI APARECER NA TELA DE CONSULTA: ID DO FUNCIONARIO, QUANTIDADE DE ACERTOS (ID-RESUL), ID DA DISCIPLINA, NOTA E DATA DA PROVA
       *> PUXAR ESSE PROGRAMA JUNTO DA PROVA, PARA ARMAZENAR O NUMERO DE ACERTOS
           .
       2000-processamento-exit.
           exit.
       *>------------------------------------------------------------------------
       *>  Finalização  Anormal
       *>------------------------------------------------------------------------
       finaliza-anormal section.
           display erase
           display lnk-retorno.
           stop run
           .
       finaliza-anormal-exit.
       *> Finalização Normal
       *>------------------------------------------------------------------------
       3000-finaliza section.
           close arq-resultados
           if ws-fs-arq-resultados  <> "00" then
               move 4                                     to lnk-msn-erro-offset
               move ws-fs-arq-resultados                  to lnk-msn-erro-cod
               move "Erro ao fechar arq. arq-resultados"  to lnk-msn-erro-text
               perform finaliza-anormal
           end-if
           stop run
           .
       3000-finaliza-exit.
           exit.
