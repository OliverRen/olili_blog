---
title: Postgresql唯一性冲突异常
tags: 小书匠语法,技术
renderNumberedHeading: true
grammar_abbr: true
grammar_table: true
grammar_defList: true
grammar_emoji: true
grammar_footnote: true
grammar_ins: true
grammar_mark: true
grammar_sub: true
grammar_sup: true
grammar_checkbox: true
grammar_mathjax: true
grammar_flow: true
grammar_sequence: true
grammar_plot: true
grammar_code: true
grammar_highlight: true
grammar_html: true
grammar_linkify: true
grammar_typographer: true
grammar_video: true
grammar_audio: true
grammar_attachment: true
grammar_mermaid: true
grammar_classy: true
grammar_cjkEmphasis: true
grammar_cjkRuby: true
grammar_center: true
grammar_align: true
grammar_tableExtra: true
---

[toc]

唯一索引造成异常错误码 23505
有外键约束导致不能删除的错误码 23503

``` csharp
try
            {
                NpgsqlException exception = null;
                if (ex is NpgsqlException)
                {
                    // 直接调用npgsql或database执行sql的异常
                    exception = ex as NpgsqlException;
                }
                else if (ex.InnerException is System.Data.Entity.Core.UpdateException)
                {
                    // 使用entityframework包装后的system.data异常
                    exception = ex.InnerException.InnerException as NpgsqlException;
                }
                if (exception != null && exception.Code == "23505")
                {
                    // 违反了唯一约束
                    return new Thrift.CreatePaymentOrderResp()
                    {
                        Code = Thrift.CreatePaymentOrderCodes.UniqueConflict,
                        ErrorMessage = "当前应用指定的外部唯一id订单已经存在"
                    };
                }
            }
            catch (Exception e)
            {
                _log.Error(e.Message, e);
            }
```