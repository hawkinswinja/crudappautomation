
// import React, { Suspense, lazy } from 'react';
// import { Switch, Route } from 'react-router-dom';

// const Home = lazy(() => import('./components/product/Home'));
// const ProductIndex = lazy(() => import('./components/product/Index'));
// const CreateProduct = lazy(() => import('./components/product/Create'));
// const ProductDetail = lazy(() => import('./components/product/Detail'));
// const EditProduct = lazy(() => import('./components/product/Edit'));
// const DeleteProduct = lazy(() => import('./components/product/Delete'));

// // 👇 Lazy load your auth components
// const Login = lazy(() => import('./components/auth/Login'));
// const Register = lazy(() => import('./components/auth/Register'));

// function AppRouter() {
//   return (
//     <Suspense fallback={null}>
//       <Switch>
//         <Route path="/" component={Home} exact />
//         <Route path="/product" component={ProductIndex} exact />
//         <Route path="/product/create" component={CreateProduct} exact />
//         <Route path="/product/:id/" component={ProductDetail} exact />
//         <Route path="/product/edit/:id/" component={EditProduct} exact />
//         <Route path="/product/delete/:id/" component={DeleteProduct} exact />

//         {/* 👇 Add auth routes */}
//         <Route path="/login" component={Login} exact />
//         <Route path="/register" component={Register} exact />
//       </Switch>
//     </Suspense>
//   );
// }

// export default AppRouter;

// import React, { Suspense, lazy } from 'react'
// import { Switch, Route, Redirect } from 'react-router-dom'

// export default function AppRoute(props) {
//   return (
//     <Suspense fallback={''}>
//       <Switch>
//         <Route path="/" component={lazy(() => import('./components/product/Home'))} exact />
//         <Route path="/product" component={lazy(() => import('./components/product/Index'))} exact />
//         <Route path="/product/create" component={lazy(() => import('./components/product/Create'))} exact />
//         <Route path="/product/:id/" component={lazy(() => import('./components/product/Detail'))} exact />
//         <Route path="/product/edit/:id/" component={lazy(() => import('./components/product/Edit'))} exact />
//         <Route path="/product/delete/:id/" component={lazy(() => import('./components/product/Delete'))} exact />
//       </Switch>
//     </Suspense>
//   )
// }
import React, { Suspense, lazy } from 'react'
import { Switch, Route, Redirect } from 'react-router-dom'

export default function AppRoute(props) {
  return (
    <Suspense fallback={''}>
      <Switch>
        <Route path="/" component={(p) => <Redirect to="/Home" /> } exact />
        <Route path="/Home" component={lazy(() => import('./components/product/Home'))} exact />
        <Route path="/product" component={lazy(() => import('./components/product/Index'))} exact />
        <Route path="/product/create" component={lazy(() => import('./components/product/Create'))} exact />
        <Route path="/product/:id/" component={lazy(() => import('./components/product/Detail'))} exact />
        <Route path="/product/edit/:id/" component={lazy(() => import('./components/product/Edit'))} exact />
        <Route path="/product/delete/:id/" component={lazy(() => import('./components/product/Delete'))} exact />
        <Route path="/login" component={lazy(() => import('./components/Auth/Login'))} exact />
        <Route path="/register" component={lazy(() => import('./components/Auth/Register'))} exact />
      </Switch>
    </Suspense>
  )
}