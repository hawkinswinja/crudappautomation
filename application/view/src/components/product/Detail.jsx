import React, { useState, useEffect } from 'react'
import { Link } from 'react-router-dom'
import Service from './Service'

export default function ProductDetail(props) {
  
  const [ product, setProduct ] = useState({})
  
  useEffect(() => {
    get()
  }, [ props.match.params.id ])
  
  function get() {
    return Service.get(props.match.params.id).then(response => {
      setProduct(response.data)
    }).catch(e => {
      alert(e.response.data)
    })
  }

  return (
    <div className="container">
      <div className="row">
        <div className="col">
          <form method="post">
            <div className="row">
              <div className="mb-3 col-md-6 col-lg-4">
                <label className="form-label" htmlFor="product_id">Id</label>
                <input readOnly id="product_id" name="id" className="form-control" value={product.id ?? '' } type="number" required />
              </div>
              <div className="mb-3 col-md-6 col-lg-4">
                <label className="form-label" htmlFor="product_name">Name</label>
                <input readOnly id="product_name" name="name" className="form-control" value={product.name ?? '' } maxLength="50" />
              </div>
              <div className="mb-3 col-md-6 col-lg-4">
                <label className="form-label" htmlFor="product_price">Price</label>
                <input readOnly id="product_price" name="price" className="form-control" value={product.price ?? '' } type="number" />
              </div>
              <div className="col-12">
                <Link className="btn btn-secondary" to="/product">Back</Link>
                <Link className="btn btn-primary" to={`/product/edit/${product.id}`}>Edit</Link>
              </div>
            </div>
          </form>
        </div>
      </div>
    </div>
  )
}