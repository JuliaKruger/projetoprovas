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
       special-names. decimal-point is comma.

      *>----Declaração dos recursos externos
       input-output section.
       file-control.

           select arq-resultados assign to "arq-resultados.dat"
           organization is indexed
           access mode is dynamic
           lock mode is manual with lock on multiple records
           record key is fl-chave-resul
           alternate key is fl-user-disc with duplicates
           file status is ws-fs-arq-resultados.

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
           05 fl-nota                              pic -99,99.
           05 fl-data-prova                        pic x(10).

      *>----Variáveis de trabalho
       working-storage section.
       77 ws-fs-arq-resultados                     pic x(02).

       77 ws-operacao                              pic x(02).
           88 ws-salvar                            value "SA".
           88 ws-consultar-um                      value "C1".
           88 ws-consultar-varios                  value "CN".
           88 ws-consultar-todos                   value "CT".
           88 ws-excluir                           value "DE".

       77 ws-confirmacao                           pic x(01).
           88 ws-confirmar                         value "?".
           88 ws-confirmado                        value "S".
           88 ws-nao-confirmado                    value "N".

       77 ws-ind                                   pic 9(03).

      *>----Variáveis para comunicação entre programas
       linkage section.
       01 lnk-controle.
           05 lnk-operacao                         pic x(02).
           05 lnk-confirmacao                      pic x(01).
           05 lnk-msn                              pic x(50).
           05 lnk-retorno.
               10 lnk-msn-erro-pmg                 pic x(09). *> id do pmg
               10 lnk-msn-erro-offset              pic 9(03). *> local do erro
               10 lnk-return-code                  pic 9(02). *> status do pmg
               10 lnk-msn-erro-cod                 pic x(02). *> file status
               10 lnk-msn-erro-text                pic x(50). *> mensagem de erro

       01 lnk-gp-resultado.
           05 lnk-resultado.
               10 lnk-chave-resul.
                   15 lnk-id-resultado                  pic 9(02).
                   15 lnk-user-disc.
                       20 lnk-user-id                   pic x(08).
                       20 lnk-id-disciplina             pic 9(03).
               10 lnk-nota                              pic -99,99.
               10 lnk-data-prova                        pic x(10).

      *>----Declaração de tela
       screen section.

      *>----Declaração do corpo do programa
       procedure division using lnk-controle, lnk-gp-resultado.

      *>------------------------------------------------------------------------
      *>  Controle das seções
      *>------------------------------------------------------------------------
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
           open i-o arq-resultados                 *> open i-o abre o arquivo para leitura e escrita
           if   ws-fs-arq-resultados  <> "00"      *> file status 00: comando executado com sucesso
           and  ws-fs-arq-resultados <> "05" then  *> file status 05: open opcional com sucesso, mas não existe aquivo anterior
                move "P06SISC20"                         to lnk-msn-erro-pmg
                move 1                                   to lnk-msn-erro-offset
                move 12                                  to lnk-return-code
                move ws-fs-arq-resultados                to lnk-msn-erro-cod
                move "Erro ao abrir arq. arq-resultados" to lnk-msn-erro-text
                perform 9000-finaliza-anormal
           end-if
           move lnk-confirmacao to ws-confirmacao  *> movendo a confirmação do usuário da linkage storage para a working storage
           .
       1000-inicializa-exit.
           exit.

      *>------------------------------------------------------------------------
      *>  Processamento principal
      *>------------------------------------------------------------------------
       2000-processamento section.
           evaluate lnk-operacao
               when "SA"
                   perform 2100-salvar-dados       *> seção para salvar dados
               when "C1"
                   perform 2200-b-um-registro      *> seção para buscar um registro
               when "CN"
                   perform 2300-b-varios-registros *> seção para buscar varios registros
               when "CT"
                   perform 2400-b-todos-registros  *> seção para buscar todos os registros
               when "DE"
                   perform 2500-deletar-dados      *> seção para deletar dados
           end-evaluate

           .
       2000-processamento-exit.
           exit.

      *>------------------------------------------------------------------------
      *>  Seção para salvar dados
      *>------------------------------------------------------------------------
       2100-salvar-dados section.
           move lnk-resultado                      to fl-resultado
           write fl-resultado                      *> escrevendo os dados no arquivo
           if   ws-fs-arq-resultados  = "00" or ws-fs-arq-resultados = "02" then  *> file status 02: sucesso, mas existe chave alternada
                move "P06SISC20"                   to lnk-msn-erro-pmg
                move 2                             to lnk-msn-erro-offset
                move 00                            to lnk-return-code
                move "Registro salvo com sucesso"  to lnk-msn-erro-text
                move ws-fs-arq-resultados          to lnk-msn-erro-cod
           else
                if   ws-fs-arq-resultados = 22 then*> file status 22: na gravação, registro já existe
                     if   ws-confirmado then
                          *> movendo "N" para ws-confirmacao (usuário ainda precisa confirmar a exclusão de registro)
                          set ws-nao-confirmado    to true
                          rewrite fl-resultado     *> reescrevendo o registro caso o usuário queira
                          if   ws-fs-arq-resultados = "00" then
                               move "P06SISC20"                          to lnk-msn-erro-pmg
                               move 3                                    to lnk-msn-erro-offset
                               move 00                                   to lnk-return-code
                               move "Registro alterado com sucesso"      to lnk-msn-erro-text
                               move ws-fs-arq-resultados                 to lnk-msn-erro-cod
                          else
                               move "P06SISC20"                          to lnk-msn-erro-pmg
                               move 4                                    to lnk-msn-erro-offset
                               move 12                                   to lnk-return-code
                               move "Erro ao alterar registro"           to lnk-msn-erro-text
                               move ws-fs-arq-resultados                 to lnk-msn-erro-cod
                               perform 9000-finaliza-anormal
                          end-if
                     else
                          *> movendo "?" para ws-confirmacao
                          set ws-confirmar         to true
                          *> saber se o usuário quer reescrever o registro
                          move "SA-Confirmar a alteracao de resultado?"  to lnk-msn
                     end-if
                else
                     move "P06SISC20"                                    to lnk-msn-erro-pmg
                     move 5                                              to lnk-msn-erro-offset
                     move 12                                             to lnk-return-code
                     move "Erro ao escrever registro"                    to lnk-msn-erro-text
                     move ws-fs-arq-resultados                           to lnk-msn-erro-cod
                     perform 9000-finaliza-anormal
                end-if
           end-if
           .
       2100-salvar-dados-exit.
           exit.

      *>------------------------------------------------------------------------
      *>  Seção para consultar/buscar um registro
      *>------------------------------------------------------------------------
       2200-b-um-registro section.
      *> carregando as chaves do arquivo
           move lnk-user-id                        to fl-user-id
           move lnk-id-disciplina                  to fl-id-disciplina
           read arq-resultados key fl-user-id      *> lendo o arquivo usando a chave
           if   ws-fs-arq-resultados = "00" then
                move fl-resultado to lnk-resultado
                move "P06SISC20"                   to lnk-msn-erro-pmg
                move 6                             to lnk-msn-erro-offset
                move 00                            to lnk-return-code
                move "Registro lido com sucesso"   to lnk-msn-erro-text
                move ws-fs-arq-resultados          to lnk-msn-erro-cod
           else
                if   ws-fs-arq-resultados = "23" then *> file status 23: na leitura, registro não existe
                     move "P06SISC20"              to lnk-msn-erro-pmg
                     move 7                        to lnk-msn-erro-offset
                     move 04                       to lnk-return-code
                     move "Codigo inexistente"     to lnk-msn-erro-text
                     move ws-fs-arq-resultados     to lnk-msn-erro-cod
                else
                     move "P06SISC20"              to lnk-msn-erro-pmg
                     move 8                        to lnk-msn-erro-offset
                     move 12                       to lnk-return-code
                     move "Erro ao ler registro"   to lnk-msn-erro-text
                     move ws-fs-arq-resultados     to lnk-msn-erro-cod
                     perform 9000-finaliza-anormal
                end-if
           end-if
           .
       2200-b-um-registro-exit.
           exit.

      *>------------------------------------------------------------------------
      *>  Seção para consultar/buscar varios registros / não está funcionando
      *>------------------------------------------------------------------------
       2300-b-varios-registros section.
      *> carregando a chave do arquivo
           move lnk-user-id                        to fl-user-id
           start arq-resultados key = fl-user-disc *> começando o arquivo a partir da chave que o usuário inseriu
           if   ws-fs-arq-resultados = "00" then
                perform until ws-fs-arq-resultados <> "10"          *> lendo até o final do arquivo
                           or fl-user-disc > lnk-user-disc
                     read arq-resultados next record                *> lendo o arquivo sequencialmente
                     if   ws-fs-arq-resultados = "00" or ws-fs-arq-resultados = "02"
                     and  fl-user-disc = lnk-user-disc then         *> ... e as variáveis da chave do arquivo forem iguais às variáveis da linkage section
                          move fl-resultado        to lnk-resultado *> movendo o registro do arquivo para as variáveis da linkage section
                     else
                          if   ws-fs-arq-resultados <> 10   *> file status 10: fim do arquivo
                               move "P06SISC20"             to lnk-msn-erro-pmg
                               move 9                       to lnk-msn-erro-offset
                               move 12                      to lnk-return-code
                               move "Erro ao ler registro"  to lnk-msn-erro-text
                               move ws-fs-arq-resultados    to lnk-msn-erro-cod
                               perform 9000-finaliza-anormal
                          end-if
                     end-if
                end-perform
           else
                if   ws-fs-arq-resultados = "23" then
                     move "P06SISC20"              to lnk-msn-erro-pmg
                     move 10                       to lnk-msn-erro-offset
                     move 04                       to lnk-return-code
                     move "Codigo inexistente"     to lnk-msn-erro-text
                     move ws-fs-arq-resultados     to lnk-msn-erro-cod
                else
                     move "P06SISC20"              to lnk-msn-erro-pmg
                     move 11                       to lnk-msn-erro-offset
                     move 12                       to lnk-return-code
                     move "Erro ao ler registro"   to lnk-msn-erro-text
                     move ws-fs-arq-resultados     to lnk-msn-erro-cod
                     perform 9000-finaliza-anormal
                end-if
           end-if
           .
       2300-b-varios-registros-exit.
           exit.

      *>------------------------------------------------------------------------
      *>  Seção para consultar/buscar todos os registros / não está funcionando
      *>------------------------------------------------------------------------
       2400-b-todos-registros section.
           *> fazer até o fim do arquivo
           perform varying ws-ind from 1 by 1 until ws-fs-arq-resultados = 10
                                                 or ws-ind > 100
                read arq-resultados next           *> lendo o arquivo sequencialmente
                if   ws-fs-arq-resultados = "00" then
                     *> movendo o registro do arquivo para as variáveis da linkage section
                     move fl-resultado                    to lnk-resultado
                else
                     if   ws-fs-arq-resultados = "10"
                          move "P06SISC20"                to lnk-msn-erro-pmg
                          move 12                         to lnk-msn-erro-offset
                          move 04                         to lnk-return-code
                          move "Todos os registros lidos" to lnk-msn-erro-text
                          move ws-fs-arq-resultados       to lnk-msn-erro-cod
                     else
                          move "P06SISC20"                to lnk-msn-erro-pmg
                          move 13                         to lnk-msn-erro-offset
                          move 12                         to lnk-return-code
                          move "Erro ao ler registro"     to lnk-msn-erro-text
                          move ws-fs-arq-resultados       to lnk-msn-erro-cod
                          perform 9000-finaliza-anormal
                     end-if
                end-if
           end-perform
           .
       2400-b-todos-registros-exit.
           exit.

      *>------------------------------------------------------------------------
      *>  Seção para deletar dados
      *>------------------------------------------------------------------------
       2500-deletar-dados section.
      *> movendo os dados da linkage section para as variáveis da file section (chaves)
           move lnk-id-resultado                   to fl-id-resultado
           move lnk-user-id                        to fl-user-id
           move lnk-id-disciplina                  to fl-id-disciplina
           read arq-resultados                     *> lendo o arquivo
           if   ws-fs-arq-resultados = "00" then
                if   ws-confirmado then
                     *> movendo "N" para ws-confirmacao (usuário ainda precisa confirmar a exclusão de registro)
                     set ws-nao-confirmado         to true
                     delete arq-resultados         *> deletando o registro
                     if   ws-fs-arq-resultados = "00" then
                          move "P06SISC20"                      to lnk-msn-erro-pmg
                          move 14                               to lnk-msn-erro-offset
                          move 00                               to lnk-return-code
                          move "Registro excluido com sucesso"  to lnk-msn-erro-text
                          move ws-fs-arq-resultados             to lnk-msn-erro-cod
                     else
                          move "P06SISC20"                      to lnk-msn-erro-pmg
                          move 15                               to lnk-msn-erro-offset
                          move 12                               to lnk-return-code
                          move "Erro ao excluir registro"       to lnk-msn-erro-text
                          move ws-fs-arq-resultados             to lnk-msn-erro-cod
                          perform 9000-finaliza-anormal
                     end-if
                else
                     *> movendo "?" para ws-confirmacao
                     set ws-confirmar              to true
                     *> saber se o usuário quer excluir/deletar o registro
                     move "DE-Confirma a exclusao de registro?" to lnk-msn
                end-if
           else
                if   ws-fs-arq-resultados = "23" then
                     move "P06SISC20"              to lnk-msn-erro-pmg
                     move 16                       to lnk-msn-erro-offset
                     move 04                       to lnk-return-code
                     move "Codigo inexistente"     to lnk-msn-erro-text
                     move ws-fs-arq-resultados     to lnk-msn-erro-cod
                else
                     move "P06SISC20"              to lnk-msn-erro-pmg
                     move 17                       to lnk-msn-erro-offset
                     move 12                       to lnk-return-code
                     move "Erro ao ler registro"   to lnk-msn-erro-text
                     move ws-fs-arq-resultados     to lnk-msn-erro-cod
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
      *> movendo 12 (seguindo a especificação) para o return code da linkage section
           move 12                                 to lnk-return-code
      *> parando a execução o programa
           stop run
           .
       9000-finaliza-anormal-exit.
           exit.

      *>------------------------------------------------------------------------
      *>  Finalização Normal
      *>------------------------------------------------------------------------
       3000-finaliza section.
      *> movendo a variável de confirmação da working storage para a linkage section
           move ws-confirmacao                     to lnk-confirmacao
           close arq-resultados                    *> fechando o arquivo
           if   ws-fs-arq-resultados  <> "00" then
                move "P06SISC20"                           to lnk-msn-erro-pmg
                move 18                                    to lnk-msn-erro-offset
                move 12                                    to lnk-return-code
                move "Erro ao fechar arq. arq-resultados"  to lnk-msn-erro-text
                move ws-fs-arq-resultados                  to lnk-msn-erro-cod
                perform 9000-finaliza-anormal
           end-if
      *> saindo do programa chamado
           exit program
           .
       3000-finaliza-exit.
           exit.

