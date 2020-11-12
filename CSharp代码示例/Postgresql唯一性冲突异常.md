---
title: Postgresql唯一性冲突异常
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